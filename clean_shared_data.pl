#!/usr/bin/env perl
# Odstraní soubory omylem vytvořené ve sdílených datech Treexu, když Ondra Bojar pokazil logiku zápisu.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use lib '/home/zeman/lib';
use find;

find::go('/ha/projects/tectomt_shared/data/resources/normalized_treebanks', \&clean);

sub clean
{
    my $cesta = shift;
    my $objekt = shift;
    my $druh = shift;
    # Odstranit 001.gz
    # Nechat 001.treex.gz
    if($objekt =~ m/^\d+\.gz$/)
    {
        print("$cesta/$objekt\n");
        unlink("$cesta/$objekt") or
            print STDERR ("WARNING: Cannot remove file $objekt: $!\n");
    }
    return $druh eq 'drx';
}
