#!/usr/bin/env perl
# Scans test.log, output of HamleDT tests. Filters hits matching a particular path.
# May change the path if desired (e.g. if we want to send the filelist to somebody who has a local
# copy of the tested files).
# May also filter only hits of one selected test.

# Usage:
# cat test.log | filter_test_log.pl

###!!! WINDOWS
# Make all paths relative (erase up to and including the last slash).
# On Windows, put it to the folder where the target Treex files are.
# Open cmd.exe and go to the folder with Tred (e.g. cd "C:\Program Files (x86)\tred").
# Run tred with the -l option pointing to the file list, e.g.
# tred.bat -l C:\Users\Dan\Documents\Lingvistika\Projects\...\copula.fl
# Alternatively, create a copy of tred.bat, call it tredfl.bat, insert the "-l" switch in it.
# Then tell the Windows shell that all *.fl files are to be opened by this batch script.

use utf8;
use Getopt::Long;

my $only_test_re = '.*'; # try 'UD::UnconvertedDependencies'
my $only_data_re = '.*'; # try '/net/work/people/zeman/unidep/UD_Uyghur/manually-checked-treex/'
my $replace_path = ''; # if $only_data_re is the full path except file name, this will make the file name relative to the working folder
my $sort_all_tests = 1; # automatically select a file name for each test, export all tests but each to its file

# The real setting is temporarily hard-wired. In the future it will be read from command-line options.
$only_test_re = 'UD::CopulaIsVerb';
$only_data_re = '/net/work/people/zeman/unidep/UD_Uyghur/manually-checked-treex/';

GetOptions('test=s' => \$only_test_re);

while(<>)
{
    # Example line:
    # HamleDT::Test::UD::UnconvertedDependencies      /net/work/people/zeman/unidep/UD_Uyghur/manually-checked-treex/001.treex.gz##1.n1       conj>dobj:cau
    s/\r?\n$//;
    my @fields = split(/\t/);
    my $filename;
    if($fields[0] =~ m/^HamleDT::Test::UD::(.+)$/)
    {
        $filename = 'test-'.lc($1).'.fl';
    }
    next unless($fields[1] =~ s/$only_data_re/$replace_path/);
    #next unless($fields[1] =~ m/$only_data_re/);
    push(@{$hash{$filename}}, $fields[1]);
    next unless($fields[0] =~ m/$only_test_re/);
    # Print only the middle field (path + node address). We are creating a file list for Tred.
    #print("$fields[1]\n");
}
# Write all file lists.
my @filenames = keys(%hash);
foreach my $filename (@filenames)
{
    open(FILE, ">$filename") or die("Cannot write $filename: $!");
    # Due to a bug, Tred will skip the first line of the file list. We will thus insert an empty line.
    print FILE ("\n");
    foreach my $hit (@{$hash{$filename}})
    {
        print FILE ("$hit\n");
    }
    close(FILE);
}