#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";

my ($help, $mcd, $mcdproj, $malt, $new);

GetOptions(
    "help|h"  => \$help,
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
        print STDERR "Creating script for evaluation ($name).\n";
        open (BASHSCRIPT, ">:utf8", "eval-$name.sh") or die;
        print BASHSCRIPT "#!/bin/bash\n\n";
        print BASHSCRIPT "treex Eval::AtreeUAS language=$language selector='' -- $dir/parsed/*.treex.gz > $dir/parsed/uas.txt";
        close BASHSCRIPT;
        system "qsub -cwd eval-$name.sh";
    }
}
