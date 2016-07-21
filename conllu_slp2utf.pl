#!/usr/bin/perl
# Převede indický CoNLL soubor z kódování SLP1 do UTF-8. Je nutné si uvědomit následující:
# - SLP1 zapisuje indický text pomocí latinky. Pokud do indického textu měla být vložena skutečná latinka, nepoznáme to.
# SLP1 (https://en.wikipedia.org/wiki/SLP1) je zkratka za Sanskrit Library Phonetic Basic encoding scheme.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use Getopt::Long;
use translit;
use translit::slp2utf;
use translit::brahmi;

# Výchozí jazyk je sanskrt, tj. písmo dévanágarí.
$jazyk = 'sa';
# Na požádání lze po převodu do UTF-8 převést zpět do latinky nějakým mým schématem, např. vědeckým do článků.
$tl = 0;
GetOptions('language=s' => \$jazyk, 'transliterate' => \$tl);
# Vytvořit převodní tabulku.
$maxl = translit::slp2utf::inicializovat(\%prevod, $jazyk);
# Vytvořit zpětné transliterační tabulky.
# 0x900: Písmo devanágarí.
translit::brahmi::inicializovat(\%translit, 2304, $scientific);

# Vlastní přepis standardního vstupu ve formátu CoNLL-U.
while(<>)
{
    unless(m/^#/ || m/^\s*$/)
    {
        s/\r?\n$//;
        my @pole = split(/\t/, $_);
        # Přepsat FORM a LEMMA. Ostatní položky nechat na pokoji, např. morfologickou značku chceme nechat v latince.
        $pole[1] = translit::prevest(\%prevod, $pole[1], $maxl) unless($pole[1] =~ m/^(_|NULL)$/);
        $pole[2] = translit::prevest(\%prevod, $pole[2], $maxl) unless($pole[2] =~ m/^(_|NULL)$/);
        if($tl)
        {
            $pole[1] = translit::prevest(\%translit, $pole[1], 2) unless($pole[1] =~ m/^(_|NULL)$/);
            $pole[2] = translit::prevest(\%translit, $pole[2], 2) unless($pole[2] =~ m/^(_|NULL)$/);
        }
        $_ = join("\t", @pole)."\n";
    }
    print;
}
