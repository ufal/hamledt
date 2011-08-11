#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";

my ($help, $mcd, $malt);

GetOptions(
    "help|h" => \$help,
    "mcd"    => \$mcd,
    "malt"   => \$malt,
);

if ($help || !@ARGV) {
    die "Usage: train.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --mst      - run McDonald's MST parser
    --malt     - run Malt parser
    -h,--help  - print this help
";
}

foreach my $language (@ARGV) {
    foreach my $dir (glob "$data_dir/$language/treex/*") {
        next if (!-d $dir);
        if (!-e "$dir/parsed/*.treex") {
            print STDERR "Treex files not found in 'parsed' directory. They will be copied form 'test' directory.\n";
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
            $scenario .= "W2A::ParseMST model=$dir/parsed/mcd_nonproj_o2.model ";
        }
        if ($malt && -e "$dir/parsed/malt_stackeager.mco") {
            $scenario .= "Util::SetGlobal language=$language selector=maltstackeager ";
            $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' " ;
            $scenario .= "A2A::CopyAtree source_selector='' flatten=1 ";
            $scenario .= "W2A::ParseMalt model=$dir/parsed/malt_stackeager.mco ";
        }
        $scenario .= "Eval::AtreeUAS selector='' ";
        print STDERR "Creating script for parsing ($name).\n";
        open (BASHSCRIPT, ">:utf8", "$name-parse.sh") or die;
        print BASHSCRIPT "#!/bin/bash\n\n";
        print BASHSCRIPT "treex -s $scenario -- $dir/parsed/*.treex >> $dir/parsed/uas.txt";
        close BASHSCRIPT;
        system "qsub -cwd $name-parse.sh";
    }
}
