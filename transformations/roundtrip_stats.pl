#!/usr/bin/env perl
use Modern::Perl;
use Text::Table;
use List::Util qw(sum);

my %data;
my %languages;

sub uas {
   my ($trans, $lang) = @_;
   my $all = $data{$trans}{$lang}{all};
   return '-' if !$all;
   my $err = $data{$trans}{$lang}{err} || 0;
   return 1-($err/$all);
}

sub round {
    return map {/-/ ? $_ : sprintf("%.4f", $_)} @_;
}


while(<>){
    next if !/^file/;
    my ($file, $err_sents, $all_sents, $err_nodes, $all_nodes, $score) = map {/=(.+)/;$1} split;
    my ($lang, $trans) = ($file =~ m{/([^/]+)/treex/trans_([^/]+)});
    $data{$trans}{$lang}{all} += $all_nodes;
    $data{$trans}{$lang}{err} += $err_nodes;
    $data{average}{$lang}{all} += $all_nodes;
    $data{average}{$lang}{err} += $err_nodes;
    $languages{$lang} = 1;
}

my @langs = sort keys %languages;
my $table = Text::Table->new('trans', @langs, 'average');

foreach my $trans (sort keys %data){
    my @row = map {uas($trans, $_)} @langs;
    my @numbers = grep {!/-/} @row;
    my $avg = sum(@numbers) / @numbers;
    $table->add($trans, round(@row, $avg));
}

if (@langs < 18){
    say $table;
} else {
    say $table->select(0 .. (@langs/2)+1);
    say $table->select(0,(@langs/2)+2 .. @langs+3);
}
