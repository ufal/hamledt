#!/usr/bin/perl
# Used to process (tabularize) the output of Treex::Block::HamleDT::Test::Statistical::Afuns
# Copyright 2014 Jan Mašek <masek@ufal.mff.cuni.cz>
# License: GNU GPLv2 or any later version

use strict;
use warnings;

use feature 'say';

use List::Util qw( sum min max );

use open qw( :std :utf8 );

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
    my ($language, $afun) = split /\s+/, $line;
    $afuns_in->{$language}->{$afun}++;
    $afuns_in->{$language}->{TOTAL}++ unless $afun eq 'AuxS'; # AuxS is just a technical root
    $afuns_in->{TOTAL}->{$afun}++;
    $afuns_in->{TOTAL}->{TOTAL}++ unless $afun eq 'AuxS';
    $count_of->{$afun}->{$language}++;
}

my @languages = ( (sort keys %$afuns_in) );
my @afuns = ( (sort keys %$count_of), 'TOTAL' ) ;

# output
use Text::Table;

my $tb = Text::Table->new(
        'Afun/Language', @languages,
    );

$tb->load(
    map {
        my $afun = $_;
        [$_, map {$afuns_in->{$_}->{$afun} || 0} @languages]
    } @afuns
);

print $tb;

__END__
