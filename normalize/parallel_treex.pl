#!/usr/bin/env perl
# Processes a set of Treex files in the HamleDT ecosystem, in parallel on the
# cluster. Writes the modified files to the target folder.
# Copyright © 2023 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

# Typically we either run make prague or make ud. The former converts the input
# Treex files (00) to Prague-style HamleDT (01), the latter converts this to
# Universal Dependencies (02). If we are in the HamleDT normalize subfolder of
# the given treebank, the Treex files are accessible via a path like this:
# data/treex/{00,01,02}/{train,dev,test}/*.treex (or *.treex.gz)
# The total number of files can range from 1 to over 5000.

if(-d 'data/treex/00')
{
    my @files_treex = glob('data/treex/00/{train,dev,test}/*.treex');
    my @files_treex_gz = glob('data/treex/00/{train,dev,test}/*.treex.gz');
    my $nt = scalar(@files_treex);
    my $ntg = scalar(@files_treex_gz);
    print("In data/treex/00, there are $nt treex files and $ntg treex.gz files (train, dev and test combined).\n");
}
else
{
    die("Cannot find 'data/treex/00'");
}
