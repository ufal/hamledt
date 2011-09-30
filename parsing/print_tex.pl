#!/usr/bin/env perl

use strict;
use warnings;
use Treex::Core::Config;

my %trans_hash = ('000_orig'          => 'orig',
                  '001_pdtstyle'      => 'pdt',
trans_fMpPcBhLsN => 'fM hL sN cB pP',
trans_fMpPcBhMsN => 'fM hM sN cB pP',
trans_fMpPcBhRsH => 'fM hR sH cB pP',
trans_fMpPcBhRsN => 'fM hR sN cB pP',
trans_fMpPcPhLsN => 'fM hL sN cP pP',
trans_fMpPcPhRsN => 'fM hR sN cP pP',
trans_fPpBcHhRsH => 'fP hR sH cH pB',
trans_fPpBcHhRsN => 'fP hR sN cH pB',
trans_fSpPcBhLsN => 'fS hL sN cB pP',
trans_fSpPcBhMsN => 'fS hM sN cB pP',
trans_fSpPcBhRsH => 'fS hR sH cB pP',
trans_fSpPcBhRsN => 'fS hR sN cB pP',
);

my @transformations = ('orig', 'pdt');
my %tr_hash = ('orig' => 1, 
                'pdt' => 1);

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";

my %value;
my %conf;

my @parsers = ('mst', 'malt');

my @languages = grep {$_ =~ /^.{2,3}$/ and $_ !~/^(jp|zh|ca|et|is)$/}
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

        # Just to make sure that only the standard directories are explored
        # next if ($trans !~ /^(trans_|000_orig|001_pdtstyle)/);
        next if (!exists $trans_hash{$trans});


        #$trans =~ s/trans_//;
        #
        #$trans = 'orig' if ($trans =~ /^(000_orig)$/);
        #$trans = 'pdt' if ($trans =~ /^(001_pdtstyle)$/);
        
        $trans = $trans_hash{$trans};
        
        if (!exists $tr_hash{$trans}) {
            $tr_hash{$trans} = 1;
            push @transformations, $trans;
        }

        next DIR unless $trans;

        open (UAS, "<:utf8", "$dir/parsed/uas_conf.txt") or next;
        while (<UAS>) {
            chomp;
            my ($sys, $score, $confint) = split /\s+/;
            $score = $score ? 100 * $score : 0;
            $confint =~ s/\(\+\/\-\)//;
            $confint = $confint ? 100 * $confint : 0;
            
            #if ($trans !~ /00/ && defined $value{'pdt'}{$language}) {
            #    $score -= $value{'pdt'}{$language};
            #}

            my $parser;
            if ($sys =~ /maltnivreeager$/) {
                $parser = 'malt';
            }
            elsif ($sys =~ /mcdprojo2$/) {
                $parser = 'mst';
            }

            if ($parser) {
                $value{$trans}{$language}{$parser} = $score;
                $conf{$trans}{$language}{$parser} = $confint;
            }
        }
    }
}


sub round {
    my $score = shift;
    return undef if not defined $score;
    return sprintf("%.2f", $score);
}


print " \\begin{tabular}{|p{6mm}|p{6mm}|p{8mm}||".(join "|",map{"p{0.6cm}"}(1..$#transformations-1))."|} \\hline \n";
print join(' & ', ('Lang.', @transformations));
print "\\\\ \\hline \\hline \n";

sub table_value {
    my ($trans,$language,$parser) = @_;
    my $value;
    if ($trans eq 'orig') {
        return round($value{$trans}{$language}{$parser}) || '?';
    }
    elsif ($trans eq 'pdt') {
        return (round($value{$trans}{$language}{$parser}) || '?') . '$\pm$' . (round($conf{$trans}{$language}{$parser}) || '?');
    }
    else {        
        if (defined($value{$trans}{$language}{$parser})) {          
            if (defined($value{pdt}{$language}{$parser})) {
              return round($value{$trans}{$language}{$parser} - $value{pdt}{$language}{$parser});  
            }
            else {
              return '?';
            }            
        }
        else {
            return '?';
        }
    }
}

my %diff;
my %diff_label = (
    'pos' => 'Significantly positive change',
    'ins' => 'Insignificant change',
    'neg' => 'Significantly negative change',
);


foreach my $language (@languages) {
    print "$language  ";

    my $confmst = $conf{'pdt'}{$language}{'mst'};
    my $confmalt = $conf{'pdt'}{$language}{'malt'};

    foreach my $trs (@transformations) {

        my $mstValue = table_value($trs,$language,$parsers[0]);
        my $maltValue = table_value($trs,$language,$parsers[1]);
        

        if (($trs !~ /(orig|pdt)/) && $mstValue eq '?') {
            print " &  " . $mstValue. " "; 
            $diff{$trs}{'mst'}{'ins'}++;
        }
        elsif (($trs !~ /(orig|pdt)/) && ($mstValue > $confmst) ) {
            $diff{$trs}{'mst'}{'pos'}++;
            print " &  " . '{\bf' . " " . $mstValue . '}' . " ";
        }
        elsif (($trs !~ /(orig|pdt)/) && ($mstValue < -($confmst))) {
            $diff{$trs}{'mst'}{'neg'}++;
            print " &  " . $mstValue. " ";
        }
        elsif (($trs !~ /(orig|pdt)/) && ($mstValue >= -($confmst)) && (($mstValue <= $confmst))) {
            $diff{$trs}{'mst'}{'ins'}++;
            print " &  " . $mstValue . " ";
        }
        elsif ($trs =~ /(orig|pdt)/) {
            print " &  " . $mstValue. " "; 
        }

        if (($trs !~ /(orig|pdt)/) && $maltValue eq '?' ) {
            print $maltValue. " ";                    
            $diff{$trs}{'malt'}{'ins'}++;
        }
        elsif (($trs !~ /(orig|pdt)/) && ($maltValue > $confmalt)) {
            $diff{$trs}{'malt'}{'pos'}++;
            print '{\bf' . " " . $maltValue . '}';
        }
        elsif (($trs !~ /(orig|pdt)/) && ($maltValue < -($confmalt))) {
            $diff{$trs}{'malt'}{'neg'}++;
            print $maltValue;
        }
        elsif (($trs !~ /(orig|pdt)/) && ($maltValue >= -($confmalt)) && (($maltValue <= $confmalt))) {
            $diff{$trs}{'malt'}{'ins'}++;
            print $maltValue;
        }
        elsif ($trs =~ /(orig|pdt)/) {
            print $maltValue; 
        }
    }
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

foreach my $difference_type ('pos','ins','neg') {
    print "\\multicolumn{3}{|l|}{$diff_label{$difference_type}} ";
    foreach my $trans (grep {$_ !~ /orig|pdt/} @transformations) {
        print ' & ';
        foreach my $parser (@parsers) {
            print $diff{$trans}{$parser}{$difference_type}  || '?';
            print ' ';
        }
    }
    print "\\\\ \\hline\n";
}

print "\n\\end{tabular}\n";
