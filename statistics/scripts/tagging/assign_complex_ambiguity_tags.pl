#!/usr/bin/perl
use warnings;
use strict;

use autodie;
use Getopt::Std;
use open qw( :std :utf8 );

my $FREQ_THRESHOLD = 0.01;
my $COUNT_THRESHOLD = 10;

our($opt_t, $opt_u, $opt_c, $opt_o, );
getopts('t:u:c:o:');

my $variation_trigrams_fn = $opt_t or die;
my $variation_unigrams_fn = $opt_u or die;
my $corpus_fn = $opt_c or die;

my $complex_corpus_output_fn = $opt_o || "STDOUT";

open my $TRIGRAMS, '<:encoding(utf-8)', $variation_trigrams_fn;
my %variation_words;
while (defined( my $line = <$TRIGRAMS> )) {
    chomp $line;
    my ($nucleus, $nucleus_tag, $total_count, $rest) = split "\t", $line, 4;
    $variation_words{$nucleus} = $total_count;
}
close $TRIGRAMS;

open my $UNIGRAMS, '<:encoding(utf-8)', $variation_unigrams_fn;
my %variation_lexicon;
my %tags;
while (defined( my $line = <$UNIGRAMS> )) {
    chomp $line;
    my ($total_count, $word, $counts_and_tags) = split "\t", $line, 3;
    $variation_lexicon{$word} = $total_count;
    my %word_tags = reverse split /\s/, $counts_and_tags;
    for my $tag (keys %word_tags) {
        if ($word_tags{$tag}/$variation_lexicon{$word} < $FREQ_THRESHOLD
                and $word_tags{$tag} < $COUNT_THRESHOLD) {
            delete $word_tags{$tag};
        }
    }
    if (scalar keys %word_tags > 1) {
        $tags{$word} = \%word_tags;
    }
}
close $UNIGRAMS;

my %ambiguity_classes;
for my $variation_word (keys %variation_words) {
    my $ac = join '/', keys %{$tags{$variation_word}};
    if ($ac =~ m/\S+/ ) {
        $ambiguity_classes{$ac} += 1;
    }
}

open my $CORPUS, '<:encoding(utf-8)', $corpus_fn;
while (defined( my $line = <$CORPUS> )) {
    chomp $line;
    my ($word, $tag) = split "\t", $line;
    my $new_tag;
    my $ac = join('/', keys %{$tags{$word}});
    if ($variation_words{$word}) {
        if ($tags{$word}->{$tag}) {
            $new_tag = '<' . "$ac" . ',' . "$tag" . '>';
        }
        else {
            $new_tag = $tag;
        }
    }
    else {
        if ($ambiguity_classes{$ac}) {
            $new_tag = '<' . "$ac" . ',' . "$tag" . '>';
        }
        else {
            $new_tag = $tag;
        }
    }
    print $word, "\t", $new_tag, "\n";
}
