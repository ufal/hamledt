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

    print join "\t",
        (
            $langcode,
            $counts{$langcode}{sents},
            $counts{$langcode}{toks},

            sprintf("%.0f / %.0f",
                    100 * $counts{$langcode}{train} / $counts{$langcode}{toks},
                    100 * $counts{$langcode}{test} / $counts{$langcode}{toks} ),

            map {sprintf("%.1f",$_)} (
                100 * ($counts{$langcode}{is_coord_head}||0) / $counts{$langcode}{toks},
                100 * ($counts{$langcode}{is_member}||0) / $counts{$langcode}{toks},
                100 * ($counts{$langcode}{is_shared_modif}||0) / $counts{$langcode}{toks},
            )
        );
    print "\n";
}
