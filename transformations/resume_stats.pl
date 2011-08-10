#!/usr/bin/env perl

use strict;
use warnings;

my %nodes;
my %rehanged_nodes;
my %directories;

while (<>) {
    chomp;
    my ( $language, $directory, $transformation ) = split;
    $directory =~ s/trans_//;
    $nodes{$language}{$directory}++;
    if ($transformation) {
        $rehanged_nodes{$language}{$directory}++;
    }
    $directories{$directory} = 1;
}

sub string30 {
    return sprintf("%-30s",shift);
}

my @languages = sort keys %nodes;

print string30(""),'   ',(join '    ',@languages),"\n";

foreach my $directory (sort keys %directories) {

    print string30($directory)," ";

    foreach my $language (@languages) {
        my $value;
        if ($nodes{$language}{$directory}) {
            $value = sprintf ("%.2f",100*($rehanged_nodes{$language}{$directory}||0)/$nodes{$language}{$directory});
        }
        else {
            $value = '???';
        }
        print sprintf("%5s",$value)." ";
    }
    print "\n";
}

