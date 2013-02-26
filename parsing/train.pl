#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my $share_dir = Treex::Core::Config->share_dir();
my $data_dir = "$share_dir/data/resources/hamledt";
my $mcd_dir  = "$share_dir/installed_tools/parser/mst/0.4.3b";
my $malt_dir = "$share_dir/installed_tools/malt_parser/malt-1.5";
my $script_dir = "/home/marecek/treex/devel/hamledt/parsing";

my ($help, $mcd, $mcdproj, $malt, $maltsmf, $feat, $transformations, $new, $wdirroot);

# defaults
$feat = '_';
$transformations = '000_orig,001_pdtstyle,trans_fMhLsNcBpP,trans_fMhMsNcBpP,trans_fMhRsNcBpP,trans_fPhLsHcHpB,trans_fPhMsHcHpB,trans_fPhRsHcHpB,trans_fShLsNcBpP,trans_fShMsNcBpP,trans_fShRsNcBpP';
$wdirroot = '/net/cluster/TMP/marecek/hamledt_parsing';

GetOptions(
    "help|h"  => \$help,
    "mcd"     => \$mcd,
    "malt"    => \$malt,
    "maltsmf" => \$maltsmf,
    "mcdproj" => \$mcdproj,
    "trans=s" => \$transformations,
    "feat=s"  => \$feat,
    "new"     => \$new,
    "wdir=s"  => \$wdirroot,
);

if ($help || !@ARGV) {
    die "Usage: train.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --mcd      - train McDonald's non-projective MST parser
    --mcdproj  - train McDonald's projective MST parser
    --malt     - train Malt parser
    --maltsmf  - train Malt parser with stack algorithm and morph features
    --new      - recreate training file, don't reuse existing
    --trans    - select transformationis separated by comma. All transformations are run otherwise.
    --feat     - select features conll|iset|_ (_ is default)
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
        system "mkdir -p $wdir";

        # Compress transformation names because qstat only shows 10 characters.
        my $shortname = $trans;
        $shortname =~ s/^trans_/t/;
        $shortname =~ s/^00[01]_//;

        # TODO:
        # my $deprel_attribute = $name =~ /000_orig/ ? 'conll/deprel' : 'afun';
        
        # Chdir to the working folder so that all scripts and logs are also created there.
        chdir($wdir) or die("Cannot change to $wdir: $!");

        # Select the train filename and feature options based on the features used
        my ($trainfilename, $feature_option);
        if ( $feat =~ m/^conll/i ) {
            $trainfilename = 'train-conllfeat.conll';
            $feature_option = 'feat_attribute=conll/feat';
        }
        elsif ( $feat =~ m/^i(nter)?set/i ) {
            $trainfilename = 'train-iset.conll';
            $feature_option = 'feat_attribute=iset';
        }
        else {
            $trainfilename = 'train.conll';
            $feature_option = '';
        }

        # Create training CoNLL file if needed.
        # All deprels are substituted by 'Atr'
        if ($new || !-e $trainfilename) {
            my $command =  "treex -p -j 20 ";
               $command .= "Util::SetGlobal language=$language ";
               $command .= "Util::Eval anode='\$anode->set_attr(\"conll/deprel\", \"Atr\");' ";
               $command .= "Write::CoNLLX $feature_option deprel_attribute=conll/deprel is_member_within_afun=1 is_shared_modifier_within_afun=1 is_coord_conjunction_within_afun=1 ";
               $command .= "-- $ddir/train/*.treex.gz > $trainfilename";
            system $command;
        }

        # Create training data in MST format
        if ($mcd || $mcdproj) {
            system "cat $trainfilename | $script_dir/conll2mst.pl > train.mst\n";
        }

        # Prepare the training script and submit the job to the cluster.
        if ($mcd) {
            my $scriptname = "mcd-$language-$shortname.sh";
            print STDERR "Creating script for training McDonald's non-projective parser ($scriptname).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            print BASHSCRIPT "java -cp $mcd_dir/mstparser.jar:$mcd_dir/lib/trove.jar -Xmx9g mstparser.DependencyParser \\\n";
            print BASHSCRIPT "  train order:2 format:MST decode-type:non-proj train-file:train.mst model-name:mcd_nonproj_o2.model\n";
            close BASHSCRIPT;
            system "qsub -p -100 -hard -l mf=10g -l act_mem_free=10g -cwd -j yes $scriptname";
        }
        if ($mcdproj) {
            my $scriptname = "mcp-$language-$shortname.sh";
            print STDERR "Creating script for training McDonald's projective parser ($scriptname).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            print BASHSCRIPT "java -cp $mcd_dir/mstparser.jar:$mcd_dir/lib/trove.jar -Xmx9g mstparser.DependencyParser \\\n";
            print BASHSCRIPT "  train order:2 format:MST decode-type:proj train-file:train.mst model-name:mcd_proj_o2.model\n";
            close BASHSCRIPT;
            system "qsub -p -100 -hard -l mf=10g -l act_mem_free=10g -cwd -j yes $scriptname";
        }
        if ($malt) {
            my $scriptname = "mlt-$language-$shortname.sh";
            print STDERR "Creating script for training Malt parser ($scriptname).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            # If there is the temporary folder from failed previous runs, erase it or Malt will decline training.
            print BASHSCRIPT "rm -rf malt_nivreeager\n";
            print BASHSCRIPT "java -Xmx15g -jar $malt_dir/malt.jar -i $trainfilename -c malt_nivreeager -a nivreeager -l liblinear -m learn\n";
            close BASHSCRIPT;
            system "qsub -p -100 -hard -l mf=16g -l act_mem_free=16g -cwd -j yes $scriptname";
        }
        if ($maltsmf) {
            my $scriptname = "smf-$language-$shortname.sh";
            print STDERR "Creating script for training Malt parser with stack and morph features ($scriptname).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            # Debugging message: anyone here eating my memory?
            print BASHSCRIPT "hostname -f\n";
            print BASHSCRIPT "echo jednou | /net/projects/SGE/sensors/mem_free.sh\n";
            print BASHSCRIPT "echo jednou | /net/projects/SGE/sensors/act_mem_free.sh\n";
            print BASHSCRIPT "top -bn1 | head -20\n";
            # If there is the temporary folder from failed previous runs, erase it or Malt will decline training.
            print BASHSCRIPT "rm -rf malt_stacklazy\n";
            my $features = '/net/work/people/zeman/parsing/malt-parser/marco-kuhlmann-czech-settings/CzechNonProj-JOHAN-NEW-MODIFIED.xml';
            my $command = "java -Xmx29g -jar $malt_dir/malt.jar -i $trainfilename -c malt_stacklazy -a stacklazy -F $features -grl Pred -d POSTAG -s 'Stack[0]' -T 1000 -gds T.TRANS,A.DEPREL -l libsvm -m learn\n";
            print BASHSCRIPT "echo $command";
            print BASHSCRIPT $command;
            close BASHSCRIPT;
            my $memory = '31g';
            system "qsub -p -100 -hard -l mf=$memory -l act_mem_free=$memory -cwd -j yes $scriptname";
        }
    }
}
