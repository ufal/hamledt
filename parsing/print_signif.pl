#!/usr/bin/env perl
use strict;
use warnings;
my $ALPHA = 0.1;

use Treex::Core::Config;
my $data_dir = Treex::Core::Config->share_dir()."/data/resources/hamledt/";
my @languages = qw(ar bg bn cs da de el en es eu fi grc hi hu it ja la nl pt ro ru sl sv ta te tr);
#my @languages = qw(cs);

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

sub load_samples {
  my ($file) = @_;
  open my $S, '<:utf8', $file or return;
  my %samples;
  while (<$S>){
    next if /orig|before|PDT|regardless/;
    next if !/maltnivreeager/; #mcdnonprojo2
    my ($name,$fraction,$score) = split;
    $samples{$name} = [] if !$samples{$name};
    push @{$samples{$name}}, $score;
  }
  return %samples;
}

foreach my $language (@languages) {
    my %pdt_samples = load_samples("$data_dir/$language/treex/001_pdtstyle/parsed/uas_samples.txt");

    DIR:
    foreach my $dir (glob "$data_dir/$language/treex/trans*") {
        next if (!-d $dir);
        my $trans = $dir;
        $trans =~ s/^.+\///;
        next if !$trans_hash{$trans};        
        $trans = $trans_hash{$trans};

        my %trans_samples = load_samples("$dir/parsed/uas_samples.txt");
        
        foreach my $name (keys %pdt_samples){
            my @gold = @{$pdt_samples{$name}};
            if (!$trans_samples{$name}){
                warn "$name not in $dir/parsed/uas_samples.txt\n";
                next DIR;
            }
            my @test = @{$trans_samples{$name}};
            if (@gold != @test){
                warn "$name in $dir/parsed/uas_samples.txt has different #of samples\n";
                next DIR;
            }
            for my $i (0..$#gold){
                $test[$i] -= $gold[$i];
            }
            @test = sort @test;
            my $size = $#gold;
            my $index_lower = int(($ALPHA / 2) * $size);
            my $index_upper = $size - $index_lower;
            my ($lower,$upper) = @test[$index_lower, $index_upper];
            my $change = $lower >= 0 ? 'positive' : $upper <= 0 ? 'negative' : 'insignificant';
            print "$name\t$trans\t$change\t$lower\t$upper\n" #.join('|',@test)."\n";
        }
    }
}


