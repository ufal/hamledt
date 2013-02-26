#!/usr/bin/env perl
use Modern::Perl;

use Getopt::Long;
use Treex::Core::Config;
use Text::Table;

my $share_dir = Treex::Core::Config->share_dir();
my $data_dir = "$share_dir/data/resources/hamledt";
my $script_dir = "/home/marecek/treex/devel/hamledt/parsing";

my $help;
my $wdirroot = '/net/cluster/TMP/marecek/hamledt_parsing';
my $eval = 'pms';
my $parser = 'malt';
my $filename = 'uas.txt';
my $transform = 'there-and-back';
my $transformations = '000_orig,001_pdtstyle,trans_fMhLsNcBpP,trans_fMhMsNcBpP,trans_fMhRsNcBpP,trans_fPhLsHcHpB,trans_fPhMsHcHpB,trans_fPhRsHcHpB,trans_fShLsNcBpP,trans_fShMsNcBpP,trans_fShRsNcBpP';

GetOptions(
    "help|h"  => \$help,
    "parser=s"  => \$parser,
    "transform=s" => \$transform,
    "eval=s"  => \$eval,
    "wdir=s"  => \$wdirroot,
    "filename=s" => \$filename,
);

my $signif_diff = 0.1;
# TODO: Update this value (for each lang) as soon as Loganathan finishes the significance testing.

if ($help || !@ARGV) {
    die "Usage: print_table.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --parser   - parser: 'mcd', 'mcdproj', 'malt', or 'maltsmf'. Default is 'malt'.
    --eval     - type o evaluation: p (parent), pm (parent, is_member), pms (parent, is_member, is_shared_modifier). Default is 'pms'.
    --wdir     - path to working folder
    -h,--help  - print this help
";
}

my %parser_name = (mcd => 'MST', mcdproj => 'MST-PROJECTIVE', malt => 'MALT-ARC-EAGER', maltsmf => 'MALT-STACK-LAZY');
my %parser_selector = (mcd => 'mcd', mcdproj => 'mcdproj', malt => 'malt', maltsmf => 'maltsmf');

print "********** $parser_name{$parser} **********\n";

my $table = Text::Table->new('trans', @ARGV, 'better', 'worse', 'average');
my %value;

foreach my $language (@ARGV) {

    foreach my $trans ( split(/,/, $transformations)) {

        # From where the data will be taken
        my $wdir = "$wdirroot/$language/$trans";
        next if (!-d $wdir);

        my $is_trans = $trans =~ /^trans_/ ? 1 : 0;

        # Chdir to the working folder so that all scripts and logs are also created there.
        chdir($wdir) or die("Cannot change to $wdir: $!");

        if (!open(UAS, "<:utf8", "$wdir/uas.txt")) {
            print STDERR "Cannot read $wdir/uas.txt: $!";
            next;
        }
        my $my_score;
        my $base_score;
        while (<UAS>) {
            chomp;
            my ($sys, $counts, $score) = split /\t/;
            if ($is_trans && $transform ne 'there-only' && $sys eq "UAS$eval(".$language."_".$parser_selector{$parser}."PDT,".$language."_before)") {
                $value{$trans}{$language} += $score ? 100 * $score : 0;
            }
            elsif ($is_trans && $transform eq 'there-only' && $sys eq "UAS$eval($language"."_$parser_selector{$parser},$language)") {
                $value{$trans}{$language} += $score ? 100 * $score : 0;
            }
            elsif ($is_trans && $sys eq "UAS$eval(".$language."_".$parser_selector{$parser}."BASE,".$language."_before)") {
                $value{$trans}{$language} -= $score ? 100 * $score : 0;
            }
            elsif ($trans eq "001_pdtstyle" && $sys eq "UAS$eval(".$language."_".$parser_selector{$parser}.",".$language.")") {
                $value{$trans}{$language} = $score ? 100 * $score : 0;
            }
            elsif ($trans eq "000_orig" && $sys eq "UAS$eval(".$language."_".$parser_selector{$parser}.",".$language.")") {
                $value{$trans}{$language} = $score ? 100 * $score : 0;
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
        push @row, round($value{$trans}{$language});
        next if !$value{$trans}{$language} || !$value{'001_pdtstyle'}{$language};
        $better++ if  $value{$trans}{$language} > $signif_diff;
        $worse++ if  $value{$trans}{$language} < -$signif_diff;
        $diff += $value{$trans}{$language};
        $cnt++;
    }
    # Warning: $cnt can be zero if we do not have $value for either this transformation or for 001_pdtstyle.
    $diff /= $cnt if($cnt);
    push @row, ($better, $worse, round($diff));
    $table->add(@row);
}

my $langs = @ARGV;
if ($langs < 18) {
    say $table;
}
else {
    say $table->select(0 .. ($langs / 2 + 1));
    say $table->select(0, ($langs / 2 + 2) .. ($langs + 3));
}
