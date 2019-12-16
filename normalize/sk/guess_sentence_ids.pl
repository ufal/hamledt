#!/usr/bin/env perl
# Reads a CoNLL-X-like file where the FEATS column contains word id features
# (long ids containing the document and sentence ids, not just the numeric id
# that appears in the ID column). Tries to guess a suitable sentence id from
# the ids of all the words in the sentence.
# Copyright © 2019 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

my @sentence = ();
while(<>)
{
    push(@sentence, $_);
    if(m/^\s*$/)
    {
        process_sentence(@sentence);
        @sentence = ();
    }
}



#------------------------------------------------------------------------------
# Collects word ids of all words in a sentence and tries to guess the sentence
# id from them.
#------------------------------------------------------------------------------
sub process_sentence
{
    my @sentence = @_;
    my @wids;
    foreach my $line (@sentence)
    {
        if($line =~ m/^\d+\t/)
        {
            my @f = split(/\t/, $line);
            my $feats = $f[5];
            my @featsids = grep {m/^id=.+/} (split(/\|/, $feats);
            foreach my $id (@featsids)
            {
                if($id =~ m/^id=(.+)$/)
                {
                    push(@wids, $1);
                }
            }
        }
    }
    my $sid = get_common_prefix(@wids);
    # Too short a prefix is suspicious. It should include folder and file name!
    if(length($sid) < 5)
    {
        print STDERR ("WARNING: Too short sid: '$sid'\n");
    }
    # Make sure the sentence id is unique.
    if(exists($h{$sid}))
    {
        print STDERR ("WARNING: Avoiding duplicate '$sid'\n");
        for(my $i = 1;; $i++)
        {
            my $ssid = "$sid.$i";
            if(!exists($h{$ssid}))
            {
                $sid = $ssid;
                last;
            }
        }
        print STDERR ("=======> '$sid'\n");
    }
    # Store the sentence id with the nodes.
    foreach my $line (@sentence)
    {
        if($line =~ m/^\d+\t/)
        {
            my @f = split(/\t/, $line);
            my @feats = ();
            @feats = grep {!m/^sid=/} (split(/\|/, $f[5])) unless($f[5] eq '_');
            push(@feats, "sid=$sid");
            $f[5] = join('|', @feats);
            $line = join("\t", @f);
        }
        print($line);
    }
}



#------------------------------------------------------------------------------
# Finds the longest common prefix in a set of strings.
#------------------------------------------------------------------------------
sub get_common_prefix
{
    my @strings = @_;
    my $s1 = shift(@strings);
    if(scalar(@strings)==0)
    {
        return $s1;
    }
    else
    {
        my $s2 = get_common_prefix(@strings);
        my $l1 = length($s1);
        my $l2 = length($s2);
        my $l = $l1 <= $l2 ? $l1 : $l2;
        my @s1 = split(//, $s1);
        my @s2 = split(//, $s2);
        my $prefix = '';
        for(my $i = 0; $i < $l; $i++)
        {
            if($s1[$i] eq $s2[$i])
            {
                $prefix .= $s1[$i];
            }
            else
            {
                last;
            }
        }
        return $prefix;
    }
}
