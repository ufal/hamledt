#!/usr/bin/perl
# Converts Beta code (Ancient Greek text) to Unicode.
# Based on http://www.tlg.uci.edu/encoding/quickbeta.pdf
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use lib '/home/zeman/lib';
use translit;

%table =
(
    'a'  => "\x{3B1}", # alpha
    '*a' => "\x{391}",
    'b'  => "\x{3B2}", # beta
    '*b' => "\x{392}",
    'c'  => "\x{3BE}", # xi
    '*c' => "\x{39E}",
    'd'  => "\x{3B4}", # delta
    '*d' => "\x{394}",
    'e'  => "\x{3B5}", # epsilon
    '*e' => "\x{395}",
    'f'  => "\x{3C6}", # phi
    '*f' => "\x{3A6}",
    'g'  => "\x{3B3}", # gamma
    '*g' => "\x{393}",
    'h'  => "\x{3B7}", # eta
    '*h' => "\x{397}",
    'i'  => "\x{3B9}", # iota
    '*i' => "\x{399}",
    'k'  => "\x{3BA}", # kappa
    '*k' => "\x{39A}",
    'l'  => "\x{3BB}", # lambda
    '*l' => "\x{39B}",
    'm'  => "\x{3BC}", # mu
    '*m' => "\x{39C}",
    'n'  => "\x{3BD}", # nu
    '*n' => "\x{39D}",
    'o'  => "\x{3BF}", # omicron
    '*o' => "\x{39F}",
    'p'  => "\x{3C0}", # pi
    '*p' => "\x{3A0}",
    'q'  => "\x{3B8}", # theta
    '*q' => "\x{398}",
    'r'  => "\x{3C1}", # rho
    '*r' => "\x{3A1}",
    's'  => "\x{3C3}", # sigma
    's1' => "\x{3C3}",
    's2' => "\x{3C2}", # final sigma
    's3' => "\x{3F2}", # lunate sigma
    '*s' => "\x{3A3}",
    '*s3'=> "\x{3F9}",
    't'  => "\x{3C4}", # tau
    '*t' => "\x{3A4}",
    'u'  => "\x{3C5}", # upsilon
    '*u' => "\x{3A5}",
    'v'  => "\x{3DD}", # digamma
    '*v' => "\x{3DC}",
    'w'  => "\x{3C9}", # omega
    '*w' => "\x{3A9}",
    'x'  => "\x{3C7}", # chi
    '*x' => "\x{3A7}",
    'y'  => "\x{3C8}", # psi
    '*y' => "\x{3A8}",
    'z'  => "\x{3B6}", # zeta
    '*z' => "\x{396}",
    ')'  => "\x{313}", # comma above / smooth breathing
    '('  => "\x{314}", # reversed comma above / rough breathing
    '/'  => "\x{301}", # acute accent
    '='  => "\x{342}", # perispomeni / circumflex accent
    '\\' => "\x{300}", # grave accent
    '+'  => "\x{308}", # diaeresis
    '|'  => "\x{345}", # ypogegrammeni / iota subscript
    '?'  => "\x{323}", # dot below
    "'"  => "\x{2019}", # right single quotation mark (Unicode-recommended for apostrophe; the ASCII is only for backward compatibility)
    ###!!! The Unicode standard and the Thesaurus Linguae Grecae documentation suggest that \x{2010} is the correct character for hyphen,
    ###!!! while \x{2D} is ambiguous between hyphen and minus in meaning and should not be used.
    ###!!! Unfortunately, most of my Windows fonts just lack the glyph for \x{2010} so this conversion seems to do more harm than good.
#    '-'  => "\x{2010}", # hyphen
    '_'  => "\x{2014}", # em dash
);
foreach my $key (keys(%table))
{
    # Some data use uppercase instead of lowercase Latin letters. Uppercase Greek letters are still marked with asterisk.
    if($key =~ m/[a-z]/)
    {
        my $ukey = uc($key);
        $table{$ukey} = $table{$key};
    }
    # Diacritics can appear between asterisk and letter.
    if($key =~ m/^\*([a-zA-Z])$/)
    {
        my $letter = $1;
        my @diacritics = ('(', ')', '/', '=', '\\', '+', '|', '?', "'", '-', '_');
        foreach my $d (@diacritics)
        {
            $table{'*'.$d.$letter} = $table{$d}.$table{'*'.$letter};
            # Even two consecutive diacritical marks are possible.
            foreach my $d1 (@diacritics)
            {
                $table{'*'.$d.$d1.$letter} = $table{$d}.$table{$d1}.$table{'*'.$letter};
            }
        }
    }
}
foreach my $key (keys(%table))
{
    my $l = length($key);
    if($l>$maxl)
    {
        $maxl = $l;
    }
}

#translit::vypsat(\%table); exit;
while(<>)
{
    if(m/^\s*$/)
    {
        print;
    }
    else
    {
        # We assume CoNLL format and convert only the 'form' and 'lemma' fields.
        chomp();
        my @fields = split(/\t/, $_);
        $fields[1] = translit::prevest(\%table, $fields[1], $maxl);
        my $fields2zaloha = $fields[2];
        $fields[2] = translit::prevest(\%table, $fields[2], $maxl) unless($fields[2] =~ m/^(comma|period|hyphen|double|quote|bracket|punc|other|unknown)1?$/i);
        ###!!! Malá statistika lemmat interpunkce.
        if($fields[1] !~ m/\pL/)
        {
            my $kody = join('+', map {ord($_)} (split(//, $fields[1])));
            $interpunkce{"'$fields[1]' $kody '$fields2zaloha' '$fields[2]'"}++;
        }
        # The transliteration table cannot distinguish word-final sigma (it is marked explicitly only if it cannot be determined by position).
        $fields[1] =~ s/\x{3C3}$/\x{3C2}/;
        $fields[2] =~ s/\x{3C3}$/\x{3C2}/;
        print(join("\t", @fields), "\n");
    }
}
###!!! Vypsat statistiku.
foreach my $klic (sort(keys(%interpunkce)))
{
    print STDERR ("$klic\t$interpunkce{$klic}\n");
}
