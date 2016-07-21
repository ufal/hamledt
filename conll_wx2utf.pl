#!/usr/bin/perl
# Převede indický CoNLL soubor z kódování WX do UTF-8. Je nutné si uvědomit následující:
# - WX zapisuje indický text pomocí latinky. Pokud do indického textu měla být vložena skutečná latinka, nepoznáme to.
# - WX je mapování obecného repertoáru hlásek, které lze zapsat v indických písmech. Pro převod do UTF-8 musíme vědět, které indické písmo se má použít.
# Copyright © 2009 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use Getopt::Long;
use translit;
use translit::wx2utf;
use translit::brahmi;

# Výchozí jazyk je hindština, tj. písmo dévanágarí.
$jazyk = 'hi';
# Na požádání lze po převodu do UTF-8 převést zpět do latinky nějakým mým schématem, např. vědeckým do článků.
$tl = 0;
GetOptions('language=s' => \$jazyk, 'transliterate' => \$tl);
# Vytvořit převodní tabulku.
$maxl = translit::wx2utf::inicializovat(\%prevod, $jazyk);
# Vytvořit zpětné transliterační tabulky.
# 0x900: Písmo devanágarí.
translit::brahmi::inicializovat(\%translit, 2304, $scientific);
# 0x980: Bengálské písmo.
translit::brahmi::inicializovat(\%translit, 2432, $scientific);
# 0xC00: Telugské písmo.
translit::brahmi::inicializovat(\%translit, 3072, $scientific);

# Vlastní přepis standardního vstupu ve formátu CoNLL.
while(<>)
{
    s/\r?\n$//;
    my @pole = split(/\t/, $_);
    # Přepsat FORM a LEMMA. Ostatní položky nechat na pokoji, např. morfologickou značku chceme nechat v latince.
    $pole[1] = translit::prevest(\%prevod, $pole[1], $maxl) unless($pole[1] eq 'NULL');
    $pole[2] = translit::prevest(\%prevod, $pole[2], $maxl) unless($pole[2] eq 'NULL');
    if($tl)
    {
        $pole[1] = translit::prevest(\%translit, $pole[1], 2) unless($pole[1] eq 'NULL');
        $pole[2] = translit::prevest(\%translit, $pole[2], 2) unless($pole[2] eq 'NULL');
    }
    $_ = join("\t", @pole)."\n";
    print;
}
