#!/usr/bin/perl
# Copyright © 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

my %hash;
my %nval;
my @treebanks = qw(ar bg-ud11 bn ca cs da-ud11 de de-ud11 el-ud11 en en-ud11 es es-ud11 et eu-ud11 fa fa-ud11 fi-ud11 fi-ud11ftb fr-ud11 ga-ud11 grc he-ud11 hi hr-ud11 hu-ud11 id-ud11 it-ud11 ja la la-it nl pl pt ro ru sk sl sv-ud11 ta te tr);
print("\t");
foreach my $tbk (@treebanks)
{
    open(STATS, "$tbk/featurestats.txt") or next;
    while(<STATS>)
    {
        s/\r?\n$//;
        my ($feature, $count) = split(/\t/, $_);
        $hash{$feature}{$tbk} += $count;
        my ($name, $valuelist) = split(/=/, $feature);
        my @values = split(/,/, $valuelist);
        foreach my $value (@values)
        {
            $nval{$name}{$tbk}{$value}++;
        }
    }
    close(STATS);
    print("$tbk\t");
}
print("\n");
my @features = sort(keys(%hash));
foreach my $feature (@features)
{
    print("$feature\t");
    foreach my $tbk (@treebanks)
    {
        print("$hash{$feature}{$tbk}\t");
    }
    print("\n");
}
# Now only feature names (before it was feature=value).
# Print out the number of distinct values for each feature and treebank.
@features = sort(keys(%nval));
my %fcounts;
foreach my $feature (@features)
{
    print("$feature\t");
    my @counts;
    foreach my $tbk (@treebanks)
    {
        my $n = scalar(keys(%{$nval{$feature}{$tbk}}));
        $n = '' if($n==0);
        print("$n\t");
        push(@{$counts[$n]}, $tbk);
    }
    print("\n");
    $fcounts{$feature} = \@counts;
}
foreach my $feature (@features)
{
    print("$feature: ");
    my @counts = @{$fcounts{$feature}};
    for(my $i = $#counts; $i>0; $i--)
    {
        if(defined($counts[$i]))
        {
            my @tbks = map {s/-ud11//; $_} grep {!m/^(de-ud11|en|es-ud11|fa|fi-ud11ftb|hr|la-it)$/} @{$counts[$i]};
            if(scalar(@tbks)>0)
            {
                my $tbks = join(',', @tbks);
                print("$i ($tbks), ");
            }
        }
    }
    print("\n");
}
