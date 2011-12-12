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
find::go('.', \&clean_cluster_run);

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

sub clean_cluster_run
{
    my $cesta = shift;
    my $objekt = shift;
    my $druh = shift;
    # Odstranit *-cluster-run-*. Pozor! Nehlídáme, zda už paralelní úloha, která tuto složku využívala, doběhla!
    if($druh eq 'drx' && $objekt =~ m/-cluster-run-/)
    {
        print("$cesta/$objekt\n");
        system("rm -rf $cesta/$objekt");
        return 0;
    }
    return $druh eq 'drx';
}
