#!/usr/bin/env perl
# Processes selected languages and transformations (train, parse, eval, clean etc.)
# Provides the unified necessary infrastructure for looping through all the sub-experiment subfolders.
# Copyright © 2011, 2012, 2013, 2014, 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

sub usage
{
    print STDERR ("go.pl [OPTIONS] <ACTION>\n");
    print STDERR ("\tActions: pretrain|train|parse|table|ltable|clean\n");
    print STDERR ("\tExperiment folder tree is created/expected at ./pokus (currently fixed).\n");
    print STDERR ("\tSource data path is fixed at \$TMT_SHARED.\n");
    print STDERR ("\tThe script knows the list of available languages.\n");
    print STDERR ("\tThe list of transformations is created by scanning subfolders of the language.\n");
    print STDERR ("\tThe 'clean' action currently only removes the cluster logs (.o123456 files).\n");
    print STDERR ("\tOptions:\n");
    print STDERR ("\t--languages en,cs,ar ... instead of all languages, process only those specified here.\n");
    print STDERR ("\t--trainlimit N ... for the 'pretrain' action: use only the first N sentences for training.\n");
}

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Getopt::Long;
use Treex::Core::Config;
use Text::Table;
use lib '/home/zeman/lib';
use dzsys;
use cluster;

# Read options.
my $wdir = 'pokus'; # default working folder
GetOptions
(
    'wdir=s'            => \$wdir,
    'languages|langs=s' => \$konfig{languages},
    'trainlimit=s'      => \$konfig{trainlimit},
    'help'              => \$konfig{help}
);
exit(usage()) if($konfig{help});

my $scriptdir = dzsys::get_script_path();
my $share_dir = Treex::Core::Config->share_dir();
if(!defined($share_dir) || $share_dir eq '')
{
    die("Unknown path to the shared folder");
}
my $data_dir = Treex::Core::Config->share_dir()."/data/resources/hamledt";
$data_dir =~ s-//-/-;
print STDERR ("Data folder    = $data_dir\n");
my $targets = get_treebanks_and_transformations();
my $action_name = sort_actions(@ARGV);
my $action = get_action($action_name);
$wdir = dzsys::absolutize_path($wdir);
print STDERR ("Working folder = $wdir\n");
sleep(5);
# We need to know what jobs are running if we are going to clean the disk.
my %qjobs = cluster::qstat0();
loop($targets, $action, $wdir);
print_table() if($action_name =~ m/table$/);



#------------------------------------------------------------------------------
# Returns the list of all treebanks that can be processed. A treebank id
# starts with the language code. The treebank id is part of the path to the
# data. Some treebank ids are just the language code and nothing else.
#------------------------------------------------------------------------------
sub get_treebanks
{
    if($konfig{treebanks})
    {
        return split(/,/, $konfig{treebanks});
    }
    else
    {
        my @hamledt = qw(ar bn ca de en es et fa grc hi hr ja la la-it nl pl pt ro ru sk sl ta te tr);
        my @ud11 = map {$_.'-ud11'} qw(bg cs da de el en es eu fa fi fr ga he hr hu id it sv);
        push(@ud11, 'fi-ud11ftb');
        return (@hamledt, @ud11);
    }
}



#------------------------------------------------------------------------------
# Returns the list of all parsers we can use. A parser is referenced by a short
# code. The code represents parser software (such as Malt or MST) together with
# particular configuration (such as the nivreeager or stacklazy algorithms of
# the Malt parser). The code may also refer to particular experiment setup, for
# example, 'dlx' uses delexicalized training and test data, while the default
# for other parsers is to used lexicalized data.
#------------------------------------------------------------------------------
sub get_parsers
{
    # We temporarily do not use 'mcd' and 'mcp' (the MST parser by Ryan McDonald).
    return qw(mlt smf dlx);
}



#------------------------------------------------------------------------------
# Returns the list of transformations available for a given treebank, i.e. the
# list of subfolders of the treebank folder.
#------------------------------------------------------------------------------
sub get_transformations_for_treebank
{
    my $treebank = shift;
    ###!!! We have suspended experiments with transformations until normalization is perfect.
    ###!!! Now we have also suspended experiments with 00 (the original trees) because the UD treebanks do not have them.
    return ('02');
}



