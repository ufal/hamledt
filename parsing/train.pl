#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";
my $mcd_dir  = $ENV{TMT_ROOT}."/libs/other/Parser/MST/mstparser-0.4.3b";
my $malt_dir = $ENV{TMT_ROOT}."/share/installed_tools/malt_parser/malt-1.5";

my ($help, $mcd, $mcdproj, $malt);

GetOptions(
    "help|h"  => \$help,
    "mcd"     => \$mcd,
    "malt"    => \$malt,
    "mcdproj" => \$mcdproj
);


if ($help || !@ARGV) {
    die "Usage: train.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --mcd      - train McDonald's non-projective MST parser
    --mcdproj  - train McDonald's projective MST parser
    --malt     - train Malt parser
    -h,--help  - print this help
";
}


foreach my $language (@ARGV) {
    foreach my $dir (glob "$data_dir/$language/treex/*") {
        next if (!-d $dir);
        my $name = $dir;
        $name =~ s/^.+\///;
        $name = "$language-$name";
        my $deprel_attribute = $name =~ /000_orig/ ? 'conll/deprel' : 'afun';
        system "mkdir -p $dir/parsed";
        system "treex -p -j 100 Write::CoNLLX language=$language deprel_attribute=$deprel_attribute -- $dir/train/*.treex > $dir/parsed/train.conll";
        system "python $mcd_dir/bin/conll2mst.py $dir/parsed/train.conll > $dir/parsed/train.mst\n";
        if ($mcd) {
            print STDERR "Creating script for training McDonald's non-projective parser ($name).\n";
            open (BASHSCRIPT, ">:utf8", "mcd-$name.sh") or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            print BASHSCRIPT "java -cp $mcd_dir/output/mstparser.jar:$mcd_dir/lib/trove.jar -Xmx9g mstparser.DependencyParser \\\n";
            print BASHSCRIPT "  train order:2 format:MST decode-type:non-proj train-file:$dir/parsed/train.mst model-name:$dir/parsed/mcd_nonproj_o2.model\n";
            close BASHSCRIPT;
            system "qsub -l mf=10g -cwd mcd-$name.sh";
        }
        if ($mcdproj) {
            print STDERR "Creating script for training McDonald's projective parser ($name).\n";
            open (BASHSCRIPT, ">:utf8", "mcdproj-$name.sh") or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            print BASHSCRIPT "java -cp $mcd_dir/output/mstparser.jar:$mcd_dir/lib/trove.jar -Xmx9g mstparser.DependencyParser \\\n";
            print BASHSCRIPT "  train order:2 format:MST decode-type:proj train-file:$dir/parsed/train.mst model-name:$dir/parsed/mcd_proj_o2.model\n";
            close BASHSCRIPT;
            system "qsub -l mf=10g -cwd mcdproj-$name.sh";
        }
        if ($malt) {
            print STDERR "Creating script for training Malt parser ($name).\n";
            open (BASHSCRIPT, ">:utf8", "malt-$name.sh") or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            print BASHSCRIPT "cd $dir/parsed/; java -Xmx9g -jar $malt_dir/malt.jar -i train.conll -c malt_nivreeager -a nivreeager -l liblinear -m learn\n";
            close BASHSCRIPT;
            system "qsub -l mf=10g -cwd malt-$name.sh";
        }
    }
}
