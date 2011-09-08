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
        # exception for Estonian, where 001_dep is treated as 000_orig and pdtstyle has number 002
        if ($language eq 'et') {
            $trans =~ s/002_pdtstyle/001_pdtstyle/;
            $trans =~ s/001_dep/000_orig/;
        }
        open (UAS, "<:utf8", "$dir/parsed/uas.txt") or next;
        while (<UAS>) {
            chomp;
            my ($sys, $counts, $score) = split /\t/;
            $score = 100 * $score;

            if ($trans !~ /00/ && defined $value{'001_pdtstyle'}{$language}) {
                $score -= $value{'001_pdtstyle'}{$language};
            }

            if ($sys =~ /malt/ && $malt) {
                $value{$trans}{$language} = round($score);
            }
            elsif ($sys =~ /mcdnonproj/ && $mcd) {
                $value{$trans}{$language} = round($score);
            }
            elsif ($sys =~ /mcdproj/ && $mcdproj) {
                $value{$trans}{$language} = round($score);
            }
        }
    }
}


sub round {
    my $score = shift;
    return undef if not defined $score;
    return sprintf("%.2f", $score);

}

foreach my $trans (sort keys %value) {
    my @row = $trans;
    my $better = 0;
    my $worse = 0;
    my $diff = 0;
    my $cnt = 0;
    foreach my $language (@ARGV) {
        push @row, $value{$trans}{$language};
        next if !$value{$trans}{$language} || !$value{'001_pdtstyle'}{$language};
            $better++ if  $value{$trans}{$language} > 0;
            $worse++ if  $value{$trans}{$language} < 0;
            $diff += $value{$trans}{$language};
            $cnt++;
        }
        $diff /= $cnt;
        push @row, ($better, $worse, round($diff));
    $table->add(@row);
}

print $table->select(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17);
print "\n";
print $table->select(0,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33);
print "\n";
