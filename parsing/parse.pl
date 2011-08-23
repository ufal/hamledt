#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";

my ($help, $mcd, $mcdproj, $malt, $new);

GetOptions(
    "help|h"  => \$help,
    "mcd"     => \$mcd,
    "mcdproj" => \$mcdproj,
    "malt"    => \$malt,
    "new"     => \$new,
);

if ($help || !@ARGV) {
    die "Usage: parse.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --mcd      - run McDonald's MST non-projective parser
    --mcdproj  - run McDonald's MST projective parser
    --malt     - run Malt parser
    --new      - copy the testing file from 'test' directory
    -h,--help  - print this help
";
}

foreach my $language (@ARGV) {
    foreach my $dir (glob "$data_dir/$language/treex/*") {
        next if (!-d $dir);
        if (!-e "$dir/parsed/001.treex" || $new) {
            system "cp $dir/test/*.treex $dir/parsed/";
        }
        my $name = $dir;
        $name =~ s/^.+\///;
        $name = "$language-$name";
        my $scenario;
        if ($mcd && -e "$dir/parsed/mcd_nonproj_o2.model") {
            $scenario .= "Util::SetGlobal language=$language selector=mcdnonprojo2 ";
            $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' " ;
            $scenario .= "A2A::CopyAtree source_selector='' flatten=1 ";
            $scenario .= "W2A::ParseMST model=$dir/parsed/mcd_nonproj_o2.model decodetype=non-proj pos_attribute=conll/pos ";
        }
        if ($mcdproj && -e "$dir/parsed/mcd_proj_o2.model") {
            $scenario .= "Util::SetGlobal language=$language selector=mcdprojo2 ";
            $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' " ;
            $scenario .= "A2A::CopyAtree source_selector='' flatten=1 ";
            $scenario .= "W2A::ParseMST model=$dir/parsed/mcd_proj_o2.model decodetype=proj pos_attribute=conll/pos ";
        }
        if ($malt && -e "$dir/parsed/malt_stackeager.mco") {
            $scenario .= "Util::SetGlobal language=$language selector=maltstackeager ";
            $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' " ;
            $scenario .= "A2A::CopyAtree source_selector='' flatten=1 ";
            $scenario .= "W2A::ParseMalt model=$dir/parsed/malt_nivreeager.mco pos_attribute=conll/pos cpos_attribute=conll/cpos ";
        }
        $scenario .= "Eval::AtreeUAS selector='' ";
        print STDERR "Creating script for parsing ($name).\n";
        open (BASHSCRIPT, ">:utf8", "parse-$name.sh") or die;
        print BASHSCRIPT "#!/bin/bash\n\n";
        print BASHSCRIPT "treex -s $scenario -- $dir/parsed/*.treex > $dir/parsed/uas.txt";
        close BASHSCRIPT;
        system "qsub -l mf=3g -cwd parse-$name.sh";
    }
}
