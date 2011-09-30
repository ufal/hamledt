#!/usr/bin/env perl
use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";

my ($help, $mcd, $mcdproj, $malt, $new, $topdt);

GetOptions(
    "help|h"  => \$help,
    "topdt"   => \$topdt,
);

if ($help || !@ARGV) {
    die "Usage: eval.pl [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    -h,--help  - print this help
";
}

foreach my $language (@ARGV) {
    foreach my $dir (glob "$data_dir/$language/treex/*") {
        next if !-d $dir;
        next if !-e "$dir/parsed/001.treex.gz";
        my $name = $dir;
        $name =~ s/^.+\///;
        $name = "$language-$name";
        my $selector_for_comparison = $name =~ m/trans_/ && $topdt ? 'before' : '';

        print STDERR "Creating script for evaluation ($name).\n";
        open (BASHSCRIPT, ">:utf8", "eval-$name.sh") or die;
        print BASHSCRIPT "#!/bin/bash\n\n";
        
        # Write UAS score for each sample of 10 sentences
        print BASHSCRIPT "treex Eval::AtreeUAS sample_size=10 eval_is_member=1 eval_is_shared_modifier=1 language=$language selector='$selector_for_comparison' -- $dir/parsed/*.treex.gz > $dir/parsed/uas_samples.txt\n";
        
        close BASHSCRIPT;
        system "qsub -cwd -j yes eval-$name.sh";
    }
}
