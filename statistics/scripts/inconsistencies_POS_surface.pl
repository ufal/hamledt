#!/usr/bin/perl
use warnings;
use strict;

use open qw( :std :utf8 );

use List::MoreUtils qw( any );
use Getopt::Std;
use autodie;

our($opt_f);
getopts('f:');

my $source_file = $opt_f;

my %count;
my %unigrams;

open my $SURFACE, '<:encoding(utf-8)', $source_file;
while( defined( my $line = <$SURFACE> ) ) {
    chomp $line;
    my ($file, $forms, $IDs, $iset_feats) = split "\t", $line;
    my @forms = split ' ', $forms;
    my @IDs = split ' ', $IDs;
    my @iset_feats = split ' ', $iset_feats;
    for my $i (0..$#forms) {
        my $unigram = $forms[$i];
        my $ID = $IDs[$i];
        my $iset_feats = $iset_feats[$i];
        $unigrams{$unigram}{$iset_feats}++;
        $count{$unigram}++;
#        my $address = $file . '##' . $ID;
#        $addresses{$address}
    }
}
close $SURFACE;

# keep only unigrams with at least two different sets of iset features
for my $unigram (keys %unigrams) {
    if ( scalar keys %{ $unigrams{$unigram} } < 2 ) {
        delete $unigrams{$unigram};
    }
}

my %ngrams;
open $SURFACE, '<:encoding(utf-8)', $source_file;
while( defined( my $line = <$SURFACE> ) ) {
    chomp $line;
#    print STDERR "$. ";
    my ($file, $forms, $IDs, $iset_feats) = split "\t", $line;
    my @forms = split ' ', $forms;
    my @IDs = split ' ', $IDs;
    my @iset_feats = split ' ', $iset_feats;
    for my $start (0..$#forms) {
        for my $end ($start..$#forms) {
            next unless ( any { $unigrams{$_} } @forms[$start..$end] );
            my $ngram = join ' ', @forms[$start..$end];
            my $iset_feats = join ' ', @iset_feats[$start..$end];
            $ngrams{$ngram}{$iset_feats}++;
            $count{$ngram}++;
        }
    }
}
close $SURFACE;


#print STDERR "NGRAMS LOADED\n";
#__END__

for my $ngram (keys %ngrams) {
    if ( scalar keys %{ $ngrams{$ngram} } < 2 ) {
        delete $ngrams{$ngram};
    }
}

# print STDERR "NGRAMS PRUNED\n";

for my $ngram ( sort { scalar(@{ [split ' ', $b] }) <=> scalar(@{ [split ' ', $a] }) or $count{$b} <=> $count{$a} }
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
