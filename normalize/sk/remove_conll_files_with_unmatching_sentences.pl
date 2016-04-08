#!/usr/bin/env perl
# Projde páry souborů Slovenského treebanku od různých anotátorů a odstraní takové, kde nesedí počet vět.
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
my $zdrojova_cesta = '/net/work/people/zeman/stb-conll';
my @slozky = dzsys::get_subfolders($zdrojova_cesta);
foreach my $slozka (@slozky)
{
    my $c1 = "$zdrojova_cesta/$slozka/anotator1";
    my $c2 = "$zdrojova_cesta/$slozka/anotator2";
    my @sa1 = sort(grep {m/\.conll$/} (dzsys::get_files($c1)));
    my @sa2 = sort(grep {m/\.conll$/} (dzsys::get_files($c2)));
    # Předpokládáme, že soubory jsou pojmenované tak, aby navzájem si odpovídající soubory měly stejné pořadí. Nebudeme porovnávat jejich názvy.
    die("Počty .conll souborů si neodpovídají: ", scalar(@sa1), " != ", scalar(@sa2)) if(scalar(@sa1)!=scalar(@sa2));
    for(my $i = 0; $i <= $#sa1; $i++)
    {
        my $empty_re = '^\s*$';
        my $e1 = `grep -P '$empty_re' $c1/$sa1[$i]`;
        my $e2 = `grep -P '$empty_re' $c2/$sa2[$i]`;
        my $n1 = length($e1);
        my $n2 = length($e2);
#        print("Now checking $sa1[$i] $sa2[$i] ... $n1 $n2\n");
        if($n1!=$n2)
        {
            print("Removing unmatching files $sa1[$i] $n1 $sa2[$i] $n2\n");
            unlink("$c1/$sa1[$i]") or die("Cannot unlink $c1/$sa1[$i]: $!");
            unlink("$c2/$sa2[$i]") or die("Cannot unlink $c2/$sa2[$i]: $!");
        }
        else
        {
            # Zjednodušit názvy souborů.
            my $x = $sa1[$i];
            $x =~ s/_dok(\.fsnew)?\.conll$/.conll/;
            if($x ne $sa1[$i])
            {
                dzsys::saferun("mv $c1/$sa1[$i] $c1/$x");
            }
            $x = $sa2[$i];
            $x =~ s/_dok(\.fsnew)?\.conll$/.conll/;
            if($x ne $sa2[$i])
            {
                dzsys::saferun("mv $c2/$sa2[$i] $c2/$x");
            }
        }
    }
}
