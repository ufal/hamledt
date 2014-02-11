#!/usr/bin/perl
use warnings;
use strict;

use open qw( :std :utf8 );

my %cnt;
my %tags;

while ( defined (my $line = <> )) {
    chomp $line;
    next if ($line eq '');
    my ($tokens,$tree,$tags) = split /\t/, $line;
    $cnt{$tokens}{$tree}++;
    $tags{$tokens}=$tags;
    #  print "$tokens xxxxx $tree\n";
}

my %trees_per_token;
foreach my $tokens (keys %cnt) {
    $trees_per_token{$tokens}=(keys %{$cnt{$tokens}});
}

my %err_per_tags;
my %cnt_per_tags;
foreach my $token (sort { $trees_per_token{$b} <=> $trees_per_token{$a} } grep { $trees_per_token{$_}>1 } keys %cnt) {
    $err_per_tags{ $tags{$token} }.="\n** $token\n";
    $cnt_per_tags{ $tags{$token} }++;
    foreach my $tree (sort { $cnt{$token}{$b} <=> $cnt{$token}{$a} } keys %{ $cnt{$token} }) {
        $err_per_tags{ $tags{$token} } .= "   **$cnt{$token}{$tree}  $tree\n";
    }
}

foreach my $tags (sort {$cnt_per_tags{$b}<=>$cnt_per_tags{$a}} keys %cnt_per_tags) {
    next if ( $tags =~ /(punc)|(prep)|(conj)/ );
    print "\n------------- $tags ----------------------";
    #  if ($cnt_per_tags{$tags} > 1) {print "### $tags\n"};
    print $err_per_tags{$tags};

}
