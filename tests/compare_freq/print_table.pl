#!/usr/bin/env perl

use strict;
use warnings;

my %nodes;
my %afuns;

print "Changes in the proportion of afun values, relative to Czech data\n";
print "CS=BASE column shows the proportion in Czech data (e.g. Adv has covers around 10% of points\n";
print "The remaining columns show changes in percents w.r.t. the base (e.g. 150 means 1.5x more occurrences)\n";

while (<>) {
    chomp;
    my ($lang,$afun) = split;
    $nodes{$lang}++;
    $afuns{$lang}{$afun}++;
}


my @languages = sort keys %nodes;
my @afuns = sort keys %{$afuns{cs}};
use Text::Table;

my $tb = Text::Table->new(
        'Afun', 'CS=BASE', grep {$_ ne 'cs'} @languages,
    );

my %value;

foreach my $language ('cs', grep {$_ ne 'cs'} @languages) {
    foreach my $afun (@afuns) {
        next if not defined $afuns{$language}{$afun};
        my $percentage = 100 * $afuns{$language}{$afun} / $nodes{$language} ;
        if ($language eq 'cs') {
            $value{$language}{$afun} = sprintf("%.3f",$percentage);
        }
        else {
            $value{$language}{$afun} = sprintf("%d", 100 * ( $percentage / $value{cs}{$afun} - 1));
        }
    }
}

$tb->load(
    map {
        my $afun = $_;
        [$_, map {  $value{$_}{$afun} || ''} ('cs', grep {$_ ne 'cs'} @languages)]
    } @afuns
);

print $tb;
