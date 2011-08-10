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
        next if (!-e "$dir/mcd.model");
        system "treex -ps Util::SetGlobal language=$language selector=mcdnonprojo2 A2A::CopyAtree flatten=1 W2A::ParseMST model=$dir/mcd.model -- $dir/test/*.treex";
    }
}
