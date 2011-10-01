#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks";

my ($help, $mcd, $mcdproj, $malt, $maltsmf, $new, $feat, $trans, $topdt);
$feat='_'; # default
$trans = '';
$mcd=0;
$malt=0;
$mcdproj=0;
$maltsmf=0;


GetOptions(
    "help|h"  => \$help,
    "mcd"     => \$mcd,
    "mcdproj" => \$mcdproj,
    "malt"    => \$malt,
    "maltsmf" => \$maltsmf,
    "new"     => \$new,
    "trans=s"   => \$trans,
    "feat=s"  => \$feat,
    "topdt"   => \$topdt,
);

if ($help || !@ARGV) {
    die "Usage: parse.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --mcd      - run McDonald's MST non-projective parser
    --mcdproj  - run McDonald's MST projective parser
    --malt     - run Malt parser
    --maltsmf  - run Malt parser with stack algorithm and morph features
    --new      - copy the testing file from 'test' directory
    --trans    - select transformationis separated by comma. All transformations are run otherwise.
    --feat     - select features conll|iset|_ (_ is default)
    --topdt    - transform the resulting trees to PDT style
    -h,--help  - print this help
";
}

die "Can't run more than one parser" if ($mcd && $mcdproj) || ($malt && $maltsmf);

my %transformation;
map {$transformation{$_} = 1} split(/,/, $trans);

print STDERR ("Going to parse languages: ", join(', ', @ARGV), "\n");
foreach my $language (@ARGV) {
    my $glob = "$data_dir/$language/treex/*";
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
            print STDERR "New file created!\n";
        }
        my $name = $dir;
        $name =~ s/^.+\///;

        next if $trans && !$transformation{$name};
        
        $name = "$language-$name";

        # the following variable indicates whether we are parsing a transformation or pdtstyle/orig file
        my $is_transformation = $name =~ /trans_/ ? 1 : 0;

        my %parser_selector = (mcd => 'mcdnonprojo2', mcdproj => 'mcdprojo2', malt => 'maltnivreeager', maltsmf => 'maltstacklazy');
        my %parser_model = (
            mcd     => "$dir/parsed/mcd_nonproj_o2.model",
            mcdproj => "$dir/parsed/mcd_proj_o2.model",
            malt    => "$dir/parsed/malt_nivreeager.mco",
            maltsmf => "$dir/parsed/malt_stacklazy.mco",
        );
        my %parser_block = (
            mcd     => "W2A::ParseMST model=$dir/parsed/mcd_nonproj_o2.model decodetype=non-proj pos_attribute=conll/pos",
            mcdproj => "W2A::ParseMST model=$dir/parsed/mcd_proj_o2.model decodetype=proj pos_attribute=conll/pos",
            malt    => "W2A::ParseMalt model=$dir/parsed/malt_nivreeager.mco pos_attribute=conll/pos cpos_attribute=conll/cpos",
            maltsmf => "W2A::ParseMalt model=$dir/parsed/malt_stacklazy.mco pos_attribute=conll/pos cpos_attribute=conll/cpos feat_attribute=$feat",
        );
        my %parser_name = ( mcd => '-mcd', mcdproj => '-mcp', malt => '-mlt', maltsmf => '-smf');

        my $parser = $mcd ? 'mcd' : $mcdproj ? 'mcdproj' : $maltsmf ? 'maltsmf' : $malt ? 'malt' : '';
        exit if !$parser;
        if (-e $parser_model{$parser}) {
            $name .= $parser_name{$parser};
            my $scenario  = "Util::SetGlobal language=$language selector=$parser_selector{$parser} ";
               $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' ";
               $scenario .= "A2A::CopyAtree source_selector='' flatten=1 ";
               $scenario .= "$parser_block{$parser} ";
            if ($is_transformation) {
#                $scenario .= "Util::SetGlobal language=$language selector=$parser_selector{$parser}PDT ";
#                $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' " ;
#                $scenario .= "A2A::CopyAtree source_selector=$parser_selector{$parser} ";
#                $scenario .= "A2A::Transform::Coord_fPhRsHcHpB ";
            }
            # Note: the trees in 000_orig should be compared against the original gold tree.
            # However, that tree has the '' selector in 000_orig (while it has the 'orig' selector elsewhere),
            # so we do not select 'orig' here.
            my $selector_for_comparison = $is_transformation && $topdt ? 'before' : '';
            $scenario .= "Eval::AtreeUAS eval_is_member=1 eval_is_shared_modifier=1 selector='$selector_for_comparison' ";

            my $uas_file = $topdt ? 'uas-pdt.txt' : 'uas.txt';

            print STDERR "Creating script for parsing ($name).\n";
            open (BASHSCRIPT, ">:utf8", "parse-$name.sh") or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            # Debugging message: anyone here eating my memory?
            print BASHSCRIPT "hostname -f\n";
            print BASHSCRIPT "top -bn1 | head -20\n";
            print BASHSCRIPT "treex -s $scenario -- $dir/parsed/*.treex.gz | tee $dir/parsed/$uas_file\n";
            close BASHSCRIPT;
            my $memory = '12g';
            my $qsub = "qsub -hard -l mf=$memory -l act_mem_free=$memory -cwd -j yes parse-$name.sh";
            #print STDERR ("$qsub\n");
            system $qsub;
        }
        else {
            print STDERR ("Model for $parser parser not found.\n");
        }
    }
}
