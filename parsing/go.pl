#!/usr/bin/env perl
# Processes selected languages and transformations (train, parse, eval, clean etc.)
# Provides the unified necessary infrastructure for looping through all the sub-experiment subfolders.
# Copyright © 2011-2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

sub usage
{
    print STDERR ("go.pl [OPTIONS] <ACTION>\n");
    print STDERR ("\tActions: pretrain|train|parse|table|ltable|clean\n");
    print STDERR ("\tSource data path is fixed at \$TMT_SHARED.\n");
    print STDERR ("\tThe script knows the list of available languages.\n");
    print STDERR ("\tThe script currently ignores transformations (if any) but it models the learning curve.\n");
    print STDERR ("\tThe 'clean' action currently only removes the cluster logs (.o123456 files).\n");
    print STDERR ("\tOptions:\n");
    print STDERR ("\t--wdir folder ... experiment folder; default is ./pokus.\n");
    print STDERR ("\t--treebanks en,cs,ar ... instead of all treebanks, process only those specified here.\n");
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
use Time::Piece; # localtime()->ymd();
use lib '/home/zeman/lib';
use dzsys;
use cluster;

# Read options.
my $wdir = 'pokus'; # default working folder
GetOptions
(
    'wdir=s'            => \$wdir,
    'treebanks=s'       => \$konfig{treebanks},  # comma-separated list, e.g. "--treebanks de,de-ud11"
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
$konfig{delexpairs} = get_best_delex();
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
        my @hamledt = qw(ar bn ca de en es et fa grc hi hr ja la la-it mt nl pl pt ro ru sk sl ta te tr);
        my @ud11 = map {$_.'-ud11'} qw(bg cs da de el en es eu fa fi fr ga he hr hu id it sv);
        push(@ud11, 'fi-ud11ftb');
        my @ud12 = map {$_.'-ud12'} qw(ar bg cs cu da de el en es et eu fa fi fr ga got grc he hi hr hu id it la nl no pl pt ro sl sv ta);
        push(@ud12, 'fi-ud12ftb', 'grc-ud12proiel', 'la-ud12itt', 'la-ud12proiel'); # Excluding ja-ud12ktc because it does not contain words and lemmas.
        return (@ud12);
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
    # We temporarily do not use 'mlt', 'mcd' and 'mcp' (the MST parser by Ryan McDonald).
    return qw(smf dlx);
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
# Returns a pre-selected feature combination to use for all delexicalizations.
# It has to be supplied at two places (pretrain and parse), so it is good to
# have it defined at one central place. (See below for an experiment with many
# different feature combinations.)
#------------------------------------------------------------------------------
sub get_fc
{
    # 0 ... none
    # 1 ... all
    # prontype,numtype ... only prontype and numtype
    return 1;
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
# Returns pre-computed hash that says for each treebank, which other treebanks
# provide the best delexicalized models to parse this treebank.
#------------------------------------------------------------------------------
sub get_best_delex
{
    # The accuracy of the source languages was assessed on the UD 1.2 data.
    # Malt parser stack lazy, gold standard tags and features, including language-specific.
    # Utility of the model is based on the best number along the learning curve.
    # Sometimes a source language is good because it has a lot of data. But sometimes we have to stop training much earlier, otherwise we overfit to the source language.
    # This ranking cheats in that we will not know what is the right amount to take from the available training data.
    my %best =
    (
        # Indo-European
        'bg-ud12' => ['sl-ud12', 'hr-ud12', 'cs-ud12'],
        'cs-ud12' => ['sl-ud12', 'bg-ud12', 'hr-ud12'],
        'cu-ud12' => ['got-ud12', 'grc-ud12proiel', 'la-ud12proiel'],
        'hr-ud12' => ['sl-ud12', 'bg-ud12', 'cs-ud12'],
        'pl-ud12' => ['sl-ud12', 'bg-ud12', 'hr-ud12'],
        'ru' => ['hr', 'sk', 'pl'],
        'sk' => ['hr', 'sl', 'pl'],
        'sl-ud12' => ['cs-ud12', 'bg-ud12', 'hr-ud12'],
        'da-ud12' => ['bg-ud12', 'sv-ud12', 'no-ud12'],
        'de-ud12' => ['sl-ud12', 'bg-ud12', 'sv-ud12'],
        'en-ud12' => ['de-ud12', 'fr-ud12', 'sv-ud12'],
        'got-ud12' => ['cu-ud12', 'grc-ud12proiel', 'la-ud12proiel'],
        'nl-ud12' => ['de-ud12', 'pt-ud12', 'el-ud12'],
        'no-ud12' => ['sv-ud12', 'hr-ud12', 'bg-ud12'],
        'sv-ud12' => ['da-ud12', 'no-ud12', 'en-ud12'],
        'ca' => ['it', 'fr', 'es'],
        'es-ud12' => ['it-ud12', 'fr-ud12', 'ro-ud12'],
        'fr-ud12' => ['es-ud12', 'it-ud12', 'bg-ud12'],
        'it-ud12' => ['es-ud12', 'fr-ud12', 'ro-ud12'],
        'pt-ud12' => ['es-ud12', 'it-ud12', 'fr-ud12'],
        'ro-ud12' => ['it-ud12', 'es-ud12', 'id-ud12'],
        'el-ud12' => ['sl-ud12', 'hr-ud12', 'ro-ud12'],
        'grc-ud12' => ['grc-ud12proiel', 'got-ud12', 'la-ud12'],
        'grc-ud12proiel' => ['got-ud12', 'la-ud12proiel', 'grc-ud12'],
        'la-ud12' => ['la-ud12proiel', 'grc-ud12proiel', 'cu-ud12'],
        'la-ud12itt' => ['la-ud12', 'pl-ud12', 'hr-ud12'],
        'la-ud12proiel' => ['grc-ud12proiel', 'got-ud12', 'cu-ud12'],
        'ga-ud12' => ['he-ud12', 'ro-ud12', 'id-ud12'],
        'bn' => ['ja', 'te', 'ru'],
        'fa-ud12' => ['he-ud12', 'sl-ud12', 'grc-ud12proiel'],
        'hi-ud12' => ['ta-ud12', 'hu-ud12', 'et-ud12'],
        # Semitic
        'ar-ud12' => ['he-ud12', 'pl-ud12', 'got-ud12'],
        'he-ud12' => ['ro-ud12', 'id-ud12', 'es-ud12'],
        'eu-ud12' => ['hu-ud12', 'hi-ud12', 'et-ud12'],
        # Dravidian
        'ta-ud12' => ['hi-ud12', 'hu-ud12', 'eu-ud12'],
        'te' => ['bn', 'ja', 'tr'],
        # Uralic
        'et-ud12' => ['fi-ud12', 'hu-ud12', 'pl-ud12'],
        'fi-ud12' => ['fi-ud12ftb', 'da-ud12', 'et-ud12'],
        'fi-ud12ftb' => ['fi-ud12', 'la-ud12', 'et-ud12'],
        'hu-ud12' => ['bg-ud12', 'sv-ud12', 'et-ud12'],
        # Altaic
        'ja' => ['tr', 'he', 'grc'],
        'tr' => ['ta', 'la', 'hu'],
        # Austronesian
        'id-ud12' => ['hr-ud12', 'he-ud12', 'bg-ud12'],
    );
    my %pairs;
    foreach my $tgt (keys(%best))
    {
        my @src = ($tgt, @{$best{$tgt}});
        foreach my $src (@src)
        {
            $pairs{$tgt}{$src}++;
        }
    }
    return \%pairs;
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
            foreach my $size (10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 100000)
            {
                $konfig{trainlimit} = $size;
                my $dir = "$wdir/$treebank/$transformation/$size";
                # Create the working folder if it does not exist yet.
                # This will also create other folders in the path if necessary.
                system("mkdir -p $dir");
                # Change to the working folder.
                chdir($dir) or die("Cannot change to $dir: $!\n");
                # Run the action.
                &{$action}($treebank, $transformation, $size);
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
    my $fc = get_fc();
    my $delexfilename1 = $filename1;
    $delexfilename1 =~ s/\.conll$/.delex.conll/;
    print SCR ("/net/work/people/zeman/parsing/tools/conll_delexicalize.pl --keep-features=$fc < $filename1 > $delexfilename1\n");
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
    my $size = shift; # training size
    my $modeldir = shift; # for cross-language delexicalized training: where is the model?
    my $path = defined($modeldir) ? "$modeldir/$transformation/$size/" : '';
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
        my $fc = get_fc();
        $scenario .= "W2A::Delexicalize keep_iset=$fc "
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
    my $size = shift;
    my $language = $treebank;
    $language =~ s/-.*//;
    # Prepare the training script and submit the job to the cluster.
    foreach my $parser (get_parsers())
    {
        my %scenarios;
        # The delexicalized parser can use trained delexicalized models from any language/treebank, not necessarily its own.
        if($parser eq 'dlx')
        {
            # If the user restricted the set of treebanks, it was for target treebanks.
            # We must now remove the restriction, otherwise get_treebanks() will also apply it to source treebanks! ###!!!
            delete($konfig{treebanks});
            my @treebanks = get_treebanks();
            foreach my $srctbk (@treebanks)
            {
                # Skip delexicalized source models that have not been determined as promising.
                ###!!! Temporarily turning off because the data has changed and the delexicalized similarity of languages may have too.
                if(1 || $konfig{delexpairs}{$treebank}{$srctbk})
                {
                    my $dir = "$wdir/$srctbk";
                    $scenarios{$srctbk} = get_parsing_scenario($parser, $language, $transformation, $size, $dir);
                }
                else
                {
                    print("Skipping delexpair $treebank $srctbk.\n");
                }
            }
        }
        else
        {
            $scenarios{''} = get_parsing_scenario($parser, $language, $transformation, $size);
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
            # Shorten the script name so that the derived job name on the cluster is more descriptive.
            $scriptname =~ s/-ud\d*//g;
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
    my $size = shift;
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
        my $debug = 0;
        if(!open(UAS, $uas_file) && $debug)
        {
            print STDERR ("Cannot read $treebank/$transformation/$size/$uas_file: $!\n");
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
            if($sys =~ m/^${x}AS([pd](?:ms?)?)\(${language}_${selector},${language}\)$/)
            {
                my $uasparams = $1;
                $score = $score ? 100 * $score : 0;
                $value{$treebank}{$size}{$parser}{$uasparams} = round($score);
            }
        }
    }
}
sub get_labeled_results
{
    my $treebank = shift;
    my $transformation = shift;
    my $size = shift;
    return get_results($treebank, $transformation, $size, 1);
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
sub print_table
{
    my $metric = 'd'; # pms|d|...
    my @treebanks = sort(keys(%value));
    # Print results for each treebank in a separate table (but technically it will be one large table).
    my $table = Text::Table->new('&right', \' | ', '&right', \' | ', '&right', \' | ', '&right', \' | ', '&right', \' | ', '&right', \' | ', '&right', \' | ', '&right');
    foreach my $treebank (@treebanks)
    {
        my @sizes = sort {$a <=> $b} (keys(%{$value{$treebank}}));
        # The real maximum size is not 100,000 sentences but something smaller.
        my $wcconll = `wc_conll.pl $wdir/$treebank/02/100000/train.conll`;
        my $maxsize = 100000;
        if($wcconll =~ m/^(\d+)\s+sentences/)
        {
            $maxsize = $1;
        }
        # Collect parsers (identified by training treebanks) that produced at least one result for this target treebank.
        # Normally it would be enough to take the parsers from the largest size
        # but if we are retrieving a partial table before everything is done, the
        # list of parsers may not be complete there!
        my %parsers;
        my %best_sizes;
        for(my $i = 0; $i<=$#sizes; $i++)
        {
            my @parsers = keys(%{$value{$treebank}{$sizes[$i]}});
            foreach my $parser (@parsers)
            {
                my $parser_score = $value{$treebank}{$sizes[$i]}{$parser}{$metric};
                if(defined($parser_score) && (!defined($parsers{$parser}) || $parser_score > $parsers{$parser}))
                {
                    $parsers{$parser} = $parser_score;
                    $best_sizes{$parser} = $sizes[$i];
                }
            }
        }
        my @parsers = sort {$parsers{$b} <=> $parsers{$a}} (keys{%parsers});
        $table->add("Treebank: $treebank", @parsers);
        # Add scores for each size of each parser.
        foreach my $size (@sizes)
        {
            my $isize = $size > $maxsize ? $maxsize : $size;
            my $snt = sprintf("%5d sentences:", $isize);
            my @scores = map
            {
                my $score = $value{$treebank}{$size}{$_}{$metric};
                # Some parsers do not achieve the best score with the best size.
                # Mark scores that are lower than a score of a smaller size of the same parser.
                $score = "($score)" if($size > $best_sizes{$_});
                $score
            }
            (@parsers);
            $table->add($snt, @scores);
        }
        # Estimate how many training sentences of the smf parsing model each delexicalized model corresponds to.
        my @psignif = ('~ smf sents');
        # Extract scores of the smf parser for each treebank size.
        # For the purpose of this estimation make the sequence monotonic, i.e. artificially increase scores that were worse than a previous score.
        my @smfscores;
        foreach my $size (@sizes)
        {
            my $size_score = $value{$treebank}{$size}{smf}{$metric};
            if(scalar(@smfscores)>=1 && (!defined($size_score) || $size_score<=$smfscores[-1]))
            {
                $size_score = $smfscores[-1] + 0.01; # 0.01 %; our scores are in % and their precision is two decimal positions
            }
            push(@smfscores, $size_score);
        }
        foreach my $parser (@parsers)
        {
            my $score = $parsers{$parser};
            if ($score < $smfscores[0])
            {
                push(@psignif, 'USELESS');
            }
            elsif ($score > $smfscores[-1])
            {
                push(@psignif, 'BETTER!');
            }
            else
            {
                my $i = $#sizes;
                for(; $i>0 && $score < $smfscores[$i]; $i--)
                {
                }
                my $score0 = $smfscores[$i];
                my $score1 = $smfscores[$i+1];
                my $size0  = $sizes[$i];
                my $size1  = $sizes[$i+1] > $maxsize ? $maxsize : $sizes[$i+1];
                my $isents = sprintf("%d", ($score-$score0)/($score1-$score0)*($size1-$size0)+$size0+0.5);
                $isents = $maxsize if($isents>$maxsize);
                push(@psignif, $isents);
            }
        }
        $table->add(@psignif);
        $table->add(' ', ' ', ' ', ' ', ' ');
    }
    print($table->table());
    return;
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
# Prints a table of feature combinations (currently out of order, we do not
# generate experiments for different feature combinations).
#------------------------------------------------------------------------------
sub print_table_feature_combinations
{
    # The results are stored in the following structure:
    # $value{$treebank}{$fc}{$parser}{$uasparams}
    # We want to reorganize them to the following structure:
    # $result{$treebank.$parser}{$fc}
    # At the same time we want to know the best result (feature combination) for each $treebank.$parser pair.
    # We will use it to order parsers and drop the uninteresting ones.
    my %result;
    my %bestfc;
    my @datasets;
    my @treebanks = sort(keys(%value));
    foreach my $treebank (@treebanks)
    {
        my @fcs = keys(%{$value{$treebank}});
        foreach my $fc (@fcs)
        {
            my @parsers = keys(%{$value{$treebank}{$fc}});
            foreach my $parser (@parsers)
            {
                # We do not want to show the results of 'mlt'. It uses different algorithm than 'smf' and all the 'dlx*' parsers.
                next if($parser eq 'mlt');
                my $pms = $value{$treebank}{$fc}{$parser}{pms};
                if(defined($pms))
                {
                    $result{$treebank.' <= '.$parser}{$fc} = $pms;
                    if(!defined($bestfc{$treebank}{$parser}) || $pms > $bestfc{$treebank}{$parser})
                    {
                        $bestfc{$treebank}{$parser} = $pms;
                    }
                }
            }
        }
        # Order parsers for each treebank from the best to the worst. Forget results of bad parsers so that the table is not cluttered.
        my @parsers = sort {$bestfc{$treebank}{$b} <=> $bestfc{$treebank}{$a}} (keys(%{$bestfc{$treebank}}));
        for(my $i = 0; $i<=$#parsers; $i++)
        {
            my $dataset = $treebank.' <= '.$parsers[$i];
            if($i<10)
            {
                push(@datasets, $dataset);
            }
        }
    }
    # Create table with the header (which also defines the number of columns).
    my $table = Text::Table->new('data', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10');
    # For each data set ($treebank + $parser), rank the feature combinations.
    my %fcscore;
    foreach my $dataset (@datasets)
    {
        my @fcs = sort {$result{$dataset}{$b} <=> $result{$dataset}{$a}} keys(%{$result{$dataset}});
        $table->add($dataset, @fcs[0..9]);
        $table->add('', map {$result{$dataset}{$_}} (@fcs[0..9]));
        for(my $i = 0; $i<10; $i++)
        {
            $fcscore{$fcs[$i]} += $result{$dataset}{$fcs[$i]} / $result{$dataset}{$fcs[0]};
        }
    }
    my @fcs = sort {$fcscore{$b} <=> $fcscore{$a}} (keys(%fcscore));
    $table->add('GLOBAL', @fcs[0..9]);
    $table->add('', map {$fcscore{$_}} (@fcs[0..9]));
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
        # Get the date of the last modification of the file.
        # We can use it to only remove files older than a certain threshold.
        my $filedate = localtime((stat $file)[9])->ymd(''); # '' means empty separator; format is: 20000229
        next if($filedate > 20151231);
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
