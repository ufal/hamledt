#!/usr/bin/perl
# Used to process (tabularize) the output of Treex::Block::HamleDT::Test::Statistical::Afuns
# Copyright 2014 Jan Mašek <masek@ufal.mff.cuni.cz>
# License: GNU GPLv2 or any later version

use strict;
use warnings;

use feature 'say';

use Getopt::Std;
use List::Util qw( sum min max );

use open qw( :std :utf8 );

our $opt_n;
getopts('n'); # output normalized proportions (ie. proportion of afun in language divided by its average proportion across all languages in which it was found)
              # otherwise output a raw proportion of afuns in each language

# language statistics
my $afuns_in;
my $total_afuns_in;
my $afun_types_in;
my $afun_proportion_in;
my $norm_afun_proportion_in;

# afun statistics
my $count_of;
my $total_count_of;
my $lang_count_of;
my $proportion_of;
my $average_proportion_of;

# load the data
while ( defined( my $line = <> )) {
    chomp $line;
    my ($language, $count, $afun) = split /\s+/, $line;
    $afuns_in->{$language}->{$afun} += $count;
    $total_afuns_in->{$language}    += $count;
    $count_of->{$afun}->{$language} += $count;
    $total_count_of->{$afun}        += $count;
}

# get the remaining afun statistics
for my $afun (keys %$count_of) {
    $lang_count_of->{$afun} = scalar keys %{ $count_of->{$afun} };
    for my $language (keys %{ $count_of->{$afun} }) {
        $proportion_of->{$afun}->{$language} = $count_of->{$afun}->{$language} / $total_afuns_in->{$language}; # the same numbers as in %$afun_proportion_in
    }
    $average_proportion_of->{$afun} = sum( values %{ $proportion_of->{$afun} }) / scalar keys %{ $proportion_of->{$afun} };
}

# get the remaining language statistics
for my $language (sort keys %$afuns_in) {
    $afun_types_in->{$language} = scalar keys %{ $afuns_in->{$language} };
    for my $afun (keys %{ $afuns_in->{$language} }) {
        $afun_proportion_in->{$language}->{$afun} = $afuns_in->{$language}->{$afun} / $total_afuns_in->{$language};
        $norm_afun_proportion_in->{$language}->{$afun} = $afun_proportion_in->{$language}->{$afun} / $average_proportion_of->{$afun};
    }
}

# output
say join "\t", '', sort keys %$count_of; # header (names of afuns)
# main part of the table - proportions of afuns in languages; based on -n flag either normalized, or not
for my $language ( sort keys %$afuns_in ) {
    print "$language";
    for my $afun ( sort keys %$count_of ) {
        no warnings 'uninitialized';
        printf("\t%5.2f", $opt_n ? ($norm_afun_proportion_in->{$language}->{$afun} || 0) : (100 * $afun_proportion_in->{$language}->{$afun} || 0) );
    }
    print "\n";
}

# output in how many languages each afun is
print "CNT";
for my $afun ( sort keys %$count_of ) {
    print "\t", $lang_count_of->{$afun};
}
print "\n";

# output the average proportion of each afun across languages (unless the -n flag is set)
if (!$opt_n) {
    print "AVG";
    for my $afun ( sort keys %$count_of ) {
        printf("\t%5.2f", 100*$average_proportion_of->{$afun});
    }
    print "\n";
}