#------------------------------------------------------------------------------
# Returns the matrix (hash) of all treebanks and transformations.
#------------------------------------------------------------------------------
sub get_treebanks_and_transformations
{
    my @treebanks = get_treebanks();
    my %hash;
    foreach my $treebank (@treebanks)
    {
        my @transformations = get_transformations_for_treebank($treebank);
        $hash{$treebank} = \@transformations;
    }
    return \%hash;
}



#------------------------------------------------------------------------------
# Returns pre-selected combinations of Interset features that we want to try
# keeping in the data. The combinations can be used as parameter to either
# conll_delexicalize.pl (for training data) or the W2A::Delexicalize Treex
# block (for test data). Experiments with different feature combinations serve
# two goals: 1. to estimate how important is a particular feature for parsers;
# 2. to improve cross-language training in cases where a feature is not
# available in the target language.
#------------------------------------------------------------------------------
sub get_feature_combinations
{
    # Volitelný výběr rysů z Universal Dependencies:
    # žádné rysy (pouze UPOS)
    # různé kombinace následujících množin:
    # - pouze lexikální rysy: PronType, NumType, Poss, Reflex
    # - pád: Case
    # - slovesný tvar: VerbForm
    # - slovesné tvary jemněji: Mood, Tense, Aspect, Voice
    # - osoba: Person
    # - číslo: Number
    # - další jmenné se shodou: Gender, Animacy, Definite
    # - (zbývá Degree a Negative, v jejichž užitečnost nevěřím, projeví se jen v množině všechny rysy)
    # všechny univerzální rysy (vynechat nadstavby jednotlivých jazyků či treebanků)
    # všechny rysy
    my %fc;
    $fc{lex}  = ['prontype', 'numtype', 'poss', 'reflex'];
    $fc{vf}   = ['verbform'];
    $fc{tmav} = ['mood', 'tense', 'aspect', 'voice'];
    $fc{case} = ['case'];
    $fc{prs}  = ['person'];
    $fc{num}  = ['number'];
    $fc{gad}  = ['gender', 'animacy', 'definiteness'];
    $fc{lv}   = fc(\%fc, 'lex', 'vf');
    $fc{lt}   = fc(\%fc, 'lex', 'tmav');
    $fc{lc}   = fc(\%fc, 'lex', 'case');
    $fc{lp}   = fc(\%fc, 'lex', 'prs');
    $fc{ln}   = fc(\%fc, 'lex', 'num');
    $fc{lg}   = fc(\%fc, 'lex', 'gad');
    $fc{vt}   = fc(\%fc, 'vf', 'tmav');
    $fc{vc}   = fc(\%fc, 'vf', 'case');
    $fc{vp}   = fc(\%fc, 'vf', 'prs');
    $fc{vn}   = fc(\%fc, 'vf', 'num');
    $fc{vg}   = fc(\%fc, 'vf', 'gad');
    $fc{tc}   = fc(\%fc, 'tmav', 'case');
    $fc{tp}   = fc(\%fc, 'tmav', 'prs');
    $fc{tn}   = fc(\%fc, 'tmav', 'num');
    $fc{tg}   = fc(\%fc, 'tmav', 'gad');
    $fc{cp}   = fc(\%fc, 'case', 'prs');
    $fc{cn}   = fc(\%fc, 'case', 'num');
    $fc{cg}   = fc(\%fc, 'case', 'gad');
    $fc{pn}   = fc(\%fc, 'prs', 'num');
    $fc{pg}   = fc(\%fc, 'prs', 'gad');
    $fc{ng}   = fc(\%fc, 'num', 'gad');
    $fc{lvt}  = fc(\%fc, 'lex', 'vf', 'tmav');
    $fc{lvtc} = fc(\%fc, 'lex', 'vf', 'tmav', 'case');
    $fc{lvc}  = fc(\%fc, 'lex', 'vf', 'case');
    $fc{vtc}  = fc(\%fc, 'vf', 'tmav', 'case');
    $fc{lvtcpn} = fc(\%fc, 'lex', 'vf', 'tmav', 'case', 'prs', 'num');
    $fc{lvtcpng} = fc(\%fc, 'lvtcpn', 'gad');
    my %fcpar;
    foreach my $combination (keys(%fc))
    {
        $fcpar{$combination} = join(',', @{$fc{$combination}});
    }
    $fcpar{all} = 1;
    $fcpar{none} = 0;
    return \%fcpar;
}
sub fc
{
    my $fc = shift;
    my @keys = @_;
    my @features = map {@{$fc->{$_}}} @keys;
    return \@features;
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
        'table' => 60,
        'ltable' => 61, # labeled instead of unlabeled attachment score
        'clean' => 80,
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
    elsif($action_name eq 'train')
    {
        $action = \&train;
    }
    elsif($action_name eq 'parse')
    {
        $action = \&parse;
    }
    elsif($action_name eq 'table')
    {
        $action = \&get_results;
    }
    elsif($action_name eq 'ltable')
    {
        $action = \&get_labeled_results;
    }
    elsif($action_name eq 'clean')
    {
        $action = \&clean;
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
    my @treebanks = sort(keys(%{$targets}));
    my $fchash = get_feature_combinations();
    my @fcombinations = sort(keys(%{$fchash}));
    foreach my $treebank (@treebanks)
    {
        foreach my $transformation (@{$targets->{$treebank}})
        {
            foreach my $fc (@fcombinations)
            {
                my $dir = "$wdir/$treebank/$transformation/$fc";
                # Create the working folder if it does not exist yet.
                # This will also create other folders in the path if necessary.
                system("mkdir -p $dir");
                # Change to the working folder.
                chdir($dir) or die("Cannot change to $dir: $!\n");
                # Run the action.
                &{$action}($treebank, $transformation, $fchash->{$fc});
            }
        }
    }
}



#------------------------------------------------------------------------------
# Returns block parameters that specify which node attributes shall be exported
# to the CoNLL file. Identical parameters must be used to create training and
# test data. In the former case, the parameters are applied to the
# Write::CoNLLX block. In the latter case, the parameters are applied to the
# W2A::ParseMalt block.
#------------------------------------------------------------------------------
sub get_conll_block_parameters
{
    my $transformation = shift;
    my @parameters;
    # Some attributes are not available before normalization.
    if($transformation eq '00')
    {
        @parameters =
        (
            'cpos_attribute=conll/cpos',
            'pos_attribute=conll/pos',
            'feat_attribute=conll/feat',
            'deprel_attribute=conll/deprel',
            'is_member_within_afun=1',
            'is_shared_modifier_within_afun=1',
            'is_coord_conjunction_within_afun=1'
        );
    }
    else # harmonized data
    {
        @parameters =
        (
            'cpos_attribute=tag',
            'pos_attribute=tag',
            'feat_attribute=iset',
            'deprel_attribute=deprel',
            'is_member_within_afun=0',
            'is_shared_modifier_within_afun=0',
            'is_coord_conjunction_within_afun=0'
        );
    }
    return join(' ', @parameters);
}



#------------------------------------------------------------------------------
# Creates CoNLL training file from the transformed Treex files. Must be rerun
# before training whenever the normalization or transformation algorithm
# changed.
#------------------------------------------------------------------------------
sub create_conll_training_data
{
    my $treebank = shift;
    my $transformation = shift;
    my $fcparameter = shift;
    my $language = $treebank;
    $language =~ s/-.*//;
    my $filename1 = 'train.conll';
    my $filename2 = 'train.mst';
    my $scriptname = 'create_training_data.sh';
    open(SCR, ">$scriptname") or die("Cannot write $scriptname: $!\n");
    print SCR ("treex -p -j 20 ");
    print SCR ("Util::SetGlobal language=$language ");
    # We have to make sure that the (cpos|pos|feat)_attribute is the same for both training and parsing! See below.
    my $writeparam = get_conll_block_parameters($transformation);
    print SCR ("Write::CoNLLX $writeparam ");
    print SCR ("-- $data_dir/$treebank/treex/$transformation/train/*.treex.gz ");
    print SCR ("> $filename1\n");
    # In order to have experiments finished faster, we can limit training data to a fixed number of sentences.
    if($konfig{trainlimit})
    {
        print SCR ("/net/work/people/zeman/parsing/tools/split_conll.pl < $filename1 -head $konfig{trainlimit} $filename1.truncated /dev/null\n");
        print SCR ("mv $filename1.truncated $filename1\n");
    }
    # Prepare a delexicalized training file for experiments with delexicalized parsing.
    my $delexfilename1 = $filename1;
    $delexfilename1 =~ s/\.conll$/.delex.conll/;
    print SCR ("/net/work/people/zeman/parsing/tools/conll_delexicalize.pl --keep-features=$fcparameter < $filename1 > $delexfilename1\n");
    # Prepare a modified form that can be used by the MST Parser.
    print SCR ("$scriptdir/conll2mst.pl < $filename1 > $filename2\n");
    close(SCR);
    chmod(0755, $scriptname) or die("Cannot chmod $scriptname: $!\n");
    # Send the job to the cluster. It will itself spawn 20 cluster jobs (via treex -p) but we do not want to wait here until they're all done.
    return cluster::qsub('priority' => -200, 'memory' => '1G', 'script' => $scriptname);
}



#------------------------------------------------------------------------------
# Trains all parsers.
#------------------------------------------------------------------------------
sub train
{
    my $treebank = shift;
    my $transformation = shift;
    my $mcd_dir  = $ENV{TMT_ROOT}."/libs/other/Parser/MST/mstparser-0.4.3b";
    my $malt_dir = $ENV{TMT_ROOT}."/share/installed_tools/malt_parser/malt-1.5";
    # Prepare the training script and submit the job to the cluster.
    foreach my $parser (get_parsers())
    {
        my $scriptname = "$parser-$treebank-$transformation.sh";
        my ($memory, $priority);
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
            $memory = '12G';
            $priority = -300;
        }
        elsif($parser eq 'mcp')
        {
            print SCR ("java -cp $mcd_dir/output/mstparser.jar:$mcd_dir/lib/trove.jar -Xmx9g mstparser.DependencyParser \\\n");
            print SCR ("  train order:2 format:MST decode-type:proj train-file:train.mst model-name:mcd_proj_o2.model\n");
            $memory = '16G';
            $priority = -300;
        }
        elsif($parser eq 'mlt')
        {
            # If there is the temporary folder from failed previous runs, erase it or Malt will decline training.
            print SCR ("rm -rf malt_nivreeager\n");
            print SCR ("java -Xmx13g -jar $malt_dir/malt.jar -i train.conll -c malt_nivreeager -a nivreeager -gcs '~' -l liblinear -m learn\n");
            $memory = '16G';
            $priority = -300;
        }
        elsif($parser eq 'smf')
        {
            my $model = 'malt_stacklazy';
            # If there is the temporary folder from failed previous runs, erase it or Malt will decline training.
            print SCR ("rm -rf $model\n");
            my $features = $scriptdir.'/malt-feature-models/CzechNonProj-JOHAN-NEW-MODIFIED.xml';
            my $command = "java -Xmx26g -jar $malt_dir/malt.jar -i train.conll -c $model -a stacklazy -F $features -grl root -gcs '~' -d POSTAG -s 'Stack[0]' -T 1000 -gds T.TRANS,A.DEPREL -l libsvm -m learn\n";
            print SCR ("echo $command");
            print SCR ($command);
            # It is more difficult to get a machine with so much memory so we will be less generous with priority.
            # Often a machine lacks just a few hundred megabytes to be able to provide 31G. Asking for 30G increases our chances to get a machine.
            $memory = '30G';
            $priority = -100;
        }
        elsif($parser eq 'dlx')
        {
            my $model = 'malt_stacklazy_delex';
            # If there is the temporary folder from failed previous runs, erase it or Malt will decline training.
            print SCR ("rm -rf $model\n");
            my $features = $scriptdir.'/malt-feature-models/CzechNonProj-JOHAN-NEW-MODIFIED.xml';
            my $command = "java -Xmx26g -jar $malt_dir/malt.jar -i train.delex.conll -c $model -a stacklazy -F $features -grl root -gcs '~' -d POSTAG -s 'Stack[0]' -T 1000 -gds T.TRANS,A.DEPREL -l libsvm -m learn\n";
            print SCR ("echo $command");
            print SCR ($command);
            # It is more difficult to get a machine with so much memory so we will be less generous with priority.
            # Often a machine lacks just a few hundred megabytes to be able to provide 31G. Asking for 30G increases our chances to get a machine.
            $memory = '30G';
            $priority = -100;
        }
        close(SCR);
        cluster::qsub('priority' => $priority, 'memory' => $memory, 'script' => $scriptname);
    }
}



