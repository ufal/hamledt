#!/usr/bin/env perl
# Prepares several mixes of source training data, always excluding the target language.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use cluster;

my $wdir = '/net/work/people/zeman/hamledt/parsing/mtag';
my @languages = qw(bg-ud12 cs-ud12 da-ud12 de-ud12 el-ud12 en-ud12 es-ud12 et-ud12 eu-ud12 fa-ud12 fi-ud12 fi-ud12ftb fr-ud12 ga-ud12 hi-ud12 he-ud12 hr-ud12 hu-ud12 id-ud12 it-ud12 la-ud12 la-ud12itt la-ud12proiel nl-ud12 no-ud12 pl-ud12 pt-ud12 ro-ud12 sl-ud12 sv-ud12 ta-ud12);

my @slavic = qw(be bg cs cu hr mk pl sl sk sr ru uk);
my @germanic = qw(da de en is nl no sv);
my @romance = qw(ca es fr gl it pt ro);
my @indoeur = (@slavic, @germanic, @romance, qw(el fa ga hi la));
my @agglut = qw(et eu fi hu tr);
my @c7 = qw(bg ca de el hi hu tr); # We defined this for HamleDT 2.0. UD 1.2 does not have ca and tr.

foreach my $lang1 (@languages)
{
    # Language without treebank extension, e.g. 'fi' instead of 'fi-ud12ftb'.
    my $l1 = $lang1;
    $l1 =~ s/-ud\d+.*//;
    my $tgtpath = "$wdir/$lang1";
    print STDERR "$lang1:";
    my %c;
    foreach my $lang2 (@languages)
    {
        my $l2 = $lang2;
        $l2 =~ s/-ud\d+.*//;
        if ($l1 ne $l2)
        {
            my $srcpath = "$wdir/$lang2/train.delex.conll";
            print STDERR " $lang2";
            push(@{$c{all}}, $srcpath);
            push(@{$c{sla}}, $srcpath) if(grep {$_ eq $l2} @slavic);
            push(@{$c{ger}}, $srcpath) if(grep {$_ eq $l2} @germanic);
            push(@{$c{rom}}, $srcpath) if(grep {$_ eq $l2} @romance);
            push(@{$c{ine}}, $srcpath) if(grep {$_ eq $l2} @indoeur);
            push(@{$c{agl}}, $srcpath) if(grep {$_ eq $l2} @agglut);
        }
    }
    print STDERR "\n";
    foreach my $combination ('all', 'sla', 'ger', 'rom', 'ine', 'agl')
    {
        print STDERR ("$tgtpath/train.$combination.delex.conll\n");
        cluster::qsub('command' => 'conll_combine_multi_interlaced.pl '.join(' ', @{$c{$combination}})." > $tgtpath/train.$combination.delex.conll", 'queue' => 'ms');
    }
}
