#!/usr/bin/perl
# Compute error rates of the HamleDT tests on all treebanks
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
getopt('apto', \%filenames);

# currently not used
# # conditional perplexities on dependency bigrams of afuns
# my %perplexity;
# open my $PERPLEX_FH, '<', $filenames{p};
# while( defined( my $line = <$PERPLEX_FH> )) {
#     chomp $line;
#     my ($language, $entropy, $perplexity) = split /\s+/, $line;
#     $perplexity{$language} = $perplexity;
# }
# close $PERPLEX_FH;

# afuns statistics
# currently only for determining how many times a specific test was run
# expects output of summarize_afuns.pl as $filenames{a}
# (languages in columns, tests in rows)
open my $AFUNS_FH, '<', $filenames{a};
my $line = <$AFUNS_FH>;
my (undef, @languages) = split /\s+/, $line;
my %afuns;
LINE:
while( defined( my $line = <$AFUNS_FH> )) {
    my ($afun, @counts) = split /\s+/, $line;
    for my $i (0..$#languages) {
        $afuns{ $languages[$i] }{$afun} = $counts[$i];
        $afuns{ $languages[$i] }{TOTAL} += $counts[$i];
    }
}
close $AFUNS_FH;

# results of tests
# expects output of summarize_tests.pl as $filenames{t}
# (languages in columns, tests in rows)
open my $TESTS_FH, '<', $filenames{t};
$line = <$TESTS_FH>;
# (undef, undef, @languages) = split /\s+/, $line;
my (@tests, %tests, %total_tests);
while( defined( my $line = <$TESTS_FH> )) {
    my ($test, @counts) = split /\s+/, $line;
    $test =~ s/^HamleDT::Test:://;
    push @tests, $test;
    for my $i (0..$#languages) {
        $tests{ $languages[$i] }{$test} = $counts[$i];
        $tests{ $languages[$i] }{TOTAL} += $counts[$i];
    }
}
close $TESTS_FH;

# for some tests, how many times they were passed
# expects output of summarize_ok_tests.pl as $filenames{o}
# (languages in columns, tests in rows)
open my $OK_TESTS_FH,  '<', $filenames{o};
$line = <$OK_TESTS_FH>;
# (undef, undef, @languages) = split /\s+/, $line;
my %ok_tests;
while( defined( my $line = <$OK_TESTS_FH> )) {
    my ($test, @counts) = split /\s+/, $line;
    $test =~ s/^HamleDT::Test:://;
    for my $i (0..$#languages) {
        $ok_tests{ $languages[$i] }{$test} = $counts[$i];
        $ok_tests{ $languages[$i] }{TOTAL} += $counts[$i];
    }
}
close $OK_TESTS_FH;