#------------------------------------------------------------------------------
# Creates the Treex parsing scenario for a given parser.
#------------------------------------------------------------------------------
sub get_parsing_scenario
{
    my $parser = shift; # parser code, e.g. 'mlt' or 'mcd'
    my $delexicalized = ($parser eq 'dlx'); # we may want to make this a parameter
    my $language = shift; # language, not treebank code
    my $transformation = shift;
    my $fcparameter = shift;
    my $modeldir = shift; # for cross-language delexicalized training: where is the model?
    my $path = defined($modeldir) ? "$modeldir/$transformation/" : '';
    # We have to make sure that the (cpos|pos|feat)_attribute is the same for both training and parsing! See above.
    my $writeparam = get_conll_block_parameters($transformation);
    my %parser_block =
    (
        mlt => "W2A::ParseMalt model=malt_nivreeager.mco             $writeparam",
        smf => "W2A::ParseMalt model=malt_stacklazy.mco              $writeparam",
        dlx => "W2A::ParseMalt model=${path}malt_stacklazy_delex.mco $writeparam",
        mcd => "W2A::ParseMST  model_dir=. model=mcd_nonproj_o2.model decodetype=non-proj pos_attribute=conll/pos",
        mcp => "W2A::ParseMST  model_dir=. model=mcd_proj_o2.model    decodetype=proj     pos_attribute=conll/pos",
    );
    my $scenario;
    $scenario .= "Util::SetGlobal language=$language selector=$parser ";
    # If there is a tree with the same name, remove it first.
    $scenario .= "Util::Eval zone='\$zone->remove_tree(\"a\") if \$zone->has_tree(\"a\");' ";
    $scenario .= "A2A::CopyAtree source_selector='' flatten=1 ";
    # Delexicalize the test sentence if required.
    if($delexicalized)
    {
        $scenario .= "W2A::Delexicalize keep_iset=$fcparameter "
    }
    $scenario .= "$parser_block{$parser} ";
    # Note: the trees in 00 should be compared against the original gold tree.
    # However, that tree has the '' selector in 00 (while it has the 'orig' selector elsewhere),
    # so we do not select 'orig' here.
    $scenario .= "Eval::AtreeUAS selector='' ";
    return $scenario;
}



