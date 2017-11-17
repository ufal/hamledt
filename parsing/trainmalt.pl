#!/usr/bin/env perl
# Creates a cluster job to train a parsing model on a given file using Malt parser.
# Copyright © 2011-2017 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Getopt::Long;
use Treex::Core::Config;
use Text::Table;
use Time::Piece; # localtime()->ymd();
use lib '/home/zeman/lib';
use dzsys;
use cluster;

if(scalar(@ARGV)!=1)
{
    die("Expecting one argument: the name of the training data file");
}
my $treebank = dzsys::absolutize_path($ARGV[0]);
if(! -f $treebank)
{
    die("Cannot find $treebank");
}
my $wdir = $treebank;
$wdir =~ s:/([^/]+)$::g;
$treebank = $1;
print STDERR ("Working folder = $wdir\n");
chdir($wdir) or die("Cannot enter $wdir: $!");
train($treebank);



#------------------------------------------------------------------------------
# Creates a training job and submits it to the cluster.
#------------------------------------------------------------------------------
sub train
{
    my $data = shift; # name of the training file without path (we are currently in the working folder where the file must be)
    my $tbkcode = $data;
    $tbkcode =~ s/\.conll$//;
    $tbkcode =~ s/-train$//;
    $tbkcode =~ s/-ud$//;
    my $malt_jar = '/home/zeman/nastroje/parsery/maltparser-1.8.1/maltparser-1.8.1.jar';
    # Prepare the training script and submit the job to the cluster.
    my $scriptname = "$tbkcode-train-malt.sh";
    my ($memory, $priority);
    print STDERR ("Creating script $scriptname.\n");
    open(SCR, ">$scriptname") or die("Cannot write $scriptname: $!\n");
    print SCR ("#!/bin/bash\n\n");
    # Debugging message: anyone here eating my memory?
    print SCR ("hostname -f\n");
    print SCR ("echo jednou | /net/projects/SGE/sensors/mem_free.sh\n");
    print SCR ("echo jednou | /net/projects/SGE/sensors/act_mem_free.sh\n");
    print SCR ("top -bn1 | head -20\n");
    # Nivreeager algorithm
    if(1)
    {
        # If there is the temporary folder from failed previous runs, erase it or Malt will decline training.
        print SCR ("rm -rf $tbkcode-nivreeager\n");
        print SCR ("java -Xmx13g -jar $malt_jar -i $data -c $tbkcode-nivreeager -a nivreeager -grl root -nt true -gcs '~' -l liblinear -m learn\n");
        $memory = '16G';
        $priority = -300;
    }
    ###!!! The following block is not used at present but I want to preserve the options I have been using with stacklazy.
    elsif($parser =~ m/^(smf|dlx|mdlx_.+)$/)
    {
        # Both smf and dlx are instances of Malt parser. Prepare common settings.
        my $features = $scriptdir.'/malt-feature-models/CzechNonProj-JOHAN-NEW-MODIFIED.xml';
        # -d CPOSTAG means that we will learn a separate model for each part of speech tag; if we work with Universal Dependencies, this is the UPOS tag.
        # -s Stack[0] means that the model splitting will be based on the tag of the word on the top of the stack.
        my $maltsettings = "-a stacklazy -F $features -grl root -gcs '~' -d CPOSTAG -s 'Stack[0]' -T 1000 -gds T.TRANS,A.DEPREL -l libsvm -m learn";
        my $model = 'malt_stacklazy';
        if($parser eq 'smf')
        {
            my $command = "java -Xmx26g -jar $malt_jar -i train.conll -c $model $maltsettings\n";
            print SCR ("echo $command");
            print SCR ($command);
            # It is more difficult to get a machine with so much memory so we will be less generous with priority.
            # Often a machine lacks just a few hundred megabytes to be able to provide 31G. Asking for 30G increases our chances to get a machine.
            $memory = '30G';
            $priority = -90;
        }
        elsif($parser eq 'dlx')
        {
            $model .= '_delex';
            my $command = "java -Xmx26g -jar $malt_jar -i train.delex.conll -c $model $maltsettings\n";
            print SCR ("echo $command");
            print SCR ($command);
            # It is more difficult to get a machine with so much memory so we will be less generous with priority.
            # Often a machine lacks just a few hundred megabytes to be able to provide 31G. Asking for 30G increases our chances to get a machine.
            $memory = '30G';
            $priority = -90;
        }
        else # Multi-source delexicalized parsing.
        {
            # The code of the parser is mdlx_something, e.g. mdlx_all.
            $parser =~ m/^mdlx_(.+)$/;
            my $source = $1;
            print SCR ("$konfig{toolsdir}/split_conll.pl < ../train.$source.delex.conll -head $current{size} train.$source.delex.conll /dev/null\n");
            $model .= '_delex_'.$source;
            my $command = "java -Xmx26g -jar $malt_jar -i train.$source.delex.conll -c $model $maltsettings\n";
            print SCR ("echo $command");
            print SCR ($command);
            # It is more difficult to get a machine with so much memory so we will be less generous with priority.
            # Often a machine lacks just a few hundred megabytes to be able to provide 31G. Asking for 30G increases our chances to get a machine.
            $memory = '30G';
            $priority = -90;
        }
        # If there is the temporary folder from failed previous runs, erase it or Malt will decline training.
        print SCR ("rm -rf $model\n");
    }
    close(SCR);
    my $jobname = $scriptname;
    $jobname =~ s/\.sh$//;
    cluster::qsub('priority' => $priority, 'memory' => $memory, 'script' => $scriptname, 'name' => $jobname);
}
