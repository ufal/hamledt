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

use Text::Table;

my $tb = Text::Table->new(
        'Test / Treebank', @treebanks,
    );

$tb->load(
    map {
        my $test = $_;
        [$_, map {$count{$_}{$test} || 0} @treebanks]
    } @tests
);

print $tb;
