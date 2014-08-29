#!/usr/bin/perl
use warnings;
use strict;

use open qw( :std :utf8 );

use List::Util qw( sum );
use List::MoreUtils qw( any );
use Getopt::Std;
use autodie;
use Text::Table;

my %opts;
getopts('i:x:n:c:', \%opts);

# file with the sentences in the pseudo-CoNNL format
# (output of HamleDT::Util::ExtractSurfaceNGrams)
my $source_file = $opts{i};

# minimal length of ngrams
my $MIN_NGRAM = $opts{n} || 3;

# maximal length of ngrams
my $MAX_NGRAM = $opts{x} || 10;

# number of words at the beginning/end of the ngram that serve only
# as context - we do not look for inconsistencies there
my $CONTEXT_SIZE = $opts{c} || 1;


my %count;
my %unigrams;
my @sentences;

{
    local $/=""; # read the file by sentence-sized chunks
    open my $SURFACE, '<:encoding(utf-8)', $source_file;
    while( defined(my $sentence = <$SURFACE> ) ) {
        chomp $sentence;
        my @words;
        for my $line (split "\n", $sentence) {
            chomp $line;

            my ($ord, $form, $iset, $p_ord, $fn, $id)
                = split "\t", $line;
            my $rest;
            ($iset, $rest) = split /\|/, $iset, 2;
            my %word = (
#                ord   => $ord,
                form  => $form,
                iset  => $iset,
#                p_ord => $p_ord,
                id    => $id,
            );
            push @words, \%word;

            $unigrams{$form}{$iset}++;
            $count{$form}++;
        }
        push @sentences, \@words;
    }
    close $SURFACE;
}

# keep only unigrams with at least two different sets of iset features
for my $unigram (keys %unigrams) {
    if ( scalar keys %{ $unigrams{$unigram} } < 2 ) {
        delete $count{$unigram};
        delete $unigrams{$unigram};
    }
}

%unigrams = ();
print STDERR "UNIGRAMS FINISHED\n";


my %ngrams;
my %nucleii;
for my $words (@sentences) {
    my @words = @$words;

    # add an empty word marking the beginning/end of the sentence
    my %sentence_start = (
#        ord => -1,
        form => '**START**',
        iset => '_',
#        p_ord => '-1',
        id=> '_',
    );
    unshift @words, \%sentence_start;
    $count{'**START**'} = 0;

    my %sentence_end = (
#        ord => inf,
        form => '**END**',
        iset => '_',
#        p_ord => inf,
        id=> '_',
    );
    push @words, \%sentence_end;
    $count{'**END**'} = 0;

    my @forms = map { $_->{form} } @words;
  START:
    for my $start (0..$#words-2) {
      END:
        for my $end ($start+$MIN_NGRAM-1..$start+$MAX_NGRAM-1) {
            next START if ($end > $#words);
            my ($start_modifier, $end_modifier) = (0, 0);
#           $start_modifier = scalar grep { $_ =~ m{^\p{punctuation}$} } @forms[$start..$start+$CONTEXT_SIZE];
            $start -= $start_modifier;
#           $end_modifier = scalar grep { $_ =~ m{^\p{punctuation}$}} @forms[$end-$CONTEXT_SIZE, $end];
            $end += $end_modifier;
#            next START if ($start < 0 or $end > $#words);

            my @possible_nucleii = @forms[$start+$CONTEXT_SIZE..$end-$CONTEXT_SIZE];
            my @nucleii = grep { $count{$_} } @possible_nucleii;
            next END unless ( scalar @nucleii != 0 );
            my $ngram = join ' ', @forms[$start..$end];
            my $iset = join(' ', ('_ 'x($start_modifier+$CONTEXT_SIZE), (map { $_->{iset} }
                                @words[$start+$start_modifier+$CONTEXT_SIZE..$end-$end_modifier-$CONTEXT_SIZE]), '_ 'x($end_modifier+$CONTEXT_SIZE))
                            );
            $ngrams{$ngram}{$iset}++;
            $count{$ngram}++;
        }
    }
}

@sentences = ();

print STDERR "NGRAMS LOADED\n";

my %pruned_ngrams;
while( my ($ngram, $isets) = each %ngrams ) {
    if (keys %{$ngrams{$ngram}} > 1) {
        $pruned_ngrams{$ngram} = $ngrams{$ngram};
    }
}

%ngrams = ();

print STDERR "NGRAMS PRUNED\n";

my $types = scalar keys %pruned_ngrams;
my $tokens = 0;
for my $ngram (keys %pruned_ngrams) {
    $tokens += sum(values %{$pruned_ngrams{$ngram}});
}
print $types, "\t", $tokens, "\n";


NGRAM:
#while( my($ngram, $iset) = each %pruned_ngrams ) {
for my $ngram (
    sort {
        scalar(@{ [split ' ', $b] }) <=> scalar(@{ [split ' ', $a] })
              or
        $count{$b} <=> $count{$a}
    }
        keys %pruned_ngrams ) {

#    next NGRAM unless ($count{$ngram} > 2);

    my $tb = Text::Table->new();
    $tb->load( $count{$ngram} . ' '. $ngram);

#    print "($count{$ngram})", "\n";
#    print join("\t", split(' ',$ngram)), "\n";
    for my $iset_feat ( sort { $pruned_ngrams{$ngram}{$b}
                                   <=>
                               $pruned_ngrams{$ngram}{$a} }
                        keys %{$pruned_ngrams{$ngram}} ) {
#        print $pruned_ngrams{$ngram}{$iset_feat}, "\t",
#            join("\t", split(' ',$iset_feat)), "\n";
        $tb->load( $pruned_ngrams{$ngram}{$iset_feat} . ' ' . $iset_feat );
    }
    print "$tb\n";
}