my %proportion; # error rates for each test and each language
my %weight; # for weighted average of error rates - log of treebank size (in number of nodes)
my %test_instances; # how many times each test was run in each language
for my $language ( @languages ) {
    $test_instances{$language}
        = { AfunDefined          => $afuns{$language}{TOTAL},
            AfunKnown            => $afuns{$language}{TOTAL},
            AfunNotNR            => $afuns{$language}{TOTAL},
            AtvVBelowVerb        => $afuns{$language}{AtvV},
            AuxAUnderNoun        => $afuns{$language}{AuxA},
            AuxGIsPunctuation    => $afuns{$language}{AuxG},
#            AuxKAtEnd            => $afuns{$language}{AuxS},
            AuxPNotMember        => $afuns{$language}{AuxP},
            AuxVNotOnTop         => $afuns{$language}{AuxS},
            AuxXIsComma          => $afuns{$language}{AuxX},
            AuxZChilds           => ($ok_tests{$language}{AuxZChilds} || 0)
                                     + ($tests{$language}{AuxZChilds} || 0),
            CoApAboveEveryMember => ($ok_tests{$language}{CoApAboveEveryMember} || 0)
                                     + ($tests{$language}{CoApAboveEveryMember} || 0),
#            CoordStyle           => $afuns{$language}{Coord},
            FinalPunctuation     => $afuns{$language}{AuxS},
            LeafAux              => sum( $afuns{$language}{AuxT} || 0,
                                         $afuns{$language}{AuxR} || 0,
                                         $afuns{$language}{AuxX} || 0,
                                         $afuns{$language}{AuxA} || 0,
                                     ),
            MaxOneSubject        => $afuns{$language}{Sb}, # checks every node for Sb children
            MemberInEveryCoAp    => ($ok_tests{$language}{MemberInEveryCoAp} || 0)
                                     + ($tests{$language}{MemberInEveryCoAp} || 0),
            MemberInEveryCoord   => $afuns{$language}{Coord},
            NonemptyAttr         => $afuns{$language}{TOTAL},
            NoNewNonProj         => $afuns{$language}{AuxS},
            NonleafAuxC          => $afuns{$language}{AuxC},
            NoneleafAuxP         => $afuns{$language}{AuxP},
            NonParentAuxS        => $afuns{$language}{TOTAL},
            NounGovernsDet       => ($ok_tests{$language}{NounGovernsDet} || 0)
                                     + ($tests{$language}{NounGovernsDet} || 0),
            NumberHavePosC       => ($ok_tests{$language}{NumberHavePosC} || 0)
                                     + ($tests{$language}{NumberHavePosC} || 0),
#            PredHeadInterrogativePronoun => $afuns{$language}{TOTAL}, # appropriate number unavailable here
            PredUnderRoot        => $afuns{$language}{Pred},
            PrepIsAuxP           => ($ok_tests{$language}{PrepIsAuxP} || 0)
                                     + ($tests{$language}{PrepIsAuxP} || 0),
#            PunctOnRoot          => $afuns{$language}{TOTAL}, # appropriate number unavailable here
#            PunctUnderCoord      => $afuns{$language}{Coord},
#            PunctUnderRoot       => $afuns{$language}{AuxS},
            SingleEffectiveRootChild => $afuns{$language}{AuxS},
            SubjectBelowVerb     => ($ok_tests{$language}{SubjectBelowVerb} || 0)
                                     + ($tests{$language}{SubjectBelowVerb} || 0),
        };

    $weight{$language} = log( $afuns{$language}{TOTAL} );
    for my $test ( @tests ) {
        $proportion{$language}{$test} = $test_instances{$language}{$test} ? ( $tests{$language}{$test} / $test_instances{$language}{$test} ) : '0';
    }
    $proportion{$language}{TOTAL} = sum( @{$proportion{$language}}{@tests} ) / scalar( grep { $_ != 0 } @{$proportion{$language}}{@tests} );
}

use Text::Table;

my $tb = Text::Table->new(
        'Test/Language',@languages,
    );

my $total_error_score = 100 * sum( map { $weight{$_} * $proportion{$_}{TOTAL} } @languages[1..$#languages] ) / sum( values %weight );

for my $test ( @tests ) {
    $tb->load( [$test, map { sprintf "%.0f%%", 100 * ($proportion{$_}{$test} || 0) } @languages] );
    $tb->load( ['', map { _magnitude($tests{$_}{$test} || 0) } @languages] );
}
$tb->load( ['TESTS NOT PASSED', map { scalar( grep {$_ != 0} values %{$proportion{$_}} ) }  @languages] );
$tb->load( ['ERRORS/NODES', map { sprintf "%.1f", 100 * $tests{$_}{TOTAL}/$afuns{$_}{TOTAL} } @languages ] );
#$tb->load( ['ERROR SCORE', (sprintf "%.1f", $total_error_score), map {sprintf "%.1f", 100 * ($proportion{$_}{TOTAL} || 0) }  @languages[1..$#languages] ] );
#$tb->load( ['WEIGHT', '', map { sprintf "%.1f", $weight{$_} } @languages[1..$#languages] ] );
print $tb->table();
printf "LOG-WEIGHTED AVERAGE ERROR SCORE: %.1f\n", $total_error_score;


sub _magnitude {
    my $num = shift;
    my $len = length($num);
    my $magnitude;
    if ($num == 0) {
        $magnitude = '-';
    }
    elsif ($len <= 3) {
        $magnitude = $num;
    }
    elsif ($len <= 6) {
        $magnitude = substr($num,0,$len-3) . 'k';
    }
    else {
        $magnitude = '>1M'
            }
    return $magnitude;
}
