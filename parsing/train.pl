#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;
use File::stat;

my $share_dir = Treex::Core::Config->share_dir();
my $data_dir = "$share_dir/data/resources/hamledt";
my $mcd_dir  = "$share_dir/installed_tools/parser/mst/0.4.3b";
my $malt_dir = "$share_dir/installed_tools/malt_parser/malt-1.5";
my $script_dir = "/home/marecek/treex/devel/hamledt/parsing";

my ($help, $mcd, $mcdproj, $malt, $maltsmf, $maltsmfndr, $feat, $transformations, $new, $wdirroot, $retrain);

# defaults
$feat = '_';
$transformations = '000_orig,001_pdtstyle,trans_fMhLsNcBpP,trans_fMhMsNcBpP,trans_fMhRsNcBpP,trans_fPhLsHcHpB,trans_fPhMsHcHpB,trans_fPhRsHcHpB,trans_fShLsNcBpP,trans_fShMsNcBpP,trans_fShRsNcBpP';
$wdirroot = '/net/cluster/TMP/marecek/hamledt_parsing';

GetOptions(
    "help|h"  => \$help,
    "mcd"     => \$mcd,
    "malt"    => \$malt,
    "maltsmf" => \$maltsmf,
    "maltsmfndr" => \$maltsmfndr,
    "mcdproj" => \$mcdproj,
    "trans=s" => \$transformations,
    "feat=s"  => \$feat,
    "newdata" => \$new,
    "retrain" => \$retrain,
    "wdir=s"  => \$wdirroot,
);

