#!/usr/bin/env perl
# Statistiky značek a slov pro Kaju.
# Copyright © 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use csort;

while(<>)
{
    chomp();
    next if(m/^\s*$/);
    my @f = split(/\t/, $_);
    my $form = lc($f[1]);
    my $lemma = $f[2];
    my $upos = $f[3];
    my $ufeat = $f[5];
    # Skip numbers expressed using digits or Roman numerals.
    next if($form =~ m/^[-\d\.]+$/);
    next if($ufeat =~ m/NumForm=Roman/);
    # Skip foreign words.
    next if($ufeat =~ m/Foreign/);
    my $word = "$form\t$lemma\t$ufeat";
    $hash{$upos}{$word}++;
    $hword{$word}++;
}

foreach my $word (keys(%hword))
{
    my ($form, $lemma, $ufeat) = split(/\t/, $word);
    $trid{$word} = csort::zjistit_tridici_hodnoty($word, 'cs');
}

foreach my $upos (qw(ADP AUX CONJ DET NUM PART PRON SCONJ))
{
    foreach my $word (sort {$trid{$a} cmp $trid{$b}} (keys(%{$hash{$upos}})))
    {
        print("$upos\t$word\t$hash{$upos}{$word}\n");
    }
}
