#!/usr/bin/env perl
use strict;
use warnings;

my %count;
my %test;

while (<>) {
    next unless(s/^HamleDT::Test:://);
    chomp;
    my ($test,$file) = split;
    $file =~ /hamledt\/([-a-z0-9]+)/
        or die "file doesn't match expected pattern: $file";
    my $treebank = $1;
    $count{$treebank}{$test}++;
    $count{$treebank}{TOTAL}++;
    $count{TOTAL}{$test}++;
    $count{TOTAL}{TOTAL}++;
    $test{$test} = 1;
}

my @treebanks = sort keys %count;
my @tests = (sort( keys %test), 'TOTAL');

# If there are multiple treebanks for a language, only one treebank (the selected one) is identified simply by the language code.
# The others use language code - treebank code, such as "cs-conll2007". Such identifiers are too long for the table, so we want
# to translate them to "cs0", "cs1" etc. and provide a legend below the table.
my %legend;
my %shortcut;
my $i = 0;
my $last_lngcode = '';
foreach my $treebank (@treebanks)
{
    my $lngcode = $treebank;
    my $tbkcode;
    if($treebank =~ m/^([a-z]+)-([a-z0-9]+)$/)
    {
        $lngcode = $1;
        $tbkcode = $2;
    }
    if($lngcode ne $last_lngcode)
    {
        $i = 0;
    }
    if($tbkcode)
    {
        my $shortcut = $lngcode.$i;
        $legend{$shortcut} = $treebank;
        $shortcut{$treebank} = $shortcut;
    }
    $last_lngcode = $lngcode;
    $i++;
}
my @shortreebanks = map {exists($shortcut{$_}) ? $shortcut{$_} : $_} (@treebanks);

use Text::Table;

my $tb = Text::Table->new(
        'Test / Treebank', @shortreebanks,
    );

$tb->load(
    map {
        my $test = $_;
        [$_, map {$count{$_}{$test} || 0} @treebanks]
    } @tests
);

print $tb;
my @legend = map {"$_=$legend{$_}"} (sort(keys(%legend)));
if(@legend)
{
    print('LEGEND: ', join(', ', @legend), "\n");
}
