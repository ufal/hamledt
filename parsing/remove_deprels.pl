#!/usr/bin/env perl

use strict;
use warnings;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

while (<>) {
    chomp;
    if ($_ =~ /^\d/) {
        my @items = split /\t/;
        my $suffix = $items[7] =~ /(_M?S?C?)$/ ? $1 : "";
        $items[7] = "_$suffix";
        print join("\t", @items);
    }
    print "\n";
}
