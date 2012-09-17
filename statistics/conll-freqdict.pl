#!/usr/bin/env perl
# Collects and counts values in a given column of a CoNLL treebank file.
# Copyright © 2012 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

sub usage
{
    print STDERR ("Usage: conll-freqdict.pl <column>\n");
    print STDERR ("\tDefault column is 1, i.e. the word forms.\n");
    print STDERR ("\tNames of columns in the CoNLL 2006 format:\n");
    print STDERR ("\t0=ord 1=form 2=lemma 3=cpos 4=pos 5=feat 6=head 7=deprel 8=phead 9=pdeprel\n");
}

my $column = scalar(@ARGV) ? $ARGV[0] : 1;
if($column !~ m/^\d+$/)
{
    usage();
    die;
}
my %mapa;
while(<>)
{
    # Strip line breaks.
    s/\r?\n$//;
    # Skip empty lines (sentence boundaries).
    next if(m/^\s*$/);
    # Split the line to columns.
    my @fields = split(/\s+/, $_);
    $mapa{$fields[$column]}++;
}
# Sort the words/tags in descending order of frequency.
my @words = sort {$mapa{$b} <=> $mapa{$a}} (keys(%mapa));
foreach my $word (@words)
{
    print("$word\t$mapa{$word}\n");
}
print("TOTAL ", scalar(@words), " TYPES\n");
