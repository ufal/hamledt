#!/usr/bin/env perl

use strict;
use warnings;

my %transformations;
my %nodes;

while (<>) {
    chomp;
    my ($language,$transformation) = split;
    $transformation =~ s/trans_//;
    $nodes{$language}{$transformation}++;
    $transformations{$transformation}{$language}++ if $transformation ne 'unchanged';
}

sub string30 {
    return sprintf("%-30s",shift);
}

my @languages = sort keys %nodes;

print string30(""),'   ',(join '    ',@languages),"\n";

foreach my $transformation (keys %transformations) {

    print string30($transformation)," ";

    foreach my $language (@languages) {
        my $value;
        if ($nodes{$language}{$transformation}) {
            $value = sprintf ("%.1f",100*$transformations{$transformation}{$language}/$nodes{$language}{$transformation});
        }
        else {
            $value = '?'
        }

        print sprintf("%5s",$value)." ";
    }
    print "\n";
}

