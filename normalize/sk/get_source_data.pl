#!/usr/bin/env perl
# Projde zdrojová data Slovenského treebanku, vybere soubory ke zkopírování, rozdělí je na trénovací a testovací data a zkopíruje je.
# Jednorázový skript se zadrátovanými cestami.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
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
my $cilova_cesta;
if($ENV{TMT_ROOT})
{
    $cilova_cesta = "$ENV{TMT_ROOT}/share/data/resources/hamledt/sk";
}
else
{
    # Nejsou nastavené proměnné prostředí, tak zkusíme default ÚFAL.
    $cilova_cesta = '/net/projects/tectomt_shared/data/resources/hamledt/sk';
}
# Podkorpusy, které obsahují syntaktickou anotaci od dvou nezávislých anotátorů.
# Prvních 7 (Orwell1984 .. PsiaKoza) má potvrzenou ruční morfologii, u ostatních si myslím, že je také ruční.
my @doublean = qw(Orwell1984 MojaPrvaLaska Mucska MilosFerko MilosFerko2 Patmos PsiaKoza blogSME Durovic Inzine ProgramVyhlasenie RaczovaOslov Rozpravky SME Wikipedia Wikipedia2);
# Podkorpusy, které obsahují syntaktickou anotaci jen od jednoho anotátora.
my @singlean = ('blogSME', 'HvoreckyLovciaZberaci', 'KralikMorus', 'Lenco', 'RazcovaRoman', 'Stavebnictvo', 'zber1-zvysne');
# Vynechávám korpusy BallekPomocnik (pravděpodobně automatická morfologie) a single/DominoForum (rozsypaná segmentace na věty).
# Projít jednotlivé zdrojové složky a získat seznam souborů.
my @seznam;
foreach my $slozka (@doublean)
{
    my $cesta = "$zdrojova_cesta/$slozka/anotator1";
    projit_slozku($slozka, $cesta);
}
foreach my $slozka (@singlean)
{
    my $cesta = "$zdrojova_cesta/single_annotator/$slozka";
    projit_slozku($slozka, $cesta);
}
# Vytvořit cílové složky a zkopírovat do nich soubory.
dzsys::saferun("mkdir -p $cilova_cesta/source/train");
dzsys::saferun("mkdir -p $cilova_cesta/source/test");
my $i = 0;
foreach my $soubor (sort(@seznam))
{
    $i++;
    my $urceni = ($i % 10 == 0) ? 'test' : 'train';
    foreach my $ext qw(a m w)
    {
        dzsys::saferun("cp $soubor.$ext $cilova_cesta/source/$urceni/$cilove_nazvy{$soubor}.$ext\n");
    }
}
printf("CELKEM %d SOUBORŮ\n", scalar(@seznam));



sub projit_slozku
{
    my $slozka = shift;
    my $cesta = shift;
    opendir(DIR, $cesta) or die("Cannot read folder $cesta: $!");
    my @soubory = readdir(DIR);
    closedir(DIR);
    foreach my $soubor (@soubory)
    {
        if($soubor =~ s/\.a$//)
        {
            push(@seznam, "$cesta/$soubor");
            # Podkorpusy, u kterých by neškodilo zopakovat název složky v názvu souboru (u ostatních už to v nějaké formě je):
            # Orwell1984, blogSME, některé soubory v Inzine, Rozpravky, SME, Wikipedia některé, některé zber1-zvysne (ty příšluší k ostatním textům, ale mají jen jednu anotaci).
            my $cilovy_nazev = lc($soubor);
            if($slozka =~ m/^(orwell1984|inzine|rozpravky|sme|blogsme|wikipedia)$/i)
            {
                $cilovy_nazev = lc($slozka).'_'.$cilovy_nazev;
            }
            ###!!! Rád bych sice názvy některých souborů upravil, ale tím bych si přidělal dost práce, protože bych musel uvnitř nich upravit odkazy na související .m a .w!
            $cilovy_nazev = $soubor; ###!!! TAKŽE ZPĚT!
            if(exists($mapa_nazvu{$cilovy_nazev}))
            {
                die("Duplicate target name $cilovy_nazev");
            }
            $mapa_nazvu{$cilovy_nazev}++;
            $cilove_nazvy{"$cesta/$soubor"} = $cilovy_nazev;
        }
    }
}
