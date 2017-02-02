#!/usr/bin/env perl
# Generates document and paragraph boundary tags from sentence ids in CoNLL-U files.
# If there are any document/paragraph tags already in the input, they will be removed.
# Assumes sentence id format as in the Prague Dependency Treebank:
# cmpr9406-001-p2s1
# ln94200-100-p1s1
# mf920901-001-p1s1A
# vesm9211-001-p1s1
# Copyright © 2017 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

my $current_did = '';
my $current_pid = '';
while(<>)
{
    s/\r?\n$//;
    # Ignore any document or paragraph tags in the input.
    # (We work only with sentence-leve paragraph boundaries. There could be also the NewPar=Yes MISC attribute, but not in PDT.)
    if(m/^\#\s*new(doc|par)(\s|$)/)
    {
        next;
    }
    # All sentences should have a sent_id attribute, which includes the ids of the current document and paragraph.
    # Compare it to the sent_id of the previous sentence.
    if(m/^\#\s*sent_id\s*=\s*(.+)/)
    {
        my $sid = $1;
        if($sid =~ m/^((.+)-p\d+)s[0-9A-Z]+$/)
        {
            my $pid = $1;
            my $did = $2;
            if($did ne $current_did)
            {
                print("# newdoc id = $did\n");
                $current_did = $did;
            }
            if($pid ne $current_pid)
            {
                print("# newpar id = $pid\n");
                $current_pid = $pid;
            }
            print("# sent_id = $sid\n");
        }
        else
        {
            print STDERR ("Unexpected sentence id '$sid'\n");
            print("# sent_id = $sid\n");
        }
    }
    else
    {
        print("$_\n");
    }
}
