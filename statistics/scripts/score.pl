#!/usr/bin/perl
# Compute a "quality score" of a treebank based on its perplexity, afuns and the results of tests
# Copyright 2014 Jan Mašek <masek@ufal.mff.cuni.cz>
# License: GNU GPLv2 or any later version

use strict;
use warnings;

use feature 'say';

use autodie;
use List::Util qw( sum );
use Getopt::Std;

use open qw( :std :utf8 );

my %filenames;
getopt('apt', \%filenames);

my $score_of;

# 
my $perplexity_of;
open my $PERPLEX_FH, '<', $filenames{p};
while( defined( my $line = <$PERPLEX_FH> )) {
    chomp $line;
    my ($language, $entropy, $perplexity) = split /\s+/, $line;
    $perplexity_of->{$language} = $perplexity;
}
close $PERPLEX_FH;

open my $AFUNS_FH, '<', $filenames{a};
my $line = <$AFUNS_FH>;
my (undef, undef, @languages) = split /\s+/, $line;
my ($afuns, $total_afuns);
LINE:
while( defined( my $line = <$AFUNS_FH> )) {
    my ($afun, $total, @counts) = split /\s+/, $line;
    for my $i (0..$#languages) {
        $afuns->{ $languages[$i] }->{$afun} = $counts[$i];
        $total_afuns->{ $languages[$i] } += $counts[$i];
    }
}
close $AFUNS_FH;

open my $TESTS_FH, '<', $filenames{t};
$line = <$TESTS_FH>;
# (undef, undef, @languages) = split /\s+/, $line;
my (@tests, $tests, $total_tests);
while( defined( my $line = <$TESTS_FH> )) {
    my ($test, $total, @counts) = split /\s+/, $line;
    $test =~ s/^HamleDT::Test:://;
    push @tests, $test;
    for my $i (0..$#languages) {
        $tests->{ $languages[$i] }->{$test} = $counts[$i];
        $total_tests->{ $languages[$i] } += $counts[$i];
    }
}
close $TESTS_FH;

my $weight_of;
for my $language ( @languages ) {
    my %test_instances
        = ( AfunDefined          => $afuns->{$language}->{TOTAL},
            AfunKnown            => $afuns->{$language}->{TOTAL},
            AfunNotNR            => $afuns->{$language}->{TOTAL},
#            AtvVBelowVerb        => $afuns->{$language}->{AtvV},
#            AuxAUnderNoun        => $afuns->{$language}->{AuxA},
#            AuxGIsPunctuation    => $afuns->{$language}->{AuxG},
#            AuxKAtEnd            => $afuns->{$language}->{AuxS},
#            AuxPNotMember        => $afuns->{$language}->{AuxP},
#            AuxVNotOnTop         => $afuns->{$language}->{AuxS},
#            AuxXIsComma          => $afuns->{$language}->{AuxX},
#            AuxZChilds           => $afuns->{$language}->{AuxZ},
            CoApAboveEveryMember => $afuns->{$language}->{TOTAL}, # should be the number of nodes with is_member=1
#            CoordStyle           => $afuns->{$language}->{Coord},
            FinalPunctuation     => $afuns->{$language}->{AuxS},
            LeafAux              => sum( $afuns->{$language}->{AuxT} || 0,
                                         $afuns->{$language}->{AuxR} || 0,
                                         $afuns->{$language}->{AuxX} || 0,
                                         $afuns->{$language}->{AuxA} || 0,
                                     ),
            MaxOneSubject        => $afuns->{$language}->{Sb}, # checks every node for Sb children
            MemberInEveryCoAp    => ($afuns->{$language}->{Apos} || 0) + ($afuns->{$language}->{Coord} || 0),
            MemberInEveryCoord   => $afuns->{$language}->{Coord},
            NonemptyAttr         => $afuns->{$language}->{TOTAL},
            NoNewNonProj         => $afuns->{$language}->{AuxS},
            NonleafAuxC          => $afuns->{$language}->{AuxC},
            NoneleafAuxP         => $afuns->{$language}->{AuxP},
#            NonParentAuxS        => $afuns->{$language}->{AuxS},
            NounGovernsDet       => $afuns->{$language}->{TOTAL}, # should be the number of nodes with iset subpos 'art'
#            NumberHavePosC       => $afuns->{$language}->{TOTAL}, # appropriate number unavailable here
#            PredHeadInterrogativePronoun => $afuns->{$language}->{TOTAL}, # appropriate number unavailable here
            PredUnderRoot        => $afuns->{$language}->{Pred},
            PrepIsAuxP           => $afuns->{$language}->{TOTAL}, # appropriate number unavailable here
#            PunctOnRoot          => $afuns->{$language}->{TOTAL}, # appropriate number anavailable here
#            PunctUnderCoord      => $afuns->{$language}->{Coord},
#            PunctUnderRoot       => $afuns->{$language}->{AuxS},
#            SingleEffectiveRootChild => $afuns->{$language}->{AuxS},
            SubjectBelowVerb     => $afuns->{$language}->{Sb},
        );

    use Data::Dumper;
 #   print $language, "\n", Dumper \%test_instances;
    $weight_of->{$language} = log( $total_afuns->{$language} );
    for my $test ( @tests ) {
        $score_of->{$language}->{TESTS}->{$test} = $test_instances{$test} ? ( $tests->{$language}->{$test} / $test_instances{$test} ) : 0;
    }
    $score_of->{$language}->{TOTAL} = 100 * sum( values %{ $score_of->{$language}->{TESTS} } ) / scalar( grep { $_ != 0 } values %{ $score_of->{$language}->{TESTS} } );
    $score_of->{TOTAL} += $weight_of->{$language} * $score_of->{$language}->{TOTAL};
    say join "\t", $language, scalar( grep { $_ != 0 } values %{ $score_of->{$language}->{TESTS} } ), $score_of->{$language}->{TOTAL}, $perplexity_of->{$language};
}
$score_of->{TOTAL} = $score_of->{TOTAL} / sum( values %$weight_of );
say join "\t", "TOTAL", $score_of->{TOTAL};
