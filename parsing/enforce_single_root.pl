#!/usr/bin/env perl
# Reads a CoNLL-U file and makes sure that there is just one node depending on the artificial root in every sentence.
# If it finds another one, it re-attaches it to the first one via the "parataxis" relation.
# Copyright © 2017 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Getopt::Long;

my $root_found = 0;
while(<>)
{
    if(m/^\d+\t/)
    {
        my @fields = split(/\t/, $_);
        my $id = $fields[0];
        my $head = $fields[6];
        if($head==0)
        {
            if($root_found)
            {
                $fields[6] = $root_found;
                $fields[7] = 'parataxis';
            }
            else
            {
                $root_found = $id;
                $fields[7] = 'root'; # just in case
            }
            $_ = join("\t", @fields);
        }
    }
    elsif(m/^\s*$/)
    {
        $root_found = 0;
    }
    print;
}