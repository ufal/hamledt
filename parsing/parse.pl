#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks";

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

die "Can't run two different models of one parser in the same scenario" if ($mcd && $mcdproj) || ($malt && $maltsmf);

print STDERR ("Going to parse languages: ", join(', ', @ARGV), "\n");
foreach my $language (@ARGV) {
    my $glob = $trans ? "$data_dir/$language/treex/$trans" : "$data_dir/$language/treex/*";
    my @glob = glob $glob;
    die("No directories found: glob = $glob") unless(@glob);
    foreach my $dir (@glob) {
        if(!-d $dir)
        {
            print STDERR ("Directory $dir not found.\n");
            next;
        }
        if (!-e "$dir/parsed/001.treex.gz" || $new) {
            system "cp $dir/test/*.treex.gz $dir/parsed/";
        }
        my $name = $dir;
        $name =~ s/^.+\///;
        $name = "$language-$name";

        # the following variable indicates whether we are parsing a transformation or pdtstyle/orig file
        my $is_transformation = $name =~ /trans_/ ? 1 : 0;

        my $scenario;
        if ($mcd) {
            my $model = "$dir/parsed/mcd_nonproj_o2.model";
            if (-e $model) {
                # Just in case each parser is invoked separately add the parser name(s) to the script name.
                # Otherwise we could damage a script for the other parsers currently being run.
                $name .= '-mcd';
                $scenario .= "Util::SetGlobal language=$language selector=mcdnonprojo2 ";
                $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' " ;
                $scenario .= "A2A::CopyAtree source_selector='' flatten=1 ";
                $scenario .= "W2A::ParseMST model=$model decodetype=non-proj pos_attribute=conll/pos ";
                $scenario .= "A2A::Transform::Coord_fPhRsHcHpB " if $is_transformation;
            } else {
                print STDERR ("MST nonprojective parser required but model $model not found.\n");
            }
        }
        if ($mcdproj) {
            my $model = "$dir/parsed/mcd_proj_o2.model";
            if (-e $model) {
                # Just in case each parser is invoked separately add the parser name(s) to the script name.
                # Otherwise we could damage a script for the other parsers currently being run.
                $name .= '-mcp';
                $scenario .= "Util::SetGlobal language=$language selector=mcdprojo2 ";
                $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' " ;
                $scenario .= "A2A::CopyAtree source_selector='' flatten=1 ";
                $scenario .= "W2A::ParseMST model=$model decodetype=proj pos_attribute=conll/pos ";
                $scenario .= "A2A::Transform::Coord_fPhRsHcHpB " if $is_transformation;
            } else {
                print STDERR ("MST projective parser required but model $model not found.\n");
            }
        }
        if ($malt) {
            my $model = "$dir/parsed/malt_nivreeager.mco";
            if (-e $model) {
                # Just in case each parser is invoked separately add the parser name(s) to the script name.
                # Otherwise we could damage a script for the other parsers currently being run.
                $name .= '-mlt';
                $scenario .= "Util::SetGlobal language=$language selector=maltnivreeager ";
                $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' " ;
                $scenario .= "A2A::CopyAtree source_selector='' flatten=1 ";
                $scenario .= "W2A::ParseMalt model=$model pos_attribute=conll/pos cpos_attribute=conll/cpos ";
                $scenario .= "A2A::Transform::Coord_fPhRsHcHpB " if $is_transformation;
            } else {
                print STDERR ("Malt parser required but model $model not found.\n");
            }
        }
        if ($maltsmf) {
            my $model = "$dir/parsed/malt_stacklazy.mco";
            if (-e $model) {
                # Just in case each parser is invoked separately add the parser name(s) to the script name.
                # Otherwise we could damage a script for the other parsers currently being run.
                $name .= '-smf';
                $scenario .= "Util::SetGlobal language=$language selector=maltstacklazy ";
                $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' " ;
                $scenario .= "A2A::CopyAtree source_selector='' flatten=1 ";
                $scenario .= "W2A::ParseMalt model=$model pos_attribute=conll/pos cpos_attribute=conll/cpos feat_attribute=$feat ";
                $scenario .= "A2A::Transform::Coord_fPhRsHcHpB " if $is_transformation;
            } else {
                print STDERR ("MaltSMF parser required but model $model not found.\n");
            }
        }
        if ($scenario) {
            # Note: the trees in 000_orig should be compared against the original gold tree.
            # However, that tree has the '' selector in 000_orig (while it has the 'orig' selector elsewhere),
            # so we do not select 'orig' here.
            my $selector_for_comparison = $is_transformation ? 'before' : '';
            $scenario .= "Eval::AtreeUAS eval_is_member=1 selector='$selector_for_comparison' ";

            print STDERR "Creating script for parsing ($name).\n";
            open (BASHSCRIPT, ">:utf8", "parse-$name.sh") or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            print BASHSCRIPT "treex -s $scenario -- $dir/parsed/*.treex.gz | tee $dir/parsed/uas.txt\n";
            close BASHSCRIPT;
            my $qsub = "qsub -q \'*\@t*,*\@f*,*\@o*,*\@c*,*\@a*,*\@h*\' -l mf=10g -cwd -j yes parse-$name.sh";
            #print STDERR ("$qsub\n");
            system $qsub;
        } else {
            print STDERR ("Nothing to do in $dir!\n");
        }
    }
}
