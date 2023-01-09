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
use cluster; # Dan's library for the ÚFAL cluster

# Typically we either run make prague or make ud. The former converts the input
# Treex files (00) to Prague-style HamleDT (01), the latter converts this to
# Universal Dependencies (02). If we are in the HamleDT normalize subfolder of
# the given treebank, the Treex files are accessible via a path like this:
# data/treex/{00,01,02}/{train,dev,test}/*.treex (or *.treex.gz)
# The total number of files can range from 1 to over 5000.

if(!-d 'data/treex/00')
{
    die("Cannot find 'data/treex/00'");
}
my @files_treex = glob('data/treex/00/{train,dev,test}/*.treex');
my @files_treex_gz = glob('data/treex/00/{train,dev,test}/*.treex.gz');
my $nt = scalar(@files_treex);
my $ntg = scalar(@files_treex_gz);
print("In data/treex/00, there are $nt treex files and $ntg treex.gz files (train, dev and test combined).\n");
if($ntg > 0)
{
    die("Processing treebanks with gzipped Treex files is currently not supported");
}
if($nt > 300)
{
    die("Processing treebanks with more than 300 Treex files is currently not supported");
}
# For each input file, submit a separate Treex job to the cluster.
# make prague (for cs-cltt) = treex -Lcs A2A::CopyAtree source_selector='' selector='orig' HamleDT::CS::Harmonize iset_driver=cs::pdt Write::Treex substitute={00}{01} compress=0 -- '!/net/work/people/zeman/hamledt-data/cs-cltt/treex/00/{train,dev,test}/*.treex'
my $command = 'treex -Lcs';
$command .= " A2A::CopyAtree source_selector='' selector='orig'";
$command .= " HamleDT::CS::Harmonize iset_driver=cs::pdt";
$command .= " Write::Treex substitute={00}{01} compress=0";
for my $f (@files_treex)
{
    my $fcommand = "$command -- $f";
    my $jobid = cluster::qsub('command' => $fcommand);
    print STDERR ("$f => $jobid\n");
}