#------------------------------------------------------------------------------
# Parses using all parsers.
#------------------------------------------------------------------------------
sub parse
{
    my $treebank = shift;
    my $transformation = shift;
    my $fcparameter = shift;
    my $language = $treebank;
    $language =~ s/-.*//;
    # Prepare the training script and submit the job to the cluster.
    foreach my $parser (get_parsers())
    {
        my %scenarios;
        # The delexicalized parser can use trained delexicalized models from any language/treebank, not necessarily its own.
        if($parser eq 'dlx')
        {
            my @treebanks = get_treebanks();
            foreach my $srctbk (@treebanks)
            {
                my $dir = "$wdir/$srctbk";
                $scenarios{$srctbk} = get_parsing_scenario($parser, $language, $transformation, $fcparameter, $dir);
            }
        }
        else
        {
            $scenarios{''} = get_parsing_scenario($parser, $language, $transformation);
        }
        foreach my $srctbk (keys(%scenarios))
        {
            my $scenario = $scenarios{$srctbk};
            my $parserst = $srctbk ne '' ? "$parser-$srctbk" : $parser;
            # Copy test data to the working folder.
            # Each parser needs its own copy so that they can run in parallel and not overwrite each other's output.
            system("rm -rf $parserst-test");
            system("mkdir -p $parserst-test");
            system("cp $data_dir/$treebank/treex/$transformation/test/*.treex.gz $parserst-test");
            my $scriptname = "p$parserst-$treebank-$transformation.sh";
            my $memory = '16G';
            # Every parser must have its own UAS file so that they can run in parallel and not overwrite each other's evaluation.
            my $uas_file = "uas-$parserst.txt";
            print STDERR ("Creating script $scriptname.\n");
            open(SCR, ">$scriptname") or die("Cannot write $scriptname: $!\n");
            print SCR ("#!/bin/bash\n\n");
            # Debugging message: anyone here eating my memory?
            print SCR ("hostname -f\n");
            print SCR ("echo jednou | /net/projects/SGE/sensors/mem_free.sh\n");
            print SCR ("echo jednou | /net/projects/SGE/sensors/act_mem_free.sh\n");
            print SCR ("top -bn1 | head -20\n");
            print SCR ("treex -s $scenario -- $parserst-test/*.treex.gz | tee $uas_file\n");
            close(SCR);
            cluster::qsub('priority' => -200, 'memory' => $memory, 'script' => $scriptname);
        }
    }
}



