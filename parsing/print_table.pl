#!/usr/bin/env perl
use Modern::Perl;

use Getopt::Long;
use Treex::Core::Config;
use Text::Table;

use lib '/home/zeman/lib';
use dzsys;

my $data_dir = Treex::Core::Config->share_dir()."/data/resources/hamledt/";

my $help;
my $wdirroot;
my $eval = 'pms';
my $parser = 'malt';
my $filename = 'uas.txt';
my $transform = 'there-and-back';

GetOptions(
    "help|h"  => \$help,
    "parser=s"  => \$parser,
    "transform=s" => \$transform,
    "eval=s"  => \$eval,
    "wdir=s"  => \$wdirroot,
    "filename=s" => \$filename,
);
my $signif_diff = 0.1; # TODO: Update this value (for each lang) as soon as Loganathan finishes the significance testing.

if ($help || !@ARGV) {
    die "Usage: print_table.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --parser   - parser: 'mcd', 'mcdproj', 'malt', or 'maltsmf'. Default is 'malt'.
    --eval     - type o evaluation: p (parent), pm (parent, is_member), pms (parent, is_member, is_shared_modifier). Default is 'pms'.
    --wdir     - path to working folder
                 default: $data_dir\${LANGUAGE}/treex/\${TRANSFORMATION}/parsed
                 if --wdir \$WDIR set: \${WDIR}/\${LANGUAGE}/\${TRANSFORMATION}
                 i.e. separately from the unparsed data and possibly from other experiments
    -h,--help  - print this help
";
}
# Lazy to enumerate all languages?
if (scalar(@ARGV)==1 && $ARGV[0] eq 'all') {
    @ARGV = qw(ar bg bn ca cs da de el en es eu fi grc hi hu it ja la nl pt ro ru sl sv ta te tr);
}

my %parser_name = (mcd => 'MST', mcdproj => 'MST-PROJECTIVE', malt => 'MALT-ARC-EAGER', maltsmf => 'MALT-STACK-LAZY');
my %parser_selector = (mcd => 'mcdnonprojo2', mcdproj => 'mcdprojo2', malt => 'maltnivreeager', maltsmf => 'maltstacklazy');

print "********** $parser_name{$parser} **********\n";

my $table = Text::Table->new('trans', @ARGV, 'better', 'worse', 'average');
my %value;

foreach my $language (@ARGV) {
    # Avoid warnings about undefined values in debugging messages.
    foreach my $dir (glob "$data_dir/$language/treex/*") {
        next if (!-d $dir);
        # Get the name of the current transformation.
        my $trans = $dir;
        $trans =~ s/^.+\///;
        my $is_trans = $trans =~ /^trans_/ ? 1 : 0;
        # Set the path to the folder where the training data and the trained model shall be.
        my $wdir = $wdirroot ? "$wdirroot/$language/$trans" : "$dir/parsed";
        if(!-d $wdir) {
            print("Directory $wdir not found.\n");
            next;
        }
        if(!open(UAS, "<:utf8", "$wdir/$filename"))
        {
            ###!!! DEBUG
            print("Cannot read $wdir/$filename: $!");
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
            elsif ($is_trans && $transform ne 'there-only' && $sys eq "UAS$eval(".$language."_".$parser_selector{$parser}."BASE,".$language."_before)") {
                $value{$trans}{$language} -= $score ? 100 * $score : 0;
            }
            elsif ($is_trans && $transform eq 'there-only' && $sys eq "UAS$eval($language"."_$parser_selector{$parser},$language)") {
                $value{$trans}{$language} += $score ? 100 * $score : 0;
            }
            elsif ($is_trans && $transform eq 'there-only' && $sys eq "UAS$eval(".$language."_".$parser_selector{$parser}."BASE,".$language."_before)") {
                $value{$trans}{$language} -= $score ? 100 * $score : 0;
            }
            elsif ($trans eq "001_pdtstyle" && $sys eq "UAS$eval(".$language."_".$parser_selector{$parser}.",".$language.")") {
                $value{$trans}{$language} = $score ? 100 * $score : 0;
            }
            elsif ($trans eq "000_orig" && $sys eq "UAS$eval(".$language."_".$parser_selector{$parser}.",".$language.")") {
                $value{$trans}{$language} = $score ? 100 * $score : 0;
            }
        }
        if(!defined($value{$trans}{$language}))
        {
            ###!!! DEBUG
            #print("$parser_name{$parser} score not found in $wdir/$filename.\n");
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
if ($langs < 18){
    say $table;
} else {
    say $table->select(0 .. ($langs/2)+1);
    say $table->select(0,($langs/2)+2 .. $langs+3);
}
