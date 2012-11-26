#!/usr/bin/env perl
use Modern::Perl;

use Getopt::Long;
use Treex::Core::Config;
use Text::Table;

use lib '/home/zeman/lib';
use dzsys;

my $data_dir = Treex::Core::Config->share_dir()."/data/resources/hamledt/";

my ($help, $mcd, $mcdproj, $malt, $maltsmf, $wdirroot, $topdt);
my $filename;

GetOptions(
    "help|h"  => \$help,
    "mcd"     => \$mcd,
    "mcdproj" => \$mcdproj,
    "malt"    => \$malt,
    "maltsmf" => \$maltsmf,
    "topdt"   => \$topdt,
    "filename=s"   => \$filename,
    "wdir=s"  => \$wdirroot,
);
my $signif_diff = 0.1; # TODO: Update this value (for each lang) as soon as Loganathan finishes the significance testing.

if ($help || !@ARGV) {
    die "Usage: print_table.pl [OPTIONS] [LANGUAGES]
    LANGUAGES  - list of ISO codes of languages to be processed
    --mcd      - McDonald's MST non-projective parser
    --mcdproj  - McDonald's MST projective parser
    --malt     - Malt parser
    --maltsmf  - Malt parser with stack algorithm and morph features
    --topdt    - converted back to PDT style
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

if (!$filename) {
    $filename = 'uas.txt';
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
    # Avoid warnings about undefined values in debugging messages.
    $value{'001_pdtstyle'}{$language} = 0;
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
        my $REF = $is_trans =~ /^trans_/ ? '_before' : '';
        my $PDT = $topdt && $is_trans ? 'PDT' : '';
        while (<UAS>) {
            chomp;
            my ($sys, $counts, $score) = split /\t/;
            next if !(
                ($sys =~ /UASpms\($language\_maltnivreeager$PDT,$language$REF\)$/ && $malt) ||
                ($sys =~ /UASpms\($language\_maltstacklazy$PDT,$language$REF\)$/ && $maltsmf) ||
                ($sys =~ /UASpms\($language\_mcdnonprojo2$PDT,$language$REF\)$/ && $mcd) ||
                ($sys =~ /UASpms\($language\_mcdprojo2$PDT,$language$REF\_$/ && $mcdproj));
            $score = $score ? 100 * $score : 0;
            if ($is_trans && defined $value{'001_pdtstyle'}{$language}) {
                $score -= $value{'001_pdtstyle'}{$language};
            }
            $value{$trans}{$language} = round($score);
        }
        if(!defined($value{$trans}{$language}))
        {
            ###!!! DEBUG
            print("$parser_name score not found in $wdir/$filename.\n");
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
