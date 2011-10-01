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
#print STDERR "$selector_for_comparison\n";
        print STDERR "Creating script for evaluation ($name).\n";
        open (BASHSCRIPT, ">:utf8", "eval-$name.sh") or die;
        print BASHSCRIPT "#!/bin/bash\n\n";
        
        # Write UAS score
#        print BASHSCRIPT "treex Eval::AtreeUAS eval_is_member=1 eval_is_shared_modifier=1 language=$language selector='$selector_for_comparison' -- $dir/parsed/*.treex.gz  | tee $dir/parsed/uas.txt\n";
        
        # Writes accuracy results with confidence interval
        print BASHSCRIPT "treex Eval::AtreeUASWithConfInterval eval_is_member=1 eval_is_shared_modifier=1 language=$language selector='$selector_for_comparison' -- $dir/parsed/*.treex.gz  | tee $dir/parsed/uas_conf.txt\n";
        
        #print BASHSCRIPT "treex Eval::AtreeUAStat language=$language selector='$selector_for_comparison' -- $dir/parsed/*.treex.gz > $dir/parsed/uastat.txt\n";
        
        close BASHSCRIPT;
        system "qsub -hard -l mf=5g -l act_mem_free=5g -cwd -j yes -cwd eval-$name.sh";
    }
}
