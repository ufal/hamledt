#!/usr/bin/perl
# Used to process (tabularize) the output of Treex::Block::HamleDT::Test::Statistical::OutputAfunBigrams
# Copyright 2014 Jan Mašek <masek@ufal.mff.cuni.cz>
# License: GNU GPLv2 or any later version

use strict;
use warnings;

use feature 'say';

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
    my ( $language, $parent_pos, $child_pos, $parent_afun, $child_afun, ) = split /\s+/, $line;
    my $bigram = join '-', ( $parent_afun, $child_afun );
    $afuns_in->{$language}->{$bigram}++;
    $afuns_in->{$language}->{TOTAL}++;
    $afuns_in->{TOTAL}->{$bigram}++;
    $afuns_in->{TOTAL}->{TOTAL}++;
    $count_of->{$bigram}->{$language}++;
}

my @languages = ( (sort keys %$afuns_in) );
my @afuns = ( (sort keys %$count_of), 'TOTAL' ) ;

# output
use Text::Table;

my $tb = Text::Table->new(
        'ParentAfun-ChildAfun/Language', @languages,
    );

$tb->load(
    map {
        my $afun = $_;
        [$_, map {$afuns_in->{$_}->{$afun} || 0} @languages]
    } @afuns
);

print $tb;

__END__
