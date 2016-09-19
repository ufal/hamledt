#!/usr/bin/env perl
# Scans test.log, output of HamleDT tests. Filters hits matching a particular path.
# May change the path if desired (e.g. if we want to send the filelist to somebody who has a local
# copy of the tested files).
# May also filter only hits of one selected test.

###!!! WINDOWS
# Make all paths relative (erase up to and including the last slash).
# On Windows, put it to the folder where the target Treex files are.
# Open cmd.exe and go to the folder with Tred (e.g. cd "C:\Program Files (x86)\tred").
# Run tred with the -l option pointing to the file list, e.g.
# tred.bat -l C:\Users\Dan\Documents\Lingvistika\Projects\...\copula.fl

my $only_test_re = '.*'; # try 'UD::UnconvertedDependencies'
my $only_data_re = '.*'; # try '/net/work/people/zeman/unidep/UD_Uyghur/manually-checked-treex/'
my $replace_path = ''; # if $only_data_re is the full path except file name, this will make the file name relative to the working folder

# The real setting is temporarily hard-wired. In the future it will be read from command-line options.
$only_test_re = 'UD::CopulaIsVerb';
$only_data_re = '/net/work/people/zeman/unidep/UD_Uyghur/manually-checked-treex/';

# Due to a bug, Tred will skip the first line of the file list. We will thus insert an empty line.
my $empty_inserted = 0;
while(<>)
{
    # Example line:
    # HamleDT::Test::UD::UnconvertedDependencies      /net/work/people/zeman/unidep/UD_Uyghur/manually-checked-treex/001.treex.gz##1.n1       conj>dobj:cau
    s/\r?\n$//;
    my @fields = split(/\t/);
    next unless($fields[0] =~ m/$only_test_re/);
    next unless($fields[1] =~ s/$only_data_re/$replace_path/);
    # Print only the middle field (path + node address). We are creating a file list for Tred.
    unless($empty_inserted)
    {
        print("\n");
        $empty_inserted = 1;
    }
    print("$fields[1]\n");
}
