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
my $wdir = 'pokus'; ###!!!
sub akce {my $l = shift; my $t = shift; print("$l\t$t\n");}
#my $action = \&akce;
my $action = \&create_conll_training_data;
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
