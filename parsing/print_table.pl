#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;
use Text::Table;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";

my ($help, $mcd, $mcdproj, $malt);

GetOptions(
    "help|h"  => \$help,
    "mcd"     => \$mcd,
    "mcdproj" => \$mcdproj,
    "malt"    => \$malt,
);


if ($help || !@ARGV) {
    die "Usage: print_table.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --mcd      - McDonald's MST non-projective parser
    --mcdproj  - McDonald's MST projective parser
    --malt     - Malt parser
    -h,--help  - print this help
";
}

my $table = Text::Table->new('trans', @ARGV, 'better', 'worse', 'avg.diff');
my %value;


foreach my $language (@ARGV) {
    foreach my $dir (glob "$data_dir/$language/treex/*") {
        next if (!-d $dir);
        my $trans = $dir;
        $trans =~ s/^.+\///;
        $trans =~ s/002/001/;
        open (UAS, "<:utf8", "$dir/parsed/uas.txt") or next;
        while (<UAS>) {
            chomp;
            my ($sys, $counts, $score) = split /\t/;
            if ($sys =~ /malt/ && $malt) {
                $value{$trans}{$language} = substr($score, 0, 6);
            }
            elsif ($sys =~ /mcdnonproj/ && $mcd) {
                $value{$trans}{$language} = substr($score, 0, 6);
            }
            elsif ($sys =~ /mcdproj/ && $mcdproj) {
                $value{$trans}{$language} = substr($score, 0, 6);
            }
        }
    }
}

foreach my $trans (sort keys %value) {
    my @row = $trans;
    my $better = 0;
    my $worse = 0;
    my $diff = 0;
    my $cnt = 0;
    foreach my $language (@ARGV) {
        push @row, $value{$trans}{$language};
        next if !$value{$trans}{$language};
        $better++ if $value{'001_pdtstyle'}{$language} < $value{$trans}{$language};
        $worse++ if $value{'001_pdtstyle'}{$language} > $value{$trans}{$language};
        $diff += $value{$trans}{$language} - $value{'001_pdtstyle'}{$language};
        $cnt++;
    }
    $diff /= $cnt;
    push @row, ($better, $worse, substr($diff*100,0,5)."%");
    $table->add(@row);
}

print $table->select(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17);
print "\n";
print $table->select(0,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33);
print "\n";
