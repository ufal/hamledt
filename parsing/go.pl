#!/usr/bin/env perl
# Processes selected languages and transformations.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use Getopt::Long;
use Treex::Core::Config;
use lib '/home/zeman/lib';
use dzsys;
use cluster;

my $scriptdir = dzsys::get_script_path();
my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks";
$data_dir =~ s-//-/-;
my $targets = get_languages_and_transformations();
my $action_name = sort_actions(@ARGV);
my $action = get_action($action_name);
my $wdir = 'pokus'; ###!!!
$wdir = dzsys::absolutize_path($wdir);
loop($targets, $action, $wdir);



#------------------------------------------------------------------------------
# Returns the list of all languages that can be processed.
#------------------------------------------------------------------------------
sub get_languages
{
    return qw(ar bg bn ca cs da de el en es et eu fi grc hi hu it ja la nl pt ro ru sl sv ta te tr);
}



#------------------------------------------------------------------------------
# Returns the list of transformations available for a given language, i.e. the
# list of subfolders of the language folder.
#------------------------------------------------------------------------------
sub get_transformations_for_language
{
    my $language = shift;
    return map {s-^.+/--; $_} (grep {-d $_} (glob("$data_dir/$language/treex/*")));
}



#------------------------------------------------------------------------------
# Returns the matrix (hash) of all languages and transformations.
#------------------------------------------------------------------------------
sub get_languages_and_transformations
{
    my @languages = get_languages();
    my %hash;
    foreach my $language (@languages)
    {
        my @transformations = get_transformations_for_language($language);
        $hash{$language} = \@transformations;
    }
    return \%hash;
}



