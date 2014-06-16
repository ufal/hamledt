#!/usr/bin/perl

# Purpose
# =======
# This program will show the general statistics of the data in the CoNLL format.

# Usage
# =====
# cat data.conll | ./conll-stats.pl

use strict;
use warnings;
use utf8;

binmode(STDOUT, ':utf8');
binmode(STDIN, ':utf8');
binmode(STDERR, ':utf8');

my $num_sen;            # number of sentences
my $num_words = 0;      # number of words
my %afun_stat;          # unique relation labels & their counts in the data    

my @conll_data;
my $currsen = q{};
my $linenum = 0;
my $conll_line = q{};


while (<STDIN>) {
    chomp;
    $linenum++;
    s/(^\s+|\s+$)//;
    next if /^#$/;  # skip the comment line
    my $line = $_;
    
    # line boundary if the line is empty
    if ($line =~ /^\s*$/) {
        $conll_line =~ s/(^\s+|\s+$)//;
        if ($conll_line ne q{}) {
            push @conll_data, $conll_line;
        }
        $conll_line = q{};
    }
    else {
        my @toks = split /\s*\t+\s*/, $line;
        my $len = scalar(@toks);
    
        # check each data CoNLL line has 10 columns
        if (($len != 10) && ($len != 8) ) {
            print "Something wrong with the CoNLL data: number of columns not 10 in line number: $linenum\n";
            exit 1;
        }

        
        $afun_stat{$toks[7]}++;
        
        # combine CoNLL data lines until a line boundary
        $conll_line = $conll_line . "££%%££" . $line;
        $num_words++;
    }
    if (eof(STDIN)) {
        $conll_line =~ s/(^\s+|\s+$)//;
        if ($conll_line ne q{}) {
            push @conll_data, $conll_line;
        }
        $conll_line = q{};
    }
    
}

$num_sen = scalar(@conll_data);
print "\n(I). GENERAL STATISTICS\n";
print '-' x 36 . "\n";
my $str_out = sprintf("%-25s %-10s", "item", "value");
print $str_out . "\n";
print '-' x 36 . "\n";
$str_out = sprintf("%-25s %-10s", "number of sentences - ", $num_sen);
print $str_out . "\n";
$str_out = sprintf("%-25s %-10s", "number of words - ", $num_words);
print $str_out . "\n";
print '-' x 36 . "\n";

print "\n(II). DEPENDENCY RELATIONS\n";
print '-' x 36 . "\n";
$str_out = sprintf("%-25s %-10s", "item", "value");
print $str_out . "\n";
print '-' x 36 . "\n";
my @afuns = sort keys %afun_stat;
my $total_words = 0;
foreach my $afun (@afuns) {
    $str_out = sprintf("%-25s %-10s", $afun, $afun_stat{$afun});
    print $str_out . "\n";
    $total_words += $afun_stat{$afun};
}
print '-' x 36 . "\n";
$str_out = sprintf("tagset size - %-25s", scalar(@afuns));
print $str_out . "\n";
print '-' x 36 . "\n";

# Copyright 2011 Loganathan Ramasamy
# This file is distributed under the GNU General Public License v2. See $TMT_ROOT/README.