#------------------------------------------------------------------------------
# Collects test results of all parsers.
#------------------------------------------------------------------------------
sub get_results
{
    my $treebank = shift;
    my $transformation = shift;
    my $labeled = shift;
    my $language = $treebank;
    $language =~ s/-.*//;
    # Get the list of known parsers. For delexicalized parsing, each source model counts as a separate parser.
    my @parsers = map
    {
        my @subset = ($_);
        if($_ eq 'dlx')
        {
            my @treebanks = get_treebanks();
            @subset = map {"dlx-$_"} @treebanks;
        }
        @subset;
    }
    (get_parsers());
    foreach my $parser (@parsers)
    {
        # Every parser must have its own UAS file so that they can run in parallel and not overwrite each other's evaluation.
        my $uas_file = "uas-$parser.txt";
        # Read the score from the UAS file. Store it in a global hash called %value.
        if(!open(UAS, $uas_file))
        {
            print STDERR ("Cannot read $treebank/$transformation/$uas_file: $!\n");
            next;
        }
        while (<UAS>)
        {
            chomp;
            my ($sys, $counts, $score) = split /\t/;
            # UASp ... parent match
            # UASpm ... parent and is_member match
            # UASpms ... parent, is_member and is_shared_modifier match
            my $x = $labeled ? 'L' : 'U';
            my $selector = $parser =~ m/^dlx/ ? 'dlx' : $parser;
            if($sys =~ m/^${x}AS(p(?:ms?)?)\(${language}_${selector},${language}\)$/)
            {
                my $uasparams = $1;
                $score = $score ? 100 * $score : 0;
                # Store score differences instead of scores for transformed trees.
                if($trans !~ /00/ && defined($value{$treebank}{'02'}{$parser}{$uasparams}))
                {
                    $score -= $value{$treebank}{'02'}{$parser}{$uasparams};
                }
                $value{$treebank}{$transformation}{$parser}{$uasparams} = round($score);
            }
        }
        my $debug = 0;
        if($debug && !defined($value{$treebank}{$transformation}{$parser}{pms}))
        {
            print("Parser $parser score not found in $treebank/$transformation/$uas_file.\n");
        }
    }
}
sub get_labeled_results
{
    my $treebank = shift;
    my $transformation = shift;
    return get_results($treebank, $transformation, 1);
}



