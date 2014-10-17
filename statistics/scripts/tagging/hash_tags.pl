#!/usr/bin/env perl
use warnings;
use strict;

use autodie;
use open qw( :std :utf8 );

use Getopt::Std;
use JSON;


my $SENTENCE_SEPARATOR_TAG = 'pos=punc';

our($opt_c, $opt_d);
getopts('c:d:');

my $decompress_fn = $opt_d || '';
my $compress_fn = $opt_c || '';

if ($compress_fn) {
    my %tag_to_code;
    my $tag_code = 1;

    while (defined (my $line = <>)) {
        chomp $line;
        my ($word, $tag) = split "\t", $line;

        if (!defined $tag_to_code{$tag}) {
            if ($tag eq $SENTENCE_SEPARATOR_TAG) {
                $tag_to_code{$tag} = $tag;
            }
            else {
                $tag_to_code{$tag} = $tag_code;
                $tag_code++;
            }
        }
        print $word, "\t", $tag_to_code{$tag}, "\n";
    }
    my $tags_table = encode_json(\%tag_to_code);
    open my $COMPRESS_FH, '>:encoding(utf-8)', $compress_fn;
    print $COMPRESS_FH $tags_table, "\n";
    close $COMPRESS_FH;
}
elsif ($decompress_fn) {
    open my $DECOMPRESS_FH, '<:encoding(utf-8)', $decompress_fn;
    my $tags_table = <$DECOMPRESS_FH>;
    close $DECOMPRESS_FH;
    chomp $tags_table;
    my $tag_to_code = decode_json($tags_table);
    my %code_to_tag = reverse %$tag_to_code;

    while (defined (my $line = <>)) {
        chomp $line;
        my ($word, $tag_code) = split "\t", $line;
        print $word, "\t", $code_to_tag{$tag_code}, "\n";
    }
}
