#!/usr/bin/perl
# Used to compute afun bigrams conditional entropy of the individual languages from the output of Treex::Block::HamleDT::Test::Statistical::OutputAfunBigrams
# Copyright 2014 Jan Mašek <masek@ufal.mff.cuni.cz>
# License: GNU GPLv2 or any later version

use strict;
use warnings;

use feature 'say';
use List::Util qw( sum );

use open qw( :std :utf8 );

my ($bigrams, $parent_count, $total_count);

# load the data
while ( defined( my $line = <> )) {
    chomp $line;
    my ( $language, $parent_pos, $child_pos, $parent_afun, $child_afun, ) = split /\s+/, $line;
    $bigrams->{$language}->{$parent_afun}->{$child_afun}++;
    $parent_count->{$language}->{$parent_afun}++;
    $total_count->{$language}++;
}
my @languages = sort keys %$bigrams;
my ($joint_distribution, $conditional_distribution, $entropy, $perplexity);
for my $language ( @languages ) {
    for my $parent ( keys %{ $bigrams->{$language} } ) {
        for my $child ( keys %{ $bigrams->{$language}->{$parent} } ) {
            $joint_distribution->{$language}->{$parent}->{$child} = $bigrams->{$language}->{$parent}->{$child} / $total_count->{$language};
            $conditional_distribution->{$language}->{$parent}->{$child} = $bigrams->{$language}->{$parent}->{$child} / $parent_count->{$language}->{$parent};
        }
    }
    for my $parent ( keys %{ $bigrams->{$language} } ) {
        for my $child (keys %{ $bigrams->{$language}->{$parent} } ) {
            $entropy->{$language} += -1 * ( $joint_distribution->{$language}->{$parent}->{$child} )
                * log_2( $conditional_distribution->{$language}->{$parent}->{$child} );
        }
    }
}

use Text::Table;

my $tb = Text::Table->new(
    'Language', 'Entropy', 'Perplexity',
);

$tb->load( map { join "\t", $_, $entropy->{$_}, $entropy->{$_}**2  } @languages );

print $tb;


sub log_2 {
    my ($value) = @_;
    if ($value == 0) {
        return 0;
    }
    else {
        return log($value)/log(2);
    }
}

__END__