#------------------------------------------------------------------------------
# Rounds a score to two decimal places.
#------------------------------------------------------------------------------
sub round
{
    my $score = shift;
    return undef if(!defined($score));
    return sprintf("%.2f", $score+0.005);
}



#------------------------------------------------------------------------------
# Prints the table of results, found in the global hash %value.
#------------------------------------------------------------------------------
sub print_table_old
{
    my @languages = sort(keys(%value));
    my %transformations;
    foreach my $language (@languages)
    {
        foreach my $transformation (keys(%{$value{$language}}))
        {
            $transformations{$transformation}++;
        }
    }
    foreach my $parser (get_parsers())
    {
        print("\n", '*' x 10 . "  $parser  " . '*' x 10, "\n\n");
        my $table = Text::Table->new('trans', @languages, 'better', 'worse', 'average');
        foreach my $trans (sort(keys(%transformations)))
        {
            my @row = $trans;
            my $better = 0;
            my $worse = 0;
            my $diff = 0;
            my $cnt = 0;
            foreach my $language (@languages)
            {
                my $out = $value{$language}{$trans}{$parser}{pms};
                #$out .= '/'.$value{$language}{$trans}{$parser}{pms};
                push(@row, $out);
                next if(!$value{$language}{$trans}{$parser}{pms} || !$value{$language}{'001_pdtstyle'}{$parser}{pms});
                $better++ if($value{$language}{$trans}{$parser}{pms} > $signif_diff);
                $worse++ if($value{$language}{$trans}{$parser}{pms} < -$signif_diff);
                $diff += $value{$language}{$trans}{$parser}{pms};
                $cnt++;
            }
            # Warning: $cnt can be zero if we do not have $value for either this transformation or for 001_pdtstyle.
            $diff /= $cnt if($cnt);
            push(@row, ($better, $worse, round($diff)));
            $table->add(@row);
        }
        my $n_langs = scalar(@languages);
        if($n_langs < 18)
        {
            print($table->table());
        }
        else
        {
            print($table->select(0 .. ($n_langs/2)+1)->table());
            print("\n");
            print($table->select(0,($n_langs/2)+2 .. $n_langs+3)->table());
        }
    }
}



