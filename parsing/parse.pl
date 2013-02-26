#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my $share_dir = Treex::Core::Config->share_dir();
my $data_dir = "$share_dir/data/resources/hamledt";
my $script_dir = "/home/marecek/treex/devel/hamledt/parsing";

my ($help, $mcd, $mcdproj, $malt, $maltsmf, $feat, $transformations, $new, $wdirroot);

# defaults
$feat = '_';
$transformations = '000_orig,001_pdtstyle,trans_fMhLsNcBpP,trans_fMhMsNcBpP,trans_fMhRsNcBpP,trans_fPhLsHcHpB,trans_fPhMsHcHpB,trans_fPhRsHcHpB,trans_fShLsNcBpP,trans_fShMsNcBpP,trans_fShRsNcBpP';
$wdirroot = '/net/cluster/TMP/marecek/hamledt_parsing';
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
    "trans=s"   => \$transformations,
    "feat=s"  => \$feat,
    "wdir=s"  => \$wdirroot,
);

if ($help || !@ARGV) {
    die "Usage: parse.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --mcd      - run McDonald's MST non-projective parser
    --mcdproj  - run McDonald's MST projective parser
    --malt     - run Malt parser
    --maltsmf  - run Malt parser with stack algorithm and morph features
    --new      - copy the testing file from 'test' directory
    --trans    - select transformations separated by comma. All transformations are run otherwise.
    --feat     - select features conll|iset|_ (conll is default)
    --wdir     - path to working folder
    -h,--help  - print this help
";
}

foreach my $language (@ARGV) {

    foreach my $trans ( split(/,/, $transformations)) {

        # From where the data will be taken
        my $ddir = "$data_dir/$language/treex/$trans";
        next if (!-d $ddir);

        # Where the data will be written
        my $wdir = "$wdirroot/$language/$trans";
        next if (!-d $wdir);

        # Compress transformation names because qstat only shows 10 characters.
        my $shortname = $trans;
        $shortname =~ s/^trans_/t/;
        $shortname =~ s/^00[01]_//;
        my $tr_style = $trans =~ /^trans_/ ? $trans : '';
        $tr_style =~ s/^trans_//;

        # Chdir to the working folder so that all scripts and logs are also created there.
        chdir($wdir) or die("Cannot change to $wdir: $!");

        # Copy test data to the working folder unless it is already there.
        if (!-e "001.treex.gz" || $new) {
            system "cp $ddir/test/*.treex.gz .";
            print STDERR "New file created!\n";
        }

        # the following variable indicates whether we are parsing a transformation or pdtstyle/orig file
        my $is_transformation = $trans =~ /trans_/ ? 1 : 0;

        my %parser_selector = (mcd => 'mcd', mcdproj => 'mcdproj', malt => 'malt', maltsmf => 'maltsmf');
        my %parser_model = (
            mcd     => "$wdir/mcd_nonproj_o2.model",
            mcdproj => "$wdir/mcd_proj_o2.model",
            malt    => "$wdir/malt_nivreeager.mco",
            maltsmf => "$wdir/malt_stacklazy.mco",
        );
        my %parser_block = (
            mcd     => "W2A::ParseMST model_dir=$wdir model=mcd_nonproj_o2.model decodetype=non-proj pos_attribute=conll/pos",
            mcdproj => "W2A::ParseMST model_dir=$wdir model=mcd_proj_o2.model decodetype=proj pos_attribute=conll/pos",
            malt    => "W2A::ParseMalt model=$wdir/malt_nivreeager.mco pos_attribute=conll/pos cpos_attribute=conll/cpos",
            maltsmf => "W2A::ParseMalt model=$wdir/malt_stacklazy.mco pos_attribute=conll/pos cpos_attribute=conll/cpos feat_attribute=$feat",
        );
        my %base_parser_block = (
            mcd     => "W2A::ParseMST model_dir=$wdir/../001_pdtstyle model=mcd_nonproj_o2.model decodetype=non-proj pos_attribute=conll/pos",
            mcdproj => "W2A::ParseMST model_dir=$wdir/../001_pdtstyle model=mcd_proj_o2.model decodetype=proj pos_attribute=conll/pos",
            malt    => "W2A::ParseMalt model=$wdir/../001_pdtstyle/malt_nivreeager.mco pos_attribute=conll/pos cpos_attribute=conll/cpos",
            maltsmf => "W2A::ParseMalt model=$wdir/../001_pdtstyle/malt_stacklazy.mco pos_attribute=conll/pos cpos_attribute=conll/cpos feat_attribute=$feat",
        );
        my %run_parser = ( mcd => $mcd, mcdproj => $mcdproj, malt => $malt, maltsmf => $maltsmf);

        my @scenarios;
        foreach my $parser (qw(mcd mcdproj malt maltsmf)) {
            if (!$run_parser{$parser}) {
                next;
            }
            elsif (!-e $parser_model{$parser}) {
                print STDERR ("Model for $parser parser not found.\n");
                next;
            }
            else {
                my $scenario = "Util::SetGlobal language=$language selector=$parser_selector{$parser} ";
                $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' ";
                $scenario .= "A2A::CopyAtree source_selector='' flatten=1 ";
                $scenario .= "$parser_block{$parser} ";
                if ($is_transformation) {
                    $scenario .= "Util::SetGlobal language=$language selector=$parser_selector{$parser}PDT ";
                    $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' " ;
                    $scenario .= "A2A::CopyAtree source_selector=$parser_selector{$parser} ";
                    $scenario .= "A2A::Transform::CoordStyle from_style=$tr_style style=fPhRsHcHpB ";
                }
                push @scenarios, $scenario;
            }
            my $base_scenario  = "Util::SetGlobal language=$language selector=$parser_selector{$parser}BASE ";
            $base_scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' ";
            $base_scenario .= "A2A::CopyAtree source_selector='' flatten=1 ";
            $base_scenario .= "$base_parser_block{$parser} ";
            push @scenarios, $base_scenario;
        }

        # Evaluation
        my $eval_scenario = "Util::SetGlobal language=$language ";
        $eval_scenario .= "Eval::AtreeUAS eval_is_member=1 eval_is_shared_modifier=1 selector='' ";
        
        # We evaluate the transformation against 'before' selector as well (for trees converted back to PDT style)
        if ($is_transformation) {
            $eval_scenario .= "Eval::AtreeUAS eval_is_member=1 eval_is_shared_modifier=1 selector='before' ";
        }

        print STDERR "Creating script for parsing.\n";
        open (BASHSCRIPT, ">:utf8", "p-$language-$shortname.sh") or die;
        print BASHSCRIPT "#!/bin/bash\n\n";
        # Debugging message: anyone here eating my memory?
        print BASHSCRIPT "hostname -f\n";
        print BASHSCRIPT "top -bn1 | head -20\n";
        foreach my $scenario (@scenarios) {
            print BASHSCRIPT "treex -s $scenario -- *.treex.gz\n";
        }
        print BASHSCRIPT "treex $eval_scenario -- *.treex.gz | tee uas.txt\n";
        close BASHSCRIPT;
        my $memory = '15g';
        system "qsub -hard -l mf=$memory -l act_mem_free=$memory -cwd -j yes p-$language-$shortname.sh";
    }
}
