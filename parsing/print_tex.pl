#!/usr/bin/env perl

use strict;
use warnings;
use Treex::Core::Config;

my %new_transf_names = (
    '000_orig' => 'orig',
    '001_pdtstyle' => 'pdt',
    CoordChainRootFirst => 'fM hL',
    CoordChainRootLast => 'fM hR',
    CoordTreeRootFirst => 'fS hL',
    CoordTreeRootLast => 'fS hR',
    SharedModifBelowNearestMember => 'sN',
);

my @transformations = ('orig', 'pdt', grep {!/^(orig|pdt)$/} sort values %new_transf_names );

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";

my %value;

my @parsers = ( 'mst', 'malt' );
my @languages = grep {$_ =~ /^.{2,3}$/ and $_ !~/^(jpn|zh)$/}
    map {s/.+\///;$_}
    glob "$data_dir/*";


foreach my $language (@languages) {
  DIR:
    foreach my $dir (glob "$data_dir/$language/treex/*") {
        next if (!-d $dir);
        my $trans = $dir;
        $trans =~ s/^.+\///;
        # exception for Estonian, where 001_dep is treated as 000_orig and pdtstyle has number 002
        if ($language eq 'et') {
            $trans =~ s/002_pdtstyle/001_pdtstyle/;
            $trans =~ s/001_dep/000_orig/;
        }

        $trans =~ s/trans_//;
        $trans = $new_transf_names{$trans};
        next DIR unless $trans;

        open (UAS, "<:utf8", "$dir/parsed/uas.txt") or next;
        while (<UAS>) {
            chomp;
            my ($sys, $counts, $score) = split /\t/;
            $score = $score ? 100 * $score : 0;

            if ($trans !~ /00/ && defined $value{'001_pdtstyle'}{$language}) {
                $score -= $value{'001_pdtstyle'}{$language};
            }

            my $parser;
            if ($sys =~ /maltnivreeager/) {
                $parser = 'malt';
            }
            elsif ($sys =~ /mcdproj/) {
                $parser = 'mst';
            }

            if ($parser) {
                $value{$trans}{$language}{$parser} = $score;
#                print "t=$trans l=$language s=$sys\n";
            }
        }
    }
}


sub round {
    my $score = shift;
    return undef if not defined $score;
    return sprintf("\$%.2f\$", $score);

}


print " \\begin{tabular}{|p{6mm}|p{6mm}|p{12mm}||".(join "|",map{"p{7mm}"}(1..$#transformations-1))."|} \\hline \n";

print join(' & ', ('Lang.', @transformations));
print "\\\\ \\hline \\hline \n";

sub table_value {
    my ($trans,$language,$parser) = @_;
    my $value;
    if ($trans eq 'orig') {
        return round($value{$trans}{$language}{$parser}) || '?';
    }
    elsif ($trans eq 'pdt') {
        return (round($value{$trans}{$language}{$parser}) || '?') .'$\pm$0.50';
    }
    else {
        return round($value{$trans}{$language}{$parser} - $value{pdt}{$language}{$parser});
    }

}


foreach my $language (@languages) {
    print "$language & ".join(' & ', 
                              map { table_value($_,$language,$parsers[0]) . " "
                                        . table_value($_,$language,$parsers[1]) } @transformations);
    print "\\\\ \\hline \n";

}

print "\\hline\n Aver. ";
foreach my $trans (@transformations) {
    print ' & ';
    foreach my $parser (@parsers) {
        my $sum;
        foreach my $language (@languages) {
            if ($trans =~ /orig|pdt/) {
                $sum += ($value{$trans}{$language}{$parser} || 0);
            }
            else {
                $sum += $value{$trans}{$language}{$parser} - $value{pdt}{$language}{$parser};
            }
        }
        print round($sum / scalar @languages)." ";
    }
}

print "\\\\ \\hline\n";


my %diff;
my %diff_label = (
    'pos' => 'Significantly positive change',
    'ins' => 'Insignificant change',
    'neg' => 'Significantly negative change',
);


foreach my $difference_type ('pos','ins','neg') {
    print "\\multicolumn{3}{|l|}{$diff_label{$difference_type}} ";
    foreach my $trans (grep {$_ !~ /orig|pdt/} @transformations) {
        print ' & ';
        foreach my $parser (@parsers) {
            print $diff{$trans}{$parser}{$difference_type} || '?';
            print ' ';
        }
    }
    print "\\\\ \\hline\n";
}

print "\n\\end{tabular}\n";
