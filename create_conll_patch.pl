#!/usr/bin/env perl
# Reads CoNLL-U file, removes form + lemma + pos and prints the result.
# This way we create a treebank patch that contains only universal POS tag + features and syntactic annotation.
# Such a file should be freely redistributable because it does not enable the users to reconstruct the original treebank;
# they must have obtained it separately from the legal distributor.
# Copyright © 2014, 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

sub usage
{
    print STDERR ("Usage: create_conll_patch.pl < full.conllu > patch.conllu\n");
}

my $i = 0;
while(<>)
{
    unless(m/^\s*$/ || m/^\#/)
    {
        my @fields = split(/\t/, $_);
        # From time to time keep full annotation of a few tokens so that the user can check synchronization with his own data.
        my $mod = $i % 1000;
        unless($mod==0 || $mod==1 || $mod==2)
        {
            # Keep field 0 (token id).
            # Erase fields 1 (word form), 2 (lemma) and 4 (pos).
            # Keep the rest.
            $fields[1] = '_';
            $fields[2] = '_';
            $fields[4] = '_';
        }
        $_ = join("\t", @fields);
    }
    print;
    $i++;
}
