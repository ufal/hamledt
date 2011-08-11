#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";

if (!@ARGV) {
    die "Usage: mcd_train.pl [LANGUAGES]\n";
}

foreach my $language (@ARGV) {
    foreach my $dir (glob "$data_dir/$language/treex/*") {
        next if (!-d $dir);
        next if (!-e "$dir/parsed/mcd_nonproj_o2.model");
        my $name = $dir;
        $name =~ s/^.+\///;
        $name = "$language-$name";
        print STDERR "Creating script for McD parsing $name.\n";
        open (BASHSCRIPT, ">:utf8", "$name-parse.sh") or die;
        print BASHSCRIPT "#!/bin/bash\n\n";
        print BASHSCRIPT "cp $dir/test/*.treex $dir/parsed/\n";
        print BASHSCRIPT "treex -s Util::SetGlobal language=$language selector=mcdnonprojo2 \\
  Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' \\
  A2A::CopyAtree flatten=1 \\
  W2A::ParseMST model=$dir/mcd_nonproj_o2.model \\
  Eval::AtreeUAS selector=''\\
  -- $dir/parsed/*.treex >> $dir/parsed/uas.txt";
        close BASHSCRIPT;
        system "qsub -cwd $name-parse.sh";
    }
}
