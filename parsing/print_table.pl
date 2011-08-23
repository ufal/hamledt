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

my $table = Text::Table->new('trans', @ARGV);
my %value;

foreach my $language (@ARGV) {
    foreach my $dir (glob "$data_dir/$language/treex/*") {
        next if (!-d $dir);
        my $trans = $dir;
        $trans =~ s/^.+\///;
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
    foreach my $language (@ARGV) {
        push @row, $value{$trans}{$language};
    }
    $table->add(@row);
}
print $table;
