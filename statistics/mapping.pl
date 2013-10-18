#!/usr/bin/env perl
use strict;
use warnings;

my $MIN_DEPREL_COUNT = 100;
my %c;

while (<>) {
    chomp;
    my ($lang, $deprel, $afun) = split /\t/, $_;
    $c{$lang}{$deprel}{$afun}++; 
    $c{$lang}{$deprel}{_}++;
    $c{$lang}{_all}++;
}

sub print_line {
    my ($h, $c_deprel) = @_;
    my @afuns = sort {$h->{$b} <=> $h->{$a}} keys %{$h};       
    while (@afuns){
        my $afun = shift @afuns;
        my $c_afun = $h->{$afun};
        my $p_afun = sprintf("%.0f",100*$c_afun/$c_deprel);
        last if $p_afun < 1; ####################
        print " $afun=$p_afun\\%";
    }
    if (@afuns){
        my $c_rest = 0;
        foreach my $afun (@afuns){
            $c_rest += $h->{$afun}
        }
        my $p_rest = 100*$c_rest/$c_deprel;
        if ($p_rest >= 0.5){
            printf(" \\textit{rest}=%.0f\\%%", $p_rest);
        } else {
            print " \\textit{rest}\$<\$0.5\\%";
        }
    }
    print "\\\\ \\hline\n";
}

foreach my $lang (sort keys %c) {
    my $total = delete $c{$lang}{_all}; 
    my @deprels = sort {$c{$lang}{$b}{_} <=> $c{$lang}{$a}{_}} keys %{$c{$lang}};
    print "=== $lang =======================================\n";
    print '\begin{longtable}{|l|r|p{9cm}|}\hline'."\n";
    while (@deprels) {
        my $deprel = shift @deprels;
        my $c_deprel = delete $c{$lang}{$deprel}{_};
        last if $c_deprel < $MIN_DEPREL_COUNT; ######################
        my $dep = $deprel; $dep =~ s/_/\\_/g;
        print "$dep & $c_deprel & ";
        print_line($c{$lang}{$deprel}, $c_deprel);
    }
    if (@deprels){
        my %t;
        my $c_other = 0;
        foreach my $deprel (@deprels){
            $c_other += delete $c{$lang}{$deprel}{_};
            foreach my $afun (keys %{$c{$lang}{$deprel}}){
                $t{$afun} += $c{$lang}{$deprel}{$afun};
            }
        }

        print '\hline\textit{other} & ' . "$c_other & ";
        print_line(\%t,$c_other);
    }
    print '\end{longtable}'."\n";
}
