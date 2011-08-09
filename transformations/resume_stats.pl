#!/usr/bin/env perl

use strict;
use warnings;

my %transformations;
my %nodes;

while (<>) {
    chomp;
    my ($language,$transformation) = split;
    $nodes{$language}++;
    $transformations{$transformation}{$language}++ if $transformation ne 'unchanged';
}

sub string30 {
    return sprintf("%-30s",shift);
}

my @languages = sort keys %nodes;

print string30(""),'   ',(join '   ',@languages),"\n";

foreach my $transformation (keys %transformations) {

    print string30($transformation)," ",
        (join ' ', map {sprintf("%4s",sprintf "%.1f",100*$transformations{$transformation}{$_}/$nodes{$_})} @languages),"\n";
}

