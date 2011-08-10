#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";
my $mcd_dir  = $ENV{TMT_ROOT}."/libs/other/Parser/MST/mstparser-0.4.3b";

if (!@ARGV) {
    die "Usage: mcd_train.pl [LANGUAGES]\n";
}

foreach my $language (@ARGV) {
    foreach my $dir (glob "$data_dir/$language/treex/*") {
        next if (!-d $dir);
        my $name = $dir;
        $name =~ s/^.+\///;
        $name = "$language-$name";
        print STDERR "Creating script for McD training $name.\n";
        open (BASHSCRIPT, ">:utf8", "$name.sh") or die;
        print BASHSCRIPT "#!/bin/bash\n\n";
        print BASHSCRIPT "treex Write::CoNLLX language=$language -- $dir/train/*.treex > $dir/train.conll\n";
        print BASHSCRIPT "python $mcd_dir/bin/conll2mst.py $dir/train.conll > $dir/train.mst\n";
        print BASHSCRIPT "java -cp $mcd_dir/output/mstparser.jar:$mcd_dir/lib/trove.jar -Xmx2g mstparser.DependencyParser \\\n";
        print BASHSCRIPT "  train order:2 format:MST train-file:$dir/train.mst model-name:$dir/mcd.model\n";
        close BASHSCRIPT;
        system "qsub -cwd $name.sh";
    }
}
