#!/usr/bin/env perl
# Converts Uighur Dependency Treebank from XML to CoNLL-U.
# Does not do full XML parsing. Takes advantage of knowing that the source XML files are relatively simple.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

# <?xml version="1.0" encoding="utf-8"?>
# <Sentences>
#   <Sentence ID="1">
#     <Word ID="1" Lem="ئاسماننى" Morph="ئاسماننى" Inf=" " Rel="9,1,OBJ" POSName="ئىسىم" POS="N">ئاسماننى</Word>
# ...
#     <Word ID="31" Lem="." Morph="." Inf=" " Rel="-1,1,void" POSName="تىنىش بەلگىلىرى" POS="Y">.</Word>
#   </Sentence>
#   <Sentence ID="2">
#     <Word ID="1" Lem="بۇ" Morph="بۇ" Inf=" " Rel="2,1,ATT" POSName="ئالماش" POS="P">بۇ</Word>
# ...

# Some help with Uighur parts of speech but not the same tagset:
# http://www.aclweb.org/anthology/Y03-1025
my %posmap =
(
    'N' => 'NOUN',  # noun isim ئىسىم
    'V' => 'VERB',  # verb pzh'zhl پېئىل
    'A' => 'ADJ',   # adjective svpet سۈپەت
    'P' => 'PRON',  # pronoun almash ئالماش
    'M' => 'NUM',   # numeral san سان
    'D' => 'ADV',   # adverb rewish رەۋىش
    'R' => 'ADP',   # postposition tirkelme تىركەلمە
    'C' => 'CONJ',  # conjunction baghlighuchi باغلىغۇچى
    'Y' => 'PUNCT', #
);

while(<>)
{
    # Strip the line break character(s).
    s/\r?\n$//;
    if(m:<Sentence ID="(.+?)">:)
    {
        # The sentence ids seem to be always numeric. Precede them with "s".
        # BTW, are they unique just within their file, or corpus-wide? We need corpus-wide unique ids in UD.
        # Note: if the sentence id is just "s1", and later the CoNLL-U file is read in Treex, there will be complaints about duplicate ids.
        # That seems to be a bug in Treex. It generates new ids for bundles even if identical ids are already used for trees.
        print("\# sent_id s$1/ug\n");
    }
    elsif(m:<Word\s(.*)>(.*?)</Word>:)
    {
        my $annotation = $1;
        my $word = $2;
        my ($wid, $lemma, $morph, $inf, $rel, $posname, $pos);
        if($annotation =~ m/ID="(.+?)"/)
        {
            $wid = $1;
        }
        if($annotation =~ m/Lem="(.+?)"/)
        {
            $lemma = $1;
        }
        if($annotation =~ m/Morph="(.+?)"/)
        {
            $morph = $1;
        }
        if($annotation =~ m/Inf="(.+?)"/)
        {
            $inf = $1;
        }
        if($annotation =~ m/Rel="(.+?)"/)
        {
            $rel = $1;
        }
        if($annotation =~ m/POSName="(.+?)"/)
        {
            $posname = $1;
        }
        if($annotation =~ m/POS="(.+?)"/)
        {
            $pos = $1;
        }
        die("Word ID needed but not found: '$word'") if(!defined($wid));
        $word = '_' if(!defined($word) || $word eq '');
        $lemma = '_' if(!defined($lemma) || $lemma eq '');
        if($lemma ne $word)
        {
            print STDERR ("WOW. Word '$word', lemma '$lemma'\n");
        }
        $pos = '_' if(!defined($pos) || $pos eq '');
        my $upos = 'X';
        if(exists($posmap{$pos}))
        {
            $upos = $posmap{$pos};
        }
        else
        {
            print STDERR ("WARNING: Unknown part-of-speech tag '$pos'\n");
        }
        # Decode the dependency relation.
        my $head = 0;
        my $deprel = 'dep';
        if(defined($rel))
        {
            my @rel = split(/,/, $rel);
            # The first number may be the index of the parent node. -1 means the artificial root node (we want to keep 0 in that case).
            if($rel[0]>0)
            {
                $head = $rel[0];
            }
            if(defined($rel[2]))
            {
                $deprel = $rel[2];
            }
            # Not sure what the second number means. But it seems to be always 1.
            print STDERR ("THERE IS something else than 1: $rel") if($rel[1] != 1);
        }
        else
        {
            die("Undefined relation.");
        }
        # It seems that lemma is currently just a copy of the word. We will not print it, it would just cause confusion.
        my $line = "$wid\t$word\t_\t$upos\t$pos\t_\t$head\t$deprel\t_\t_\n";
        print($line);
    }
    elsif(m:</Sentence>:)
    {
        print("\n");
    }
}
