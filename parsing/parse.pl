#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";

my ($help, $mcd, $mcdproj, $malt, $maltsmf, $new, $feat, $trans);
$feat='_'; # default

GetOptions(
    "help|h"  => \$help,
    "mcd"     => \$mcd,
    "mcdproj" => \$mcdproj,
    "malt"    => \$malt,
    "maltsmf" => \$maltsmf,
    "new"     => \$new,
    "trans=s"   => \$trans,
    "feat=s"  => \$feat,
);

if ($help || !@ARGV) {
    die "Usage: parse.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --mcd      - run McDonald's MST non-projective parser
    --mcdproj  - run McDonald's MST projective parser
    --malt     - run Malt parser
    --maltsmf  - run Malt parser with stack algorithm and morph features
    --new      - copy the testing file from 'test' directory
    --trans    - select transformation, all transformations are run otherwise
    --feat     - select features conll|iset|_ (_ is default)
    -h,--help  - print this help
";
}

foreach my $language (@ARGV) {
    my $glob = $trans ? "$data_dir/$language/treex/$trans" : "$data_dir/$language/treex/*";
    foreach my $dir (glob $glob) {
        next if (!-d $dir);
        if (!-e "$dir/parsed/001.treex.gz" || $new) {
            system "cp $dir/test/*.treex.gz $dir/parsed/";
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
        if ($malt && -e "$dir/parsed/malt_nivreeager.mco") {
            $scenario .= "Util::SetGlobal language=$language selector=maltnivreeager ";
            $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' " ;
            $scenario .= "A2A::CopyAtree source_selector='' flatten=1 ";
            $scenario .= "W2A::ParseMalt model=$dir/parsed/malt_nivreeager.mco pos_attribute=conll/pos cpos_attribute=conll/cpos ";
        }
        if ($maltsmf) {
            my $model = "$dir/parsed/malt_stacklazy.mco";
            if (-e $model) {
                $scenario .= "Util::SetGlobal language=$language selector=maltstacklazy ";
                $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' " ;
                $scenario .= "A2A::CopyAtree source_selector='' flatten=1 ";
                $scenario .= "W2A::ParseMalt model=$model pos_attribute=conll/pos cpos_attribute=conll/cpos feat_attribute=$feat ";
            } else {
                print STDERR ("MaltSMF parser required but model $model not found.\n");
                next;
            }
        }
        $scenario .= "Eval::AtreeUAS selector='' ";
        print STDERR "Creating script for parsing ($name).\n";
        open (BASHSCRIPT, ">:utf8", "parse-$name.sh") or die;
        print BASHSCRIPT "#!/bin/bash\n\n";
        print BASHSCRIPT "treex -s $scenario -- $dir/parsed/*.treex.gz > $dir/parsed/uas.txt";
        close BASHSCRIPT;
        system "qsub -q \'*\@t*,*\@f*,*\@o*,*\@c*,*\@a*,*\@h*\' -l mf=5g -cwd parse-$name.sh";
    }
}
