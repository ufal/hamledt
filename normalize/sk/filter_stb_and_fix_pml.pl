#!/usr/bin/env perl
# Projde zdrojová data Slovenského treebanku a vybrané soubory protáhne kontrolou na chyby v XML.
# Jednorázový skript se zadrátovanými cestami.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use lib '/home/zeman/lib';
use dzsys; # saferun

# SVN: https://svn.ms.mff.cuni.cz/svn/slovallex/trunk/
my $zdrojova_cesta = '/net/work/people/zeman/slovallex';
my $cilova_cesta   = '/net/work/people/zeman/stb_fixed';
# Zajímají nás pouze ty podkorpusy, které mají ruční morfologickou anotaci a syntaktickou anotaci od dvou nezávislých anotátorů.
# Prvních 7 (Orwell1984 .. PsiaKoza) má potvrzenou ruční morfologii, u ostatních si myslím, že je také ruční.
my @doublean = qw(Orwell1984 MojaPrvaLaska Mucska MilosFerko MilosFerko2 Patmos PsiaKoza blogSME Durovic Inzine ProgramVyhlasenie RaczovaOslov Rozpravky SME Wikipedia Wikipedia2);
# Podkorpusy, které obsahují syntaktickou anotaci jen od jednoho anotátora.
#my @singlean = ('blogSME', 'HvoreckyLovciaZberaci', 'KralikMorus', 'Lenco', 'RazcovaRoman', 'Stavebnictvo', 'zber1-zvysne');
# Vynechávám korpusy BallekPomocnik (pravděpodobně automatická morfologie) a single/DominoForum (rozsypaná segmentace na věty).
# Projít jednotlivé zdrojové složky a získat seznam souborů.
my @seznam;
my %cilove_cesty;
foreach my $slozka (@doublean)
{
    for(my $ia = 1; $ia <= 2; $ia++)
    {
        my $cesta = "$zdrojova_cesta/$slozka/anotator$ia";
        dzsys::saferun("mkdir -p $cilova_cesta/$slozka/anotator$ia") or die;
        projit_slozku($cesta);
    }
}
# Vytvořit cílové složky a zkopírovat do nich soubory.
foreach my $soubor (sort(@seznam))
{
    dzsys::saferun("fix_pml.pl $soubor.a > $cilove_cesty{$soubor}.a") or die;
    dzsys::saferun("cp $soubor.m $cilove_cesty{$soubor}.m") or die;
    dzsys::saferun("cp $soubor.w $cilove_cesty{$soubor}.w") or die;
}



sub projit_slozku
{
    my $cesta = shift;
    opendir(DIR, $cesta) or die("Cannot read folder $cesta: $!");
    my @soubory = readdir(DIR);
    closedir(DIR);
    foreach my $soubor (@soubory)
    {
        if($soubor =~ s/\.a$//)
        {
            my $cestasoubor = "$cesta/$soubor";
            push(@seznam, $cestasoubor);
            my $aktualni_cilova_cesta = $cesta;
            $aktualni_cilova_cesta =~ s:$zdrojova_cesta:$cilova_cesta:;
            $cilove_cesty{$cestasoubor} = "$aktualni_cilova_cesta/$soubor";
        }
    }
}
