#!/usr/bin/env perl
use Modern::Perl;

use Getopt::Long;
use Treex::Core::Config;
use Text::Table;

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";

my ($help, $mcd, $mcdproj, $malt, $maltsmf);

GetOptions(
    "help|h"  => \$help,
    "mcd"     => \$mcd,
    "mcdproj" => \$mcdproj,
    "malt"    => \$malt,
    "maltsmf" => \$maltsmf,
);


if ($help || !@ARGV) {
    die "Usage: print_table.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --mcd      - McDonald's MST non-projective parser
    --mcdproj  - McDonald's MST projective parser
    --malt     - Malt parser
    --maltsmf  - Malt parser with stack algorithm and morph features
    -h,--help  - print this help
";
}

my $parser_name =
      $mcd     ? 'MST'
    : $mcdproj ? 'MST-PROJECTIVE'
    : $malt    ? 'MALT-ARC-EAGER'
    : $maltsmf ? 'MALT-STACK-LAZY'
    :            'OOPS';

say '*' x 10 . "  $parser_name  " . '*' x 10;

my $table = Text::Table->new('trans', @ARGV, 'better', 'worse', 'average');
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
            $score = $score ? 100 * $score : 0;

            if ($trans !~ /00/ && defined $value{'001_pdtstyle'}{$language}) {
                $score -= $value{'001_pdtstyle'}{$language};
            }

            if ($sys) {
                if (($sys =~ /maltnivreeager/ && $malt) || ($sys =~ /maltstacklazy/ && $maltsmf) ||
                    ($sys =~ /mcdnonproj/ && $mcd)      || ($sys =~ /mcdproj/ && $mcdproj)) {
                    $value{$trans}{$language} = round($score);
                }
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
    # Warning: $cnt can be zero if we do not have $value for either this transformation or for 001_pdtstyle.
    $diff /= $cnt if($cnt);
    push @row, ($better, $worse, round($diff));
    $table->add(@row);
}

my $langs = @ARGV;
if ($langs < 18){
    say $table;
} else {
    say $table->select(0 .. ($langs/2)+1);
    say $table->select(0,($langs/2)+2 .. $langs+3);
}
