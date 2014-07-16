#!/usr/bin/env perl
# Filters a CoNLL 2006 file. Only those trees get through, in which all nodes have a non-empty DEPREL label.
# This is needed for the SETimes.HR corpus where there are mixed sentences with and without dependency annotation.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

my @sentence = ();
while(<>)
{
    chomp();
    if(m/^\s*$/)
    {
        # Check that every node has a non-empty DEPREL value (column No. 7).
        my $ok = 1;
        foreach my $node (@sentence)
        {
            my $deprel = $node->[7];
            if(!defined($deprel) || $deprel eq '' || $deprel eq '_')
            {
                $ok = 0;
                last;
            }
        }
        if($ok)
        {
            # The sentence is OK, let it to the output.
            foreach my $node (@sentence)
            {
                print(join("\t", @{$node}), "\n");
            }
            print("\n");
        }
        splice(@sentence);
    }
    else
    {
        my @fields = split(/\t/, $_);
        push(@sentence, \@fields);
    }
}
