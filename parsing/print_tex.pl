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

# The result is significant if the difference between the results 
# is the following number. It can be positive, negative or insignificant 
my $signif = 0.5;

#my @transformations = ('orig', 'pdt', grep {!/^(orig|pdt)$/} sort values %new_transf_names );
my @transformations = ('orig', 'pdt');
my %tr_hash = ('orig' => 1, 
                'pdt' => 1);

my $data_dir = Treex::Core::Config::share_dir()."/data/resources/normalized_treebanks/";

my %value;

my @parsers = ( 'malt' );
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
        next if ($trans !~ /^(trans_|000_orig|001_pdtstyle)/);

        $trans =~ s/trans_//;

        $trans = 'orig' if ($trans =~ /^(000_orig)$/);
        $trans = 'pdt' if ($trans =~ /^(001_pdtstyle)$/);

        #$trans = $new_transf_names{$trans};

        if (!exists $tr_hash{$trans}) {
            $tr_hash{$trans} = 1;
            push @transformations, $trans;
        }

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
            if ($sys =~ /maltnivreeager$/) {
                $parser = 'malt';
            }
            elsif ($sys =~ /mcdprojo2$/) {
                $parser = 'mst';
            }

            if ($parser) {
                $value{$trans}{$language}{$parser} = $score;
#                print "t=$trans l=$language s=$sys score=$score\n";
            }
        }
    }
}


sub round {
    my $score = shift;
    return undef if not defined $score;
    return sprintf("\$%.2f\$", $score);
}


print " \\begin{tabular}{|p{6mm}|p{6mm}|p{12mm}||".(join "|",map{"p{1cm}"}(1..$#transformations-1))."|} \\hline \n";

print join(' & ', ('Lang.', @transformations));
print "\\\\ \\hline \\hline \n";

sub table_value {
    my ($trans,$language,$parser) = @_;
    my $value;
    if ($trans eq 'orig') {
        return round($value{$trans}{$language}{$parser}) || '?';
    }
    elsif ($trans eq 'pdt') {
#        return (round($value{$trans}{$language}{$parser}) || '?') .'$\pm$0.50';
        return (round($value{$trans}{$language}{$parser}) || '?');
    }
    else {
        #return round($value{$trans}{$language}{$parser} - $value{pdt}{$language}{$parser});
        if (defined($value{$trans}{$language}{$parser}) && defined($value{pdt}{$language}{$parser})) {
            return round($value{$trans}{$language}{$parser} - $value{pdt}{$language}{$parser});
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

    foreach my $trs (@transformations) {

        my $mstValue = table_value($trs,$language,$parsers[0]);
        my $maltValue = table_value($trs,$language,$parsers[1]);

        $mstValue =~ s/^\$(.+)\$$/$1/;
        $maltValue =~ s/^\$(.+)\$$/$1/;
        
        if ($mstValue eq '?' && ($trs !~ /(orig|pdt)/)) {
            print " &  " . $mstValue. " "; 
            $diff{$trs}{'mst'}{'ins'}++;
        }
        elsif (($mstValue > $signif) && ($trs !~ /(orig|pdt)/)) {
            $diff{$trs}{'mst'}{'pos'}++;
            print " &  " . '{\bf' . " " . $mstValue . '}' . " ";            
            #print " &  " . '{\bf' . " " . table_value($trs,$language,$parsers[0]) . '}' . " ";            
        }
        elsif (($mstValue < -($signif)) && ($trs !~ /(orig|pdt)/)) {
            $diff{$trs}{'mst'}{'neg'}++;
            #print " &  " . table_value($trs,$language,$parsers[0]). " ";
            print " &  " . $mstValue. " ";
        }
        elsif (($mstValue >= -($signif)) && (($mstValue <= $signif)) && ($trs !~ /(orig|pdt)/)) {
            $diff{$trs}{'mst'}{'ins'}++;
            print " &  " . $mstValue . " ";
        }
        elsif ($trs =~ /(orig|pdt)/) {
            print " &  " . $mstValue. " "; 
        }

        if ($maltValue eq '?' && ($trs !~ /(orig|pdt)/)) {
            print $maltValue. " ";                    
            $diff{$trs}{'malt'}{'ins'}++;
        }
        elsif (($maltValue > $signif) && ($trs !~ /(orig|pdt)/)) {
            $diff{$trs}{'malt'}{'pos'}++;
            #print '{\bf' . " " . table_value($trs,$language,$parsers[1]) . '}';
            print '{\bf' . " " . $maltValue . '}';
        }
        elsif (($maltValue < -($signif)) && ($trs !~ /(orig|pdt)/)) {
            $diff{$trs}{'malt'}{'neg'}++;
            #print table_value($trs,$language,$parsers[1]);
            print $maltValue;
        }
        elsif (($maltValue >= -($signif)) && (($maltValue <= $signif)) && ($trs !~ /(orig|pdt)/)) {
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