#------------------------------------------------------------------------------
# Prints the table of results, found in the global hash %value.
#------------------------------------------------------------------------------
sub print_table
{
    my @treebanks = sort(keys(%value));
    my %parsers;
    foreach my $treebank (@treebanks)
    {
        my $transformation = '02';
        foreach my $parser (keys(%{$value{$treebank}{$transformation}}))
        {
            $parsers{$parser}++;
        }
    }
    # Create table with the header (which also defines the number of columns).
    my $table = Text::Table->new('parser', @treebanks);
    foreach my $parser (sort(keys(%parsers)))
    {
        my @row = ($parser);
        foreach my $treebank (@treebanks)
        {
            my $out = $value{$treebank}{'02'}{$parser}{pms};
            push(@row, $out);
        }
        $table->add(@row);
    }
    # Split the table if there are too many columns.
    my $n = scalar(@treebanks);
    if($n < 18)
    {
        print($table->table());
    }
    else
    {
        print($table->select(0 .. ($n/2)+1)->table());
        print("\n");
        print($table->select(0, ($n/2)+2 .. $n)->table());
    }
    # Another table.
    # For each target treebank, show source treebanks (parsers) ordered by accuracy.
    print("\n");
    $table = Text::Table->new('treebank', 1 .. 10);
    foreach my $treebank (@treebanks)
    {
        my $results = $value{$treebank}{'02'};
        my @parsers = sort {$results->{$b}{pms} <=> $results->{$a}{pms}} (keys(%{$results}));
        my @row = ($treebank, map {my $x = "$_ ($results->{$_}{pms})"; $x =~ s/^dlx-/d/; $x =~ s/-ud11/-u/; $x} @parsers);
        $table->add(@row);
    }
    print($table->select(0..10)->table());
}



#------------------------------------------------------------------------------
# Removes temporary files and cluster job logs.
#------------------------------------------------------------------------------
sub clean
{
    my $treebank = shift;
    my $transformation = shift;
    # Scan the current folder for cluster logs.
    opendir(DIR, '.') or die("Cannot read folder $treebank/$transformation: $!");
    my @files = readdir(DIR);
    closedir(DIR);
    foreach my $file (@files)
    {
        # Does the file name look like a cluster log?
        if($file =~ m/^(.*)\.o(\d+)$/)
        {
            my $script = $1;
            my $jobid = $2;
            # If the job is running or waiting in the queue we should not remove its files.
            unless(exists($qjobs{$jobid}))
            {
                # Remove the log.
                print STDERR ("Removing $treebank/$transformation/$file\n");
                unlink($file) or print STDERR ("Warning: Cannot remove $treebank/$transformation/$file: $!\n");
                ###!!!
                # We do not know whether we can also remove the script.
                # It could be reused by another job which could be still running.
                # We would have to wait until we visit all logs of that script.
            }
            else
            {
                print STDERR ("Keeping $treebank/$transformation/$file because the job no. $jobid is still on the cluster.\n");
            }
        }
        # Does it look like the name of the folder created for a parallelized Treex run?
        elsif($file =~ m/^\d\d\d-cluster-run-[A-Za-z0-9]+$/)
        {
            my $removable = 1;
            opendir(DIR, $file);
            my @files1 = readdir(DIR);
            closedir(DIR);
            foreach my $file1 (@files1)
            {
                # Is this the reason why we cannot remove the whole folder?
                if($file1 =~ m/\.o(\d+)$/ && exists($qjobs{$jobid}))
                {
                    print STDERR ("Keeping $treebank/$transformation/$file because the job no. $jobid is still on the cluster.\n");
                    $removable = 0;
                    last;
                }
            }
            if($removable)
            {
                print STDERR ("Removing $treebank/$transformation/$file\n");
                system("rm -rf $file");
            }
        }
        # Is it a core file created after a crash?
        elsif($file eq 'core')
        {
            print STDERR ("Removing $treebank/$transformation/$file\n");
            unlink($file) or print STDERR ("Warning: Cannot remove $treebank/$transformation/$file: $!\n");
        }
    }
}
