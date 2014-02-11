#!/usr/bin/perl
# Used to process (tabularize) the output of Treex::Block::HamleDT::Test::Statistical::Afuns
# Copyright 2014 Jan Mašek <masek@ufal.mff.cuni.cz>
# License: GNU GPLv2 or any later version

use strict;
use warnings;

use feature 'say';

use List::MoreUtils qw( uniq );

use open qw( :std :utf8 );

my $afuns_in;
my $total_afuns_in;
my $count_of;
my $total_count_of;

my $language = '';

LINE:
while ( defined( my $line = <> )) {
    chomp $line;
    $line =~ s/^\s+//;
    next LINE if ( $line eq '' ); # skip empty lines
    if ( $line =~ /^...?$/ ) {    # if there is just a two or three letter word on the line, it is a language code
        $language = $line;
        next LINE;
    }
    my ($count, $afun) = split /\s+/, $line;
    $afuns_in->{$language}->{$afun} += $count;
    $total_afuns_in->{$language}    += $count;
    $count_of->{$afun}->{$language} += $count;
    $total_count_of->{$afun}        += $count;
}

say join "\t", '', sort keys %$afuns_in; # print header - names of languages (from the 2nd column on)
for my $afun ( sort keys %$count_of ) {
    print "$afun";
    for my $language ( sort keys %{ $afuns_in } ) {
        my $percent = 100 * ( $afuns_in->{$language}->{$afun} || 0 ) / $total_afuns_in->{$language} ;
        printf("\t%5.2f", $percent);
    }
    print "\n";
}

__END__
