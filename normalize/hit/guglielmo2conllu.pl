#!/usr/bin/env perl
# Converts Guglielmo's pseudo-CoNLL-U to CoNLL-U.
# Copyright © 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':encoding(cp1250)');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

while(<>)
{
    s/\r?\n$//;
    my $line = $_;
    # If the input file was exported from Microsoft Excel, empty lines actually contain empty columns!
    # Worse: sometimes the empty line is not empty and the tenth column is filled by mistake.
    if($line =~ m/^\s*$/ || $line =~ m/^\s/)
    {
        $line = '';
    }
    # Comments need no change.
    # Multi-word token lines sometimes need attention because they contain values in the extra columns.
    elsif($line !~ m/^\#/)
    {
        # CoNLL-U columns:     ID FORM LEMMA UPOS POS    FEAT HEAD DEPREL DEPS   MISC
        # Guglielmo's columns: ID FORM LEMMA UPOS NTRANS FEAT HEAD DEPREL HLEMMA PHIL
        my @fields = split(/\t/, $line);
        # If the input file was exported from Microsoft Excel, the first line may contain column headers.
        next if($fields[0] =~ m/^ID/);
        # Empty columns are not allowed.
        for(my $i = 0; $i<10; $i++)
        {
            if(!defined($fields[$i]) || $fields[$i] =~ m/^\s*$/)
            {
                $fields[$i] = '_';
            }
        }
        # No spaces are allowed inside columns.
        @fields = map {s/ /_/g; $_} (@fields);
        # We can treat the last column (PHIL) as if it was called MISC already.
        # But we will have to add new features to that column.
        my @misc;
        @misc = split(/\|/, $fields[9]) if(defined($fields[9]) && $fields[9] ne '' && $fields[9] ne '_');
        # The DEPS column will be empty and HLEMMA must be stored in MISC.
        if(defined($fields[8]) && $fields[8] ne '' && $fields[8] ne '_')
        {
            unshift(@misc, "Hlemma=$fields[8]");
            $fields[8] = '_';
        }
        # NTRANS occupies the POS column, which is not strictly constrained, but
        # the values clearly do not have anything to do with tagging, so it will be better
        # to move them to MISC, too.
        if(defined($fields[4]) && $fields[4] ne '' && $fields[4] ne '_')
        {
            unshift(@misc, "Ntrans=$fields[4]");
            $fields[4] = '_';
        }
        # UPOS must not be empty (unless it is a line with a fused token). It must be X if it is unknown.
        $fields[3] = 'X' if($fields[3] eq '_' && $fields[0] !~ m/^\d+-\d+/);
        # UPOS must be all uppercase (not "noun" but "NOUN").
        $fields[3] = uc($fields[3]);
        # Feature values must start with an uppercase letter but they don't.
        if(defined($fields[5]) && $fields[5] ne '' && $fields[5] ne '_')
        {
            my @features = sort {lc($a) cmp lc($b)} (grep {defined($_)} (map
            {
                # If there were spaces, now replaced by underscores, discard them.
                s/_//g;
                my ($f, $v) = split(/=/, $_);
                my $fv;
                # Undefined or empty value? Discard the whole feature!
                if(!defined($v) || $v eq '')
                {
                    $fv = undef;
                }
                else
                {
                    # Feature value must start with an uppercase letter.
                    $v =~ s/^(.)/\u$1/;
                    $fv = "$f=$v";
                }
                $fv
            }
            (split(/\|/, $fields[5]))));
            $fields[5] = scalar(@features) ? join('|', @features) : '_';
        }
        # HEAD must not equal to ID.
        if($fields[6] =~ m/\d/ && $fields[6] eq $fields[0])
        {
            $fields[6] = 0;
        }
        # Reassemble the MISC column.
        $fields[9] = scalar(@misc) ? join('|', @misc) : '_';
        # Reassemble the line.
        $line = join("\t", @fields);
    }
    print("$line\n");
}
