#!/usr/bin/perl
use strict;
use warnings;

my %tags;

while ( defined(my $line = <>) ) {
    next if $line eq "\n";
    chomp $line;
#    die "Error in line: $line" unless /^(.+?)\s*\t\s*(\S+)(\s+(.+?))?\s*$/;
    my ($word, $tag) = split /\s+/, $line;
#    $word = $1;
#    $tag = $2;
    $tags{$word}->{$tag} = 1;

#    $lemma = (defined $4) ? $4 : "-";
#    $lemma{"$w\t$t"} = $l;
}

# foreach $p (sort keys %lemma) {
#     my($w,$t) = split(/\t/,$p);
#     $tags{$w} .= "\t$t $lemma{$p}";
# }

for my $word (sort keys %tags) {
    next if $word =~ /^[0-9][0-9,.:;\/]+$/;
    print $word;
    for my $tag (sort keys %{$tags{$word}}) {
        print "\t", $tag, " -";
    }
    print "\n";
}
