#!/usr/bin/env perl
# Generates document and paragraph boundary tags from sentence ids in CoNLL-U files.
# If there are any document/paragraph tags already in the input, they will be removed.
# Assumes sentence id format as in the Prague Dependency Treebank:
# cmpr9406-001-p2s1
# ln94200-100-p1s1
# mf920901-001-p1s1A
# vesm9211-001-p1s1
# Faust (PDT-C 2.0):
# faust_2010_07_mu_17-SCzechA-p1858-s1-root
# Czech Academic Corpus:
# a01w-s1
# Czech FicTree: three digits before sentence number are chunk number.
# laskaneX000-s1
# Czech and English PCEDT:
# wsj-1900-s7
# Prague Arabic Dependency Treebank:
# afp.20000715.0001:p2u1
# Copyright © 2017, 2021, 2025 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Getopt::Long;

sub usage
{
    print STDERR ("Usage: perl conllu_docpar_from_sentid.pl --format doc-sn|guess < input.conllu > output.conllu\n");
}

# Normally we use sent_id to detect new documents and paragraphs.
# PROIEL treebanks have the source attribute instead.
# However, source must be explicitly asked for, because Portuguese has both source and sent_id, and we do not want two newdocs before one sentence.
my $source = 0;
# Various formats have been observed and can be guessed automagically. However,
# sometimes it is safer to explicitly state the sentence id format:
# guess ... the first regular expression to match is the winner
# doc-sn ... no paragraphs; document is any string but it is followed by a hyphen, 's', and a number (optionally followed by an [A-Z] suffix)
my $format = 'guess';
GetOptions
(
    'source'   => \$source,
    'format=s' => \$format
);

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
        if($format eq 'doc-sn')
        {
            if($sid =~ m/^(.+)-s[0-9A-Z]+$/)
            {
                my $did = $1;
                if($did ne $current_did)
                {
                    print("# newdoc id = $did\n");
                    $current_did = $did;
                }
                print("# sent_id = $sid\n");
            }
            else
            {
                print STDERR ("Unexpected sentence id '$sid'\n");
                print("# sent_id = $sid\n");
            }
        }
        else # guess the format of the sentence id
        {
            if($sid =~ m/^((.+)-p\d+)s[-0-9A-Z]+$/)
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
            # Faust
            # faust_2010_07_mu_17-SCzechA-p1858-s1-root
            elsif($sid =~ m/^(faust_.+?)-SCzechA-(p\d+)-(s.+?)(?:-root)?$/)
            {
                my $did = $1;
                my $pid = "$did-$2";
                $sid = "$pid-$3";
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
            # Czech and English PCEDT
            # This is similar to CAC and other corpora but we must catch it before FicTree, otherwise FicTree
            # will take the last three digits of the document number as paragraph number.
            elsif($sid =~ m/^(wsj-\d+)-s[0-9A-Z]+$/)
            {
                my $did = $1;
                if($did ne $current_did)
                {
                    print("# newdoc id = $did\n");
                    $current_did = $did;
                }
                print("# sent_id = $sid\n");
            }
            # Czech FicTree
            elsif($sid =~ m/^(.+?)(\d\d\d)-s[0-9A-Z]+$/)
            {
                my $did = $1;
                my $pid = $2; # chunk id rather than paragraph id; chunks are shuffled randomly within document
                $pid = $did.$pid;
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
            # Czech Academic Corpus.
            elsif($sid =~ m/^(.+)-s[0-9A-Z]+$/)
            {
                my $did = $1;
                if($did ne $current_did)
                {
                    print("# newdoc id = $did\n");
                    $current_did = $did;
                }
                print("# sent_id = $sid\n");
            }
            # Prague Arabic Dependency Treebank
            elsif($sid =~ m/^((.+):p\d+)u[0-9A-Z]+$/)
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
            # Slovenian UD treebank
            elsif($sid =~ m/^((ssj\d+)\.\d+)\.\d+$/)
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
            # Ancient Greek Dependency Treebank
            # tlg0008.tlg001.perseus-grc1.13.tb.xml@1163
            elsif($sid =~ m/^(.+)\@\d+$/)
            {
                my $did = $1;
                if($did ne $current_did)
                {
                    print("# newdoc id = $did\n");
                    $current_did = $did;
                }
                print("# sent_id = $sid\n");
            }
            # Greek Dependency Treebank
            # gdt-20120321-elwikinews-5251-1
            elsif($sid =~ m/^(.+)-\d+$/)
            {
                my $did = $1;
                if($did ne $current_did)
                {
                    print("# newdoc id = $did\n");
                    $current_did = $did;
                }
                print("# sent_id = $sid\n");
            }
            # Upper Sorbian Treebank: no document ids, just
            # p1s1
            elsif($sid =~ m/^(p\d+)s[-0-9A-Za-b]+$/)
            {
                my $pid = $1;
                if($pid ne $current_pid)
                {
                    print("# newpar id = $pid\n");
                    $current_pid = $pid;
                }
                print("# sent_id = $sid\n");
            }
            else
            {
                # Do not complain about PROIEL sentence ids. They are plain integers
                # but in PROIEL we have document ids from the source attribute.
                unless($sid =~ m/^\d+$/ && $current_did ne '')
                {
                    print STDERR ("Unexpected sentence id '$sid'\n");
                }
                print("# sent_id = $sid\n");
            }
        }
    }
    # PROIEL treebanks have an attribute called "source". When it changes we have a new document.
    elsif($source && m/^\#\s*source\s*=\s*(.+)/)
    {
        my $did = $1;
        if($did ne $current_did)
        {
            my $xdid = $did;
            $xdid =~ s/\s+/_/g;
            print("# newdoc id = $xdid\n");
            $current_did = $did;
        }
        print("# source = $did\n");
    }
    # SynTagRus has an unnamed comment of the form "# 2003Anketa.xml 1", which contains file name (document) and sentence number.
    elsif($source && m/^\#\s*((.+\.xml)\s+\d+)$/i)
    {
        my $dsid = $1;
        my $did = $2;
        if($did ne $current_did)
        {
            my $xdid = $did;
            $xdid =~ s/\s+/_/g;
            print("# newdoc id = $xdid\n");
            $current_did = $did;
        }
        print("# source = $dsid\n");
    }
    else
    {
        print("$_\n");
    }
}
