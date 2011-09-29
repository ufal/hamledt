#!/usr/bin/env perl

use strict;
use warnings;

my %counts;

while (<>) {
    chomp;
    my %feature;
    my @columns = split;
    my $language = shift @columns;
    my $set = shift @columns;

    if (/is_root/) {
        $counts{$language}{sents}++
    }
    else {
        $counts{$language}{toks}++;
        $counts{$language}{$set}++;
        foreach my $column (@columns) {
            $counts{$language}{$column}++;
        }
    }
}

foreach my $langcode (sort keys %counts) {
    my $coords = $counts{$langcode}{is_coord_head} || 0;
    my $toks = $counts{$langcode}{toks};
    print join "\t",
        (
            $langcode,
            $counts{$langcode}{sents},
            $toks,

            sprintf("%.0f / %.0f",
                    100 * $counts{$langcode}{train} / $toks,
                    100 * $counts{$langcode}{test} / $toks),

            map {sprintf("%.2f",$_)} (
                100 * $coords / $toks,
                ($counts{$langcode}{is_member}||0) / ($coords || 1),
                ($counts{$langcode}{is_shared_modif}||0) / ($coords || 1),
                ($counts{$langcode}{is_nested}||0) / ($coords || 1),
                #($counts{$langcode}{is_coord_conjunction}||0) / ($coords || 1),
            )
        );
    print "\n";
}
