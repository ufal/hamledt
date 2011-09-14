#!/usr/bin/perl

use strict;
use warnings;

my @forms;
my @tags;
my @parents;
my @labels;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

while (<>) {
    chomp;
    my @items = split(/\t/, $_);
    if (!@items) {
        print join("\t", @forms) . "\n";
        print join("\t", @tags) . "\n";
        print join("\t", @labels) . "\n";
        print join("\t", @parents) . "\n\n";
        @forms = ();
        @tags = ();
        @parents = ();
        @labels = ();
    }
    else {
        push @forms, $items[1];
        push @tags, $items[4];
        push @parents, $items[6];
        push @labels, $items[7];
    }
}
