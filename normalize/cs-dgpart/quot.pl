#!/usr/bin/env perl
# Checks quotation marks in Czech CoNLL-U.
# Copyright © 2017 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

my %h;
my $before = 'space';
my $after = 'space';
my $opened; # the opening mark if we are currently in a quoted string
my $function; # opening or closing
while(<>)
{
    if(m/^\d+\t/)
    {
        s/\r?\n$//;
        my @f = split(/\t/, $_);
        my $form = $f[1];
        # We currently ignore multi-word tokens and possible SpaceAfter=No marked at them.
        if($f[9] =~ m/SpaceAfter=No/)
        {
            $after = 'nospace';
        }
        else
        {
            $after = 'space';
        }
        # Check quotation marks.
        if($form =~ m/["“”„"]/)
        {
            # '„' should always be the Czech opening mark.
            if($form eq '„')
            {
                $function = 'opening';
                if(defined($opened))
                {
                    print STDERR ("WARNING: encountered the Czech opening mark '„' but the previous quotation has not been closed.\n");
                }
                if($after eq 'space')
                {
                    print STDERR ("WARNING: encountered the Czech opening mark '„' followed by a space.\n");
                }
                $opened = $form;
            }
            # '“' can be the Czech closing mark or the English opening mark.
            elsif($form eq '“')
            {
                if(defined($opened) && ($opened eq '„' || $opened eq '"'))
                {
                    # Assuming it is the Czech closing mark.
                    $function = 'closing';
                    if($before eq 'space')
                    {
                        print STDERR ("WARNING: encountered the Czech closing mark '“' preceded by a space.\n");
                    }
                    $opened = undef;
                }
                else
                {
                    # Assuming it is the English opening mark.
                    $function = 'opening';
                    if(defined($opened))
                    {
                        print STDERR ("WARNING: encountered the English opening mark '“' but the previous quotation has not been closed.\n");
                    }
                    if($after eq 'space')
                    {
                        print STDERR ("WARNING: encountered the English opening mark '“' followed by a space.\n");
                    }
                    $opened = $form;
                }
            }
            # '”' should always be the English closing mark.
            elsif($form eq '”')
            {
                $function = 'closing';
                if(!defined($opened))
                {
                    print STDERR ("WARNING: encountered the English closing mark '”' but no quotation is currently opened.\n");
                }
                if($before eq 'space')
                {
                    print STDERR ("WARNING: encountered the English closing mark '”' preceded by a space.\n");
                }
                $opened = undef;
            }
            # '"' can be opening or closing mark in any language.
            elsif($form eq '"')
            {
                if(defined($opened))
                {
                    # Assuming it is a closing mark.
                    $function = 'closing';
                    if($before eq 'space')
                    {
                        print STDERR ("WARNING: encountered the ASCII quotation mark, presumably closing but preceded by a space.\n");
                    }
                    $opened = undef;
                }
                else
                {
                    # Assuming it is an opening mark.
                    $function = 'opening';
                    if($after eq 'space')
                    {
                        print STDERR ("WARNING: encountered the ASCII quotation mark, presumably opening but followed by a space.\n");
                    }
                    $opened = $form;
                }
            }
            $h{"$before $form $after $function"}++;
            # Mark positions where quotation marks have to be fixed.
            # The actual change will be done later in Treex and the sentence-level attribute text will be fixed as well.
            my $todo;
            if($function eq 'opening' && $form ne '„')
            {
                $todo = 'ToDo=OpeningQuote';
            }
            elsif($function eq 'closing' && $form ne '“')
            {
                $todo = 'ToDo=ClosingQuote';
            }
            if(defined($todo))
            {
                my @misc;
                unless($f[9] eq '_')
                {
                    @misc = split(/\|/, $f[9]);
                }
                push(@misc, $todo);
                $f[9] = join('|', @misc);
            }
        }
        # Check hyphen vs. dash.
        elsif($form eq '-' && $before eq 'space' && $after eq 'space')
        {
            my @misc;
            unless($f[9] eq '_')
            {
                @misc = split(/\|/, $f[9]);
            }
            push(@misc, 'ToDo=HyphenToDash');
            $f[9] = join('|', @misc);
        }
        $before = $after;
        $_ = join("\t", @f)."\n";
    }
    print;
}
my @k = sort(keys(%h));
foreach my $k (@k)
{
    print STDERR ("$k\t$h{$k}\n");
}
