#!/usr/bin/env perl
# Breaks cycles in CoNLL treebank. Otherwise the CoNLLX Treex reader would not read it.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

# Empty first element of @tokens corresponds to the artificial root node.
@tokens = ([]);
while(<>)
{
    # Empty line separates sentences.
    if(m/^\s*$/)
    {
        if(@tokens)
        {
            # $ord, $form, $lemma, $cpos, $pos, $feat, $head, $deprel, $phead, $pdeprel
            # Build the tree, watch for cycles.
            my @parents = map {$_->[6]} (@tokens);
            for(my $i = 0; $i<=$#parents; $i++)
            {
                # Start at the i-th node, go to root, watch for cycles.
                my @map;
                my $lastj;
                for(my $j = $i; $j!=0; $j = $parents[$j])
                {
                    # If we visited the j-th node before, there is a cycle.
                    if($map[$j])
                    {
                        # Save the information about the original parent at deprel.
                        $tokens[$lastj][7] .= "-CYCLE:$j";
                        # Break the cycle.
                        $tokens[$lastj][6] = 0;
                        $parents[$lastj] = 0;
                    }
                    else # no cycle so far
                    {
                        $map[$j] = 1;
                        $lastj = $j;
                    }
                }
            }
            # Write the corrected tree.
            foreach my $token (@tokens)
            {
                print(join("\t", @{$token}), "\n");
            }
            print("\n");
        }
        @tokens = ([]);
    }
    else
    {
        s/\r?\n$//;
        my @token = split(/\t/, $_);
        push(@tokens, \@token);
    }
}
