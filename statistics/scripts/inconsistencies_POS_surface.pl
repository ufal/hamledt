#!/usr/bin/perl
use warnings;
use strict;

use open qw( :std :utf8 );

use List::Util qw( sum );
use Getopt::Std;

our($opt_n);
getopts('n:');

my $n = $opt_n-1;

my %count;
my %ngrams;
my %address;

while( defined( my $line =  <> ) ) {
    chomp $line;
    my ($file, $forms, $IDs, $iset_feats) = split "\t", $line;
    my @forms = split ' ', $forms;
    my @IDs = split ' ', $IDs;
    my @iset_feats = split ' ', $iset_feats;
    for my $start (0..$#forms-$n) {
        my $end = $start + $n;
        my $ngram = join ' ', @forms[$start..$end];
        my $iset_feat = join ' ', @iset_feats[$start..$end];
        $ngrams{$ngram}{$iset_feat}++;
        $count{$ngram}++;
        push @{ $address{$ngram}{$iset_feat} },
            join(' ', $file, @IDs[$start..$end]);
        }
}

for my $ngram ( sort { $count{$b} <=> $count{$a} }
                    grep { scalar keys %{$ngrams{$_}} > 1 }
                        keys %ngrams ) {
    print "------$ngram------\n";
    print "($count{$ngram})\n";
    for my $iset_feat ( sort { $ngrams{$ngram}{$b}
                                   <=>
                               $ngrams{$ngram}{$a} }
                        keys %{$ngrams{$ngram}} ) {
        print $ngrams{$ngram}{$iset_feat}, "\t", $iset_feat, "\n";
    }
    print "\n";
}
