#!/usr/bin/env perl
# Přepíše seznam příkladů chyb z testů HamleDTa tak, aby fungoval na extrahovaný treexový soubor (viz tests/Makefile, make treex).
# Copyright © 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

###!!! Nepotřebuju koukat na spoustu příkladů, takže pro jednoduchost předpokládám, že koukám pouze do prvního souboru.
my $localpath = 'C:\Users\Dan\Documents\Lingvistika\Projekty\tectomt\treex\devel\hamledt\tests\examples';
my $firstfile = 'ttred.cs.UD%3A%3APunctuation.filelist-0001.treex.gz';
my $last_sentence;
my $b = 0;
while(<>)
{
    # Rozdělit adresu na část identifikující větu a část identifikující uzel.
    my ($sentence, $node);
    if(s-^(.+\#\#\d+\.)(.+)$--)
    {
        $sentence = $1;
        $node = $2;
        if(defined($last_sentence) && $sentence ne $last_sentence)
        {
            $b++;
        }
        $last_sentence = $sentence;
        # Nový identifikátor je bX-starý, kde X je číslo věty v rámci nového souboru.
        print($localpath, '/', $firstfile, "\#\#", $b+1, '.b', $b, "-$node\n");
    }
    else
    {
        print;
    }
}