#------------------------------------------------------------------------------
# Sorts actions in the order in which they must logically follow each other.
#------------------------------------------------------------------------------
sub sort_actions
{
    my @actions = @_;
    my %ordering =
    (
        'pretrain' => 10, # prepare training data
        'train' => 20,
        'parse' => 40,
    );
    # Check that all action identifiers are known.
    my @unknown = grep {!exists($ordering{$_})} (@actions);
    if(@unknown)
    {
        die('Unknown actions '.join(', ', @unknown));
    }
    # Check that there is at least one action in the list.
    if(!@actions)
    {
        die('At least one action must be specified.');
    }
    # Order actions.
    @actions = sort {$ordering{$a} <=> $ordering{$b}} (@actions);
    ###!!! We cannot currently solve action dependencies and waiting for results.
    ###!!! That is why we only perform the first action and ignore the others.
    if(scalar(@actions)>1)
    {
        print STDERR ("Warning: We can currently run only one action at a time.\n");
        print STDERR ("Action '$actions[0]' will be run while the rest (", join(', ', @actions[1..$#actions]), ") will be ignored.\n");
    }
    return $actions[0];
}



#------------------------------------------------------------------------------
# Returns reference to the subroutine for an action name.
#------------------------------------------------------------------------------
sub get_action
{
    my $action_name = shift;
    my $action;
    if($action_name eq 'pretrain')
    {
        $action = \&create_conll_training_data;
    }
    elsif($action_name eq 'train)
    {
        $action = \&train;
    }
    elsif($action_name eq 'parse')
    {
        $action = \&parse;
    }
    else
    {
        die("Unknown action $action_name");
    }
    return $action;
}



#------------------------------------------------------------------------------
# Performs the given action for each given language and transformation.
# Always changes to the corresponding target folder first, i.e. all cluster
# logs will be also created there. Creates the folder if it does not exist yet.
#------------------------------------------------------------------------------
sub loop
{
    my $targets = shift; # reference to hash: languages => \@transformations
    my $action = shift; # reference to subroutine (takes $lang and $trans)
    my $wdir = shift; # absolute path to root working folder for all languages
    $wdir = dzsys::absolutize_path($wdir);
    my @languages = sort(keys(%{$targets}));
    foreach my $language (@languages)
    {
        foreach my $transformation (@{$targets->{$language}})
        {
            my $dir = "$wdir/$language/$transformation";
            # Create the working folder if it does not exist yet.
            # This will also create other folders in the path if necessary.
            system("mkdir -p $dir");
            # Change to the working folder.
            chdir($dir) or die("Cannot change to $dir: $!\n");
            # Run the action.
            &{$action}($language, $transformation);
        }
    }
}



#------------------------------------------------------------------------------
# Creates CoNLL training file from the transformed Treex files. Must be rerun
# before training whenever the normalization or transformation algorithm
# changed.
#------------------------------------------------------------------------------
sub create_conll_training_data
{
    my $language = shift;
    my $transformation = shift;
    my $filename1 = 'train.conll';
    my $filename2 = 'train.mst';
    my $deprel_attribute = $transformation eq '000_orig' ? 'conll/deprel' : 'afun';
    my $scriptname = 'create_training_data.sh';
    open(SCR, ">$scriptname") or die("Cannot write $scriptname: $!\n");
    print SCR ("treex -p -j 20 ");
    print SCR ("Util::SetGlobal language=$language ");
    print SCR ("Write::CoNLLX feat_attribute=conll/feat deprel_attribute=$deprel_attribute is_member_within_afun=1 is_shared_modifier_within_afun=1 is_coord_conjunction_within_afun=1 ");
    print SCR ("-- $data_dir/$language/treex/$transformation/train/*.treex.gz > $filename1\n");
    print SCR ("$scriptdir/conll2mst.pl < $filename1 > $filename2\n");
    close(SCR);
    chmod(0755, $scriptname) or die("Cannot chmod $scriptname: $!\n");
    # Send the job to the cluster. It will itself spawn 20 cluster jobs (via treex -p) but we do not want to wait here until they're all done.
    return cluster::qsub('memory' => '1G', 'script' => $scriptname);
}



#------------------------------------------------------------------------------
# Train all parsers.
#------------------------------------------------------------------------------
sub train
{
    my $language = shift;
    my $transformation = shift;
    my $mcd_dir  = $ENV{TMT_ROOT}."/libs/other/Parser/MST/mstparser-0.4.3b";
    my $malt_dir = $ENV{TMT_ROOT}."/share/installed_tools/malt_parser/malt-1.5";
    # Prepare the training script and submit the job to the cluster.
    foreach my $parser qw(mlt smf mcd mcp)
    {
        my $scriptname = "$parser-$language-$transformation.sh";
        my $memory;
        print STDERR ("Creating script $scriptname.\n");
        open(SCR, ">$scriptname") or die("Cannot write $scriptname: $!\n");
        print SCR ("#!/bin/bash\n\n");
        # Debugging message: anyone here eating my memory?
        print SCR ("hostname -f\n");
        print SCR ("echo jednou | /net/projects/SGE/sensors/mem_free.sh\n");
        print SCR ("echo jednou | /net/projects/SGE/sensors/act_mem_free.sh\n");
        print SCR ("top -bn1 | head -20\n");
        if($parser eq 'mcd')
        {
            print SCR ("java -cp $mcd_dir/output/mstparser.jar:$mcd_dir/lib/trove.jar -Xmx9g mstparser.DependencyParser \\\n");
            print SCR ("  train order:2 format:MST decode-type:non-proj train-file:train.mst model-name:mcd_nonproj_o2.model\n");
            $memory = '10G';
        }
        elsif($parser eq 'mcp')
        {
            print SCR ("java -cp $mcd_dir/output/mstparser.jar:$mcd_dir/lib/trove.jar -Xmx9g mstparser.DependencyParser \\\n");
            print SCR ("  train order:2 format:MST decode-type:proj train-file:train.mst model-name:mcd_proj_o2.model\n");
            $memory = '10G';
        }
        elsif($parser eq 'mlt')
        {
            # If there is the temporary folder from failed previous runs, erase it or Malt will decline training.
            print SCR ("rm -rf malt_nivreeager\n");
            print SCR ("java -Xmx15g -jar $malt_dir/malt.jar -i train.conll -c malt_nivreeager -a nivreeager -l liblinear -m learn\n");
            $memory = '16G';
        }
        elsif($parser eq 'smf')
        {
            # If there is the temporary folder from failed previous runs, erase it or Malt will decline training.
            print SCR ("rm -rf malt_stacklazy\n");
            my $features = '/net/work/people/zeman/parsing/malt-parser/marco-kuhlmann-czech-settings/CzechNonProj-JOHAN-NEW-MODIFIED.xml';
            my $command = "java -Xmx29g -jar $malt_dir/malt.jar -i train.conll -c malt_stacklazy -a stacklazy -F $features -grl Pred -d POSTAG -s 'Stack[0]' -T 1000 -gds T.TRANS,A.DEPREL -l libsvm -m learn\n";
            print SCR ("echo $command");
            print SCR ($command);
            $memory = '31G';
        }
        close(SCR);
        cluster::qsub('memory' => $memory, 'script' => $scriptname);
    }
}



#------------------------------------------------------------------------------
# Parse using all parsers.
#------------------------------------------------------------------------------
sub parse
{
    my $language = shift;
    my $transformation = shift;
    my %parser_block =
    (
        mlt => "W2A::ParseMalt model=malt_nivreeager.mco pos_attribute=conll/pos cpos_attribute=conll/cpos feat_attribute=conll/feat",
        smf => "W2A::ParseMalt model=malt_stacklazy.mco  pos_attribute=conll/pos cpos_attribute=conll/cpos feat_attribute=conll/feat",
        mcd => "W2A::ParseMST model=mcd_nonproj_o2.model decodetype=non-proj pos_attribute=conll/pos",
        mcp => "W2A::ParseMST model=mcd_proj_o2.model    decodetype=proj     pos_attribute=conll/pos",
    );
    # Prepare the training script and submit the job to the cluster.
    foreach my $parser qw(mlt smf mcd mcp)
    {
        # Copy test data to the working folder.
        # Each parser needs its own copy so that they can run in parallel and not overwrite each other's output.
        system("rm -rf $parser-test");
        system("mkdir -p $parser-test");
        system("cp $data_dir/$language/treex/$transformation/test/*.treex.gz $parser-test");
        my $scriptname = "p$parser-$language-$transformation.sh";
        my $memory = '12G';
        my $scenario;
        $scenario .= "Util::SetGlobal language=$language selector=$parser ";
        # If there is a tree with the same name, remove it first.
        $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' ";
        $scenario .= "A2A::CopyAtree source_selector='' flatten=1 ";
        $scenario .= "$parser_block{$parser} ";
        # Note: the trees in 000_orig should be compared against the original gold tree.
        # However, that tree has the '' selector in 000_orig (while it has the 'orig' selector elsewhere),
        # so we do not select 'orig' here.
        $scenario .= "Eval::AtreeUAS eval_is_member=1 eval_is_shared_modifier=1 selector='' ";
        # Every parser must have its own UAS file so that they can run in parallel and not overwrite each other's evaluation.
        my $uas_file = "uas-$parser.txt";
        print STDERR ("Creating script $scriptname.\n");
        open(SCR, ">$scriptname") or die("Cannot write $scriptname: $!\n");
        print SCR ("#!/bin/bash\n\n");
        # Debugging message: anyone here eating my memory?
        print SCR ("hostname -f\n");
        print SCR ("echo jednou | /net/projects/SGE/sensors/mem_free.sh\n");
        print SCR ("echo jednou | /net/projects/SGE/sensors/act_mem_free.sh\n");
        print SCR ("top -bn1 | head -20\n");
        print SCR ("treex -s $scenario -- $parser-test/*.treex.gz | tee $uas_file\n");
        close(SCR);
        cluster::qsub('memory' => $memory, 'script' => $scriptname);
    }
}
