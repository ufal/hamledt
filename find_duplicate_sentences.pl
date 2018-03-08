#!/usr/bin/env perl
# Reads sentences from CoNLL file, stores them in a hash, then reads sentences from another file and tries to find duplicates.
# Motivation: German UD lacks lemmas and features. But it is data from Google, which reportedly contains part of Tiger corpus. And we have morphology for Tiger, from CoNLL 2009.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

my ($f1, $f2) = @ARGV;
my %hash;
my $sentence = '';
my $skip_until;
open(IN, $f1) or die("Cannot read $f1: $!");
while(<IN>)
{
    next if(m/^\#/);
    # UD has split contractions ("zu dem") while CoNLL 2009 has "zum". Get the surface tokens when applicable.
    if(m/^(\d+)-(\d+)\t/)
    {
        $skip_until = $2;
        my @f = split(/\t/, $_);
        $sentence .= $f[1].' ';
    }
    elsif(m/^(\d+)\t/)
    {
        my $i = $1;
        if(defined($skip_until))
        {
            if($i<=$skip_until)
            {
                next;
            }
            else
            {
                $skip_until = undef;
            }
        }
        my @f = split(/\t/, $_);
        $sentence .= $f[1].' ';
    }
    else # empty line = end of sentence
    {
        $hash{$sentence}++;
        $sentence = '';
    }
}
close(IN);
open(IN, $f2) or die("Cannot read $f2: $!");
while(<IN>)
{
    next if(m/^\#/);
    next if(m/^\d+-/);
    if(m/^\d+\t/)
    {
        my @f = split(/\t/, $_);
        $sentence .= $f[1].' ';
    }
    else # empty line = end of sentence
    {
        if(exists($hash{$sentence}))
        {
            print("$sentence\n");
        }
        $sentence = '';
    }
}
close(IN);