if ($help || !@ARGV) {
    die "Usage: train.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --mcd      - train McDonald's non-projective MST parser
    --mcdproj  - train McDonald's projective MST parser
    --malt     - train Malt parser
    --maltsmf  - train Malt parser with stack algorithm and morph features
    --maltsmfndr  - train Malt parser with stack algorithm and morph features, but without dependency relations
    --newdata  - recreate training file, don't reuse existing
    --retrain  - retrain already existing models
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
        my ($trainfilename, $trainfilename_nodeprels, $feature_option);
        if ( $feat =~ m/^i(nter)?set/i ) {
            $trainfilename = 'train-iset.conll';
            $trainfilename_nodeprels = 'train-iset-nodeprels.conll';
            $feature_option = 'feat_attribute=iset';
        }
        else {
            $trainfilename = 'train-conllfeat.conll';
            $trainfilename_nodeprels = 'train-conllfeat-nodeprels.conll';
            $feature_option = 'feat_attribute=conll/feat';
        }
        my $deprel_attribute = $trans eq "000_orig" ? "conll/deprel" : "afun";

        my $train_file_was_altered = 0;
        # Create training CoNLL file if needed.
        if ($new || !-s "$wdir/$trainfilename" || stat("$ddir/train/001.treex.gz")->mtime > stat("$wdir/$trainfilename")->mtime) {
            $train_file_was_altered = 1;
            my $command =  "treex -p -j 20 ";
               $command .= "Util::SetGlobal language=$language ";
               #if ($language eq 'cs') { $command .= "Util::Eval anode='my \$d=\$anode->get_attr(\"conll/deprel\"); \$d =~ s/_M//; \$anode->set_attr(\"conll/deprel\", \$d)' "; }
               $command .= "Write::CoNLLX $feature_option deprel_attribute=$deprel_attribute is_member_within_afun=1 is_shared_modifier_within_afun=1 is_coord_conjunction_within_afun=1 ";
               $command .= "-- $ddir/train/*.treex.gz > $trainfilename";
            system $command;
            # Create a version without dependency relations
            system "cat $trainfilename | $script_dir/remove_deprels.pl > $trainfilename_nodeprels";
        }

        # Create training data in MST format
        if (($mcd || $mcdproj) && ($new || !-s "$wdir/train.mst")) {
            system "cat $trainfilename_nodeprels | $script_dir/conll2mst.pl > train.mst\n";
        }

        # Prepare the training script and submit the job to the cluster.
        if ($mcd && ($retrain || $train_file_was_altered || !-e "$wdir/mcd_nonproj_o2.model")) {
            my $scriptname = "mcd-$language-$shortname.sh";
            print STDERR "Creating script for training McDonald's non-projective parser ($scriptname).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            print BASHSCRIPT "java -cp $mcd_dir/mstparser.jar:$mcd_dir/lib/trove.jar -Xmx9g mstparser.DependencyParser \\\n";
            print BASHSCRIPT "  train order:2 format:MST decode-type:non-proj train-file:train.mst model-name:mcd_nonproj_o2.model\n";
            close BASHSCRIPT;
            system "qsub -p -100 -hard -l mf=10g -l act_mem_free=10g -cwd -j yes $scriptname";
        }
        if ($mcdproj && ($retrain || $train_file_was_altered || !-e "$wdir/mcd_proj_o2.model")) {
            my $scriptname = "mcp-$language-$shortname.sh";
            print STDERR "Creating script for training McDonald's projective parser ($scriptname).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            print BASHSCRIPT "java -cp $mcd_dir/mstparser.jar:$mcd_dir/lib/trove.jar -Xmx9g mstparser.DependencyParser \\\n";
            print BASHSCRIPT "  train order:2 format:MST decode-type:proj train-file:train.mst model-name:mcd_proj_o2.model\n";
            close BASHSCRIPT;
            system "qsub -p -100 -hard -l mf=10g -l act_mem_free=10g -cwd -j yes $scriptname";
        }
        if ($malt && ($retrain || $train_file_was_altered || !-e "$wdir/malt_nivreeager.mco" || -s "$wdir/malt_nivreeager.mco" < 10000)) {
            my $scriptname = "mlt-$language-$shortname.sh";
            print STDERR "Creating script for training Malt parser ($scriptname).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            # If there is the temporary folder from failed previous runs, erase it or Malt will decline training.
            print BASHSCRIPT "rm -rf malt_nivreeager\n";
            print BASHSCRIPT "java -Xmx15g -jar $malt_dir/malt.jar -i $trainfilename_nodeprels -c malt_nivreeager -a nivreeager -l liblinear -m learn\n";
            close BASHSCRIPT;
            system "qsub -p -100 -hard -l mf=16g -l act_mem_free=16g -cwd -j yes $scriptname";
        }
        if ($maltsmf && ($retrain || $train_file_was_altered || !-e "$wdir/malt_stacklazy.mco" || -s "$wdir/malt_stacklazy.mco" < 10000)) {
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
        if ($maltsmfndr && ($retrain || $train_file_was_altered || !-e "$wdir/malt_stacklazy_ndr.mco" || -s "$wdir/malt_stacklazy_ndr.mco" < 10000)) {
            my $scriptname = "ndr-$language-$shortname.sh";
            print STDERR "Creating script for training Malt parser with stack and morph features ($scriptname).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            # Debugging message: anyone here eating my memory?
            print BASHSCRIPT "hostname -f\n";
            print BASHSCRIPT "echo jednou | /net/projects/SGE/sensors/mem_free.sh\n";
            print BASHSCRIPT "echo jednou | /net/projects/SGE/sensors/act_mem_free.sh\n";
            print BASHSCRIPT "top -bn1 | head -20\n";
            # If there is the temporary folder from failed previous runs, erase it or Malt will decline training.
            print BASHSCRIPT "rm -rf malt_stacklazy_ndr\n";
            my $features = '/net/work/people/zeman/parsing/malt-parser/marco-kuhlmann-czech-settings/CzechNonProj-JOHAN-NEW-MODIFIED.xml';
            my $command = "java -Xmx29g -jar $malt_dir/malt.jar -i $trainfilename_nodeprels -c malt_stacklazy_ndr -a stacklazy -F $features -grl Pred -d POSTAG -s 'Stack[0]' -T 1000 -gds T.TRANS,A.DEPREL -l libsvm -m learn\n";
            print BASHSCRIPT "echo $command";
            print BASHSCRIPT $command;
            close BASHSCRIPT;
            my $memory = '31g';
            system "qsub -p -100 -hard -l mf=$memory -l act_mem_free=$memory -cwd -j yes $scriptname";
        }
    }
}
