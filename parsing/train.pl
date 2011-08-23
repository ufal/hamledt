#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";
my $mcd_dir  = $ENV{TMT_ROOT}."/libs/other/Parser/MST/mstparser-0.4.3b";
my $malt_dir = $ENV{TMT_ROOT}."/share/installed_tools/malt_parser/malt-1.5";

my ($help, $mcd, $malt);

GetOptions(
    "help|h" => \$help,
    "mcd"    => \$mcd,
    "malt"   => \$malt,
);


if ($help || !@ARGV) {
    die "Usage: train.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --mst      - train McDonald's MST parser
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
        if ($mcd) {
            print STDERR "Creating script for training McDonald's parser ($name).\n";
            open (BASHSCRIPT, ">:utf8", "mcd-$name.sh") or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            print BASHSCRIPT "python $mcd_dir/bin/conll2mst.py $dir/parsed/train.conll > $dir/parsed/train.mst\n";
            print BASHSCRIPT "java -cp $mcd_dir/output/mstparser.jar:$mcd_dir/lib/trove.jar -Xmx9g mstparser.DependencyParser \\\n";
            print BASHSCRIPT "  train order:2 format:MST train-file:$dir/parsed/train.mst model-name:$dir/parsed/mcd_nonproj_o2.model\n";
            close BASHSCRIPT;
            system "qsub -l mf=10g -cwd mcd-$name.sh";
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
