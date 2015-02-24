#!/usr/bin/env perl
# Překóduje tamilský text z Loganathanova kódování zpět do tamilského písma.
# Copyright © 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use translit;
use translit::brahmi;

# 0xB80: Tamilské písmo.
translit::brahmi::inicializovat(\%prevod, 2944, $scientific=1);

my $path_to_table = 'C:/Users/Dan/Desktop/utf8_to_latin_map.txt';
open(MAP, $path_to_table) or die("Cannot read $path_to_table: $!");
while(<MAP>)
{
    chomp();
    my ($tamil, $latin) = split(/\t:\t/, $_);
    $t2l{$tamil} = $latin;
    $l2t{$latin} = $tamil;
    my $lt = length($tamil);
    my $ll = length($latin);
    $maxlt = $lt if($lt>$maxlt);
    $maxll = $ll if($ll>$maxll);
}
close(MAP);

foreach my $dataset ('train', 'test')
{
    my $path_to_data = "C:\\Users\\Dan\\Documents\\Lingvistika\\Data\\treebanks\\HamleDT\\ta\\source\\$dataset.conll";
    open(DATA, $path_to_data) or die("Cannot read $path_to_data: $!");
    while(<DATA>)
    {
        chomp();
        my @fields = split(/\s+/, $_);
        if(defined($fields[1]))
        {
            $fields[1] = l2t($fields[1]);
            print(join("\t", @fields), "\n");
        }
        else
        {
            print("\n");
        }
    }
    close(DATA);
}

sub l2t
{
    my $l = shift;
    my $t = translit::prevest(\%l2t, $l, $maxll);
    my $s = translit::prevest(\%prevod, $t);
    # Modify transliteration of long and short e and o. The one we have now is more suitable for Devanagari.
    $s =~ tr/eo\x{E8}\x{F2}/\x{113}\x{14D}eo/;
    return "$t ($s)";
}
