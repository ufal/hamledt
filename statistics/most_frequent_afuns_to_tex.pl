#!/usr/bin/env perl

use strict;
use warnings;

my %count;
my %total;

my %language_name = ( # and also a filter whether to include a given language
    ar => q(Arabic),
    bg => q(Bulgarian),
    bn => q(Bengali),
    cs => q(Czech),
    ca => q(Catalan),
    da => q(Danish),
    de => q(German),
    el => q(Greek),
    en => q(English),
    es => q(Spanish),
    eu => q(Basque),
    et => q(Estonian),
    fa => q(Persian),
    fi => q(Finnish),
    grc=> q(Greek),
    hi => q(Hindi),
    hu => q(Hungarian),
    it => q(Italian),
    ja => q(Japanese),
    la => q(Latin),
    nl => q(Dutch),
    fa => q(Persian),
    pt => q(Portuguese),
    ro => q(Romanian),
    ru => q(Russian),
    sl => q(Slovene),
    sv => q(Swedish),
    ta => q(Tamil),
    te => q(Telugu),
    tr => q(Turkish),
);


my @afuns = qw(Atr Adv Obj AuxP Sb Pred Coord AuxV AuxC);

print STDERR "reading the counts...\n";
while (<>) {
#    if (/hamledt\/(w+)\/treex.+\<afun\>(w+)/) {
    if (/hamledt\/([a-z]+)\/treex.+afun>([a-z]+)/i) {
        my ($language,$afun) = ($1,$2);
#        print "$language $afun\n";
        $count{$language}{$afun}++;
        $total{$language}++;
    }
    else {
        print STDERR "Unexpected input: $_";
    }
}

print STDERR "aggregation...\n";
print '{\footnotesize
\setlength{\tabcolsep}{4pt}
';

print '\begin{longtable}{|l|'. join '',map{'r|'} @afuns;
print  "}\n \\hline \n";

print join ' & ',('Language',@afuns);
print '\\\\ \hline \hline';
print " \n";

foreach my $language (sort {$language_name{$a} cmp $language_name{$b}} grep {$language_name{$_}} keys %count) {
    print "$language_name{$language} ($language)",
        " &  ", join " & ", map {sprintf("%.1f",100*($count{$language}{$_}||0)/$total{$language}) } @afuns;
    print '\\\\ \hline';
    print "\n";
}

#print '\end{longtable} }'; # because the table's caption is stored in the main latex file
