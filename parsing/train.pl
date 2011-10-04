#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

use lib '/home/zeman/lib';
use dzsys;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks";
my $mcd_dir  = $ENV{TMT_ROOT}."/libs/other/Parser/MST/mstparser-0.4.3b";
my $malt_dir = $ENV{TMT_ROOT}."/share/installed_tools/malt_parser/malt-1.5";

my ($help, $mcd, $mcdproj, $malt, $maltsmf, $feat, $trans, $new, $wdirroot);
$feat = '_'; # default
$trans = '';

GetOptions(
    "help|h"  => \$help,
    "mcd"     => \$mcd,
    "malt"    => \$malt,
    "maltsmf" => \$maltsmf,
    "mcdproj" => \$mcdproj,
    "trans=s" => \$trans,
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
    @ARGV = qw(ar bg bn cs da de el en es eu fi grc hi hu it ja la nl pt ro ru sl sv ta te tr);
}

foreach my $language (@ARGV) {
    foreach my $dir (glob "$data_dir/$language/treex/*") {
        next if (!-d $dir);
        # Get the name of the current transformation.
        my $name = $dir;
        $name =~ s/^.+\///;
        # Skip transformations that we do not want to process now.
        next if $trans && !$transformation{$name};
        # Set the path to the folder where the training data and the trained model shall be created.
        my $wdir = $wdirroot ? "$wdirroot/$language/$name" : "$dir/parsed";
        # Create the folder unless it already exists.
        dzsys::saferun("mkdir -p $wdir") or die;
        # Get the name of the job based on language and transformation.
        # Compress transformation names because qstat only shows 10 characters.
        $name =~ s/^trans_/t/;
        $name = "$language-$name";
        my $deprel_attribute = $name =~ /000_orig/ ? 'conll/deprel' : 'afun';
        # Send error messages to /dev/null because it is quite probable that there are files
        # that we do not own and thus cannot change their permissions although we have write access to them.
        # Change permissions only for the shared folder, i.e. not if $wdirroot has been specified.
        system "chmod -R g+wx $wdir 2>/dev/null" unless($wdirroot);
        # Chdir to the working folder so that all scripts and logs are also created there.
        chdir($wdir) or die("Cannot change to $wdir: $!");
        my ($trainfilename, $f);
        if ( $feat =~ m/^conll/i ) {
            $trainfilename = 'train-conllfeat.conll';
            $f = 'feat_attribute=conll/feat';
        } elsif ( $feat =~ m/^i(nter)?set/i ) {
            $trainfilename = 'train-iset.conll';
            $f = 'feat_attribute=iset';
        } else {
            $trainfilename = 'train.conll';
            $f = '';
        }
        # create training CoNLL file if needed.
        # all afuns but 'Coord', 'AuxX', and 'AuxY' are substituted by 'Atr' 
        if ($new || !-e $trainfilename) {
            my $command =  "treex -p -j 20 ";
               $command .= "Util::SetGlobal language=$language ";
               $command .= "Util::Eval anode='\$anode->set_attr(\"$deprel_attribute\", \"Atr\");' ";
               $command .= "Write::CoNLLX $f deprel_attribute=$deprel_attribute is_member_within_afun=1 is_shared_modifier_within_afun=1 is_coord_conjunction_within_afun=1 ";
               $command .= "-- $dir/train/*.treex.gz > $trainfilename";
            system $command;
        }
        if ($mcd || $mcdproj) {
            system "cat $trainfilename | $scriptdir/conll2mst.pl > train.mst\n";
        }
        # Prepare the training script and submit the job to the cluster.
        if ($mcd) {
            my $scriptname = "mcd-$name.sh";
            print STDERR "Creating script for training McDonald's non-projective parser ($name).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            print BASHSCRIPT "java -cp $mcd_dir/output/mstparser.jar:$mcd_dir/lib/trove.jar -Xmx9g mstparser.DependencyParser \\\n";
            print BASHSCRIPT "  train order:2 format:MST decode-type:non-proj train-file:train.mst model-name:mcd_nonproj_o2.model\n";
            close BASHSCRIPT;
            system "qsub -hard -l mf=10g -l act_mem_free=10g -cwd -j yes $scriptname";
        }
        if ($mcdproj) {
            my $scriptname = "mcp-$name.sh";
            print STDERR "Creating script for training McDonald's projective parser ($name).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            print BASHSCRIPT "java -cp $mcd_dir/output/mstparser.jar:$mcd_dir/lib/trove.jar -Xmx9g mstparser.DependencyParser \\\n";
            print BASHSCRIPT "  train order:2 format:MST decode-type:proj train-file:train.mst model-name:mcd_proj_o2.model\n";
            close BASHSCRIPT;
            system "qsub -hard -l mf=10g -l act_mem_free=10g -cwd -j yes $scriptname";
        }
        if ($malt) {
            my $scriptname = "mlt-$name.sh";
            print STDERR "Creating script for training Malt parser ($name).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
#            print BASHSCRIPT "cd $wdir\n";
            # If there is the temporary folder from failed previous runs, erase it or Malt will decline training.
            print BASHSCRIPT "rm -rf malt_nivreeager\n";
            print BASHSCRIPT "java -Xmx15g -jar $malt_dir/malt.jar -i $trainfilename -c malt_nivreeager -a nivreeager -l liblinear -m learn\n";
            close BASHSCRIPT;
            system "qsub -hard -l mf=16g -l act_mem_free=16g -cwd -j yes $scriptname";
        }
        if ($maltsmf) {
            my $scriptname = "smf-$name.sh";
            print STDERR "Creating script for training Malt parser with stack and morph features ($name).\n";
            open (BASHSCRIPT, ">:utf8", $scriptname) or die;
            print BASHSCRIPT "#!/bin/bash\n\n";
            # Debugging message: anyone here eating my memory?
            print BASHSCRIPT "hostname -f\n";
            print BASHSCRIPT "top -bn1 | head -20\n";
#            print BASHSCRIPT "cd $wdir\n";
            # If there is the temporary folder from failed previous runs, erase it or Malt will decline training.
            print BASHSCRIPT "rm -rf malt_stacklazy\n";
            my $features = '/net/work/people/zeman/parsing/malt-parser/marco-kuhlmann-czech-settings/CzechNonProj-JOHAN-NEW-MODIFIED.xml';
            my $command = "java -Xmx29g -jar $malt_dir/malt.jar -i $trainfilename -c malt_stacklazy -a stacklazy -F $features -grl Pred -d POSTAG -s 'Stack[0]' -T 1000 -gds T.TRANS,A.DEPREL -l libsvm -m learn\n";
            print BASHSCRIPT "echo $command";
            print BASHSCRIPT $command;
            close BASHSCRIPT;
            my $memory = '31g';
            system "qsub -hard -l mf=$memory -l act_mem_free=$memory -cwd -j yes $scriptname";
        }
    }
}
