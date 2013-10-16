#!/usr/bin/env perl
use strict;
use warnings;

my $MIN_DEPREL_COUNT = 100;
my %c;

while (<>) {
    chomp;
    my ($lang, $deprel, $afun) = split /\t/, $_;
    $afun ||= 'undef';
    $c{$lang}{$deprel}{$afun}++; 
    $c{$lang}{$deprel}{_}++; 
}

foreach my $lang (sort keys %c) {
    my @deprels = sort {$c{$lang}{$b}{_} <=> $c{$lang}{$a}{_}} keys %{$c{$lang}};
    print "=== $lang =======================================\n";
    foreach my $deprel (@deprels) {
        my $c_deprel = $c{$lang}{$deprel}{_};
        next if $c_deprel < $MIN_DEPREL_COUNT;

        my @afuns = sort {$c{$lang}{$deprel}{$b} <=> $c{$lang}{$deprel}{$a}} grep {$_ ne '_'} keys %{$c{$lang}{$deprel}};       
        print "$deprel=$c_deprel:";
        foreach my $afun (@afuns){
            my $c_afun = $c{$lang}{$deprel}{$afun};
            my $p_afun = sprintf("%.0f",100*$c_afun/$c_deprel);
            #print " $afun=$c_afun ($p_afun%)";
            print " $afun=$p_afun%";
        }
        print "\n";
    }
}
