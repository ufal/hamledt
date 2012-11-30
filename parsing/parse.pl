#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

use lib '/home/zeman/lib';
use dzsys;

my $data_dir = Treex::Core::Config->share_dir()."/data/resources/hamledt";

my ($help, $mcd, $mcdproj, $malt, $maltsmf, $new, $feat, $trans, $wdirroot);
$feat='conll'; # default
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
                 default: $data_dir\${LANGUAGE}/treex/\${TRANSFORMATION}/parsed
                 if --wdir \$WDIR set: \${WDIR}/\${LANGUAGE}/\${TRANSFORMATION}
                 i.e. separately from the unparsed data and possibly from other experiments
    -h,--help  - print this help
";
}

my %transformation;
map {$transformation{$_} = 1} split(/,/, $trans);
# We will be repeatedly changing dir to $wdirroot/something so we need $wdiroot to be absolute path
# so we are able to resurface from the previous working folder.
if ($wdirroot) {
    $wdirroot = dzsys::absolutize_path($wdirroot);
}
my $scriptdir = dzsys::get_script_path();
# Lazy to enumerate all languages?
if (scalar(@ARGV)==1 && $ARGV[0] eq 'all') {
    @ARGV = qw(ar bg bn ca cs da de el en es eu fi grc hi hu it ja la nl pt ro ru sl sv ta te tr);
}

print STDERR ("Going to parse languages: ", join(', ', @ARGV), "\n");
foreach my $language (@ARGV) {
    my $glob = "$data_dir/$language/treex/*";
    my @glob = glob $glob;
    die("No directories found: glob = $glob") unless(@glob);
    foreach my $dir (@glob) {
        # Get the name of the current transformation.
        my $name = $dir;
        $name =~ s/^.+\///;
        # Skip transformations that we do not want to process now.
        next if $trans && !$transformation{$name};
        # Set the path to the folder where the training data and the trained model shall be.
        my $wdir = $wdirroot ? "$wdirroot/$language/$name" : "$dir/parsed";
        if(!-d $wdir) {
            print STDERR ("Directory $wdir not found.\n");
            next;
        }
        # Chdir to the working folder so that all scripts and logs are also created there.
        chdir($wdir) or die("Cannot change to $wdir: $!");
        # Copy test data to the working folder unless it is already there.
        if (!-e "001.treex.gz" || $new) {
            system "cp $dir/test/*.treex.gz .";
            print STDERR "New file created!\n";
        }

        my $tr_style = $name;
        $tr_style =~ s/^trans_//;
        $name = "$language-$name";

        # the following variable indicates whether we are parsing a transformation or pdtstyle/orig file
        my $is_transformation = $name =~ /trans_/ ? 1 : 0;

        my %parser_selector = (mcd => 'mcdnonprojo2', mcdproj => 'mcdprojo2', malt => 'maltnivreeager', maltsmf => 'maltstacklazy');
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
        my %run_parser  = ( mcd => $mcd,   mcdproj => $mcdproj, malt => $malt,  maltsmf => $maltsmf);
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
                my $scenario  = "Util::SetGlobal language=$language selector=$parser_selector{$parser} ";
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
        }
        # Note: the trees in 000_orig should be compared against the original gold tree.
        # However, that tree has the '' selector in 000_orig (while it has the 'orig' selector elsewhere),
        # so we do not select 'orig' here.
        my $eval_scenario = "Util::SetGlobal language=$language ";
        $eval_scenario .= "Eval::AtreeUAS eval_is_member=1 eval_is_shared_modifier=1 selector='' ";
        # We evaluate the transformation against 'before' selector, if they are convertyed back to PDT style
        if ($is_transformation) {
            $eval_scenario .= "Eval::AtreeUAS eval_is_member=1 eval_is_shared_modifier=1 selector='before' ";
        }
        print STDERR "Creating script for parsing.\n";
        open (BASHSCRIPT, ">:utf8", "parse-$name.sh") or die;
        print BASHSCRIPT "#!/bin/bash\n\n";
        # Debugging message: anyone here eating my memory?
        print BASHSCRIPT "hostname -f\n";
        print BASHSCRIPT "top -bn1 | head -20\n";
        foreach my $scenario (@scenarios) {
            print BASHSCRIPT "treex -s $scenario -- *.treex.gz\n";
        }
        print BASHSCRIPT "treex $eval_scenario -- *.treex.gz | tee uas.txt\n";
        close BASHSCRIPT;
        my $memory = '12g';
        my $qsub = "qsub -hard -l mf=$memory -l act_mem_free=$memory -cwd -j yes parse-$name.sh";
        system $qsub;
    }
}
