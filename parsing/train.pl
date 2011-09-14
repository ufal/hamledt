#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";
my $mcd_dir  = $ENV{TMT_ROOT}."/libs/other/Parser/MST/mstparser-0.4.3b";
my $malt_dir = $ENV{TMT_ROOT}."/share/installed_tools/malt_parser/malt-1.5";

my ($help, $mcd, $mcdproj, $malt, $maltsmf, $feat, $trans, $new);
$feat = '_'; # default

GetOptions(
    "help|h"  => \$help,
    "mcd"     => \$mcd,
    "malt"    => \$malt,
    "maltsmf" => \$maltsmf,
    "mcdproj" => \$mcdproj,
    "trans=s"   => \$trans,
    "feat=s"  => \$feat,
    "new"     => \$new,
);


if ($help || !@ARGV) {
    die "Usage: train.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --mcd      - train McDonald's non-projective MST parser
    --mcdproj  - train McDonald's projective MST parser
    --malt     - train Malt parser
    --maltsmf  - train Malt parser with stack algorithm and morph features
    --new      - create training file if it does not exist
    --trans    - select transformation, all transformations are run otherwise
    --feat     - select features conll|iset|_ (_ is default)
    -h,--help  - print this help
";
}


foreach my $language (@ARGV) {
    my $glob = $trans ? "$data_dir/$language/treex/$trans" : "$data_dir/$language/treex/*";
    foreach my $dir (glob $glob) {
        next if (!-d $dir);
        my $name = $dir;
        $name =~ s/^.+\///;
        $name = "$language-$name";
        my $deprel_attribute = $name =~ /000_orig/ ? 'conll/deprel' : 'afun';
        system "mkdir -p $dir/parsed";
        # Send error messages to /dev/null because it is quite probable that there are files
        # that we do not own and thus cannot change their permissions although we have write access to them.
        system "chmod -R g+wx $dir/parsed 2>/dev/null";
        my $trainfilename = 'train.conll';
        if ($new || !-e "$dir/parsed/$trainfilename") {
            my $f = '';
            if ( $feat eq 'conll' ) {
                $f = 'feat_attribute=conll/feat';
                $trainfilename = 'train-conllfeat.conll';
            } elsif ( $feat eq 'iset' ) {
                $f = 'feat_attribute=iset';
                $trainfilename = 'train-iset.conll';
            }
            system "treex -p -j 20 Write::CoNLLX language=$language $f deprel_attribute=$deprel_attribute -- $dir/train/*.treex.gz > $dir/parsed/$trainfilename";
        }
        if ($mcd || $mcdproj) {
            system "cat $dir/parsed/$trainfilename | ./conll2mst.pl > $dir/parsed/train.mst\n";
        }
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
            print BASHSCRIPT "cd $dir/parsed/; java -Xmx9g -jar $malt_dir/malt.jar -i $trainfilename -c malt_nivreeager -a nivreeager -l liblinear -m learn\n";
            close BASHSCRIPT;
            system "qsub -l mf=10g -cwd malt-$name.sh";
        }
        if ($maltsmf) {
            print STDERR "Creating script for training Malt parser with stack and morph features ($name).\n";
            open (BASHSCRIPT, ">:utf8", "maltsmf-$name.sh") or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            my $features = '/net/work/people/zeman/parsing/malt-parser/marco-kuhlmann-czech-settings/CzechNonProj-JOHAN-NEW-MODIFIED.xml';
            print BASHSCRIPT "cd $dir/parsed/; java -Xmx29g -jar $malt_dir/malt.jar -i $trainfilename -c malt_stacklazy -a stacklazy -F $features -grl Pred -d POSTAG -s 'Stack[0]' -T 1000 -gds T.TRANS,A.DEPREL -l libsvm -m learn\n";
            close BASHSCRIPT;
            system "qsub -l mf=31g -cwd maltsmf-$name.sh";
        }
    }
}
