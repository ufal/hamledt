#!/usr/bin/perl
use warnings;
use strict;

use Getopt::Std;
use List::Util 'first';

use open qw( :std :utf8 );

our($opt_i, $opt_c);
getopts('i:c:');
my $inconsistencies_output_file = $opt_i || 'STDOUT';
my $corrections_output_file = $opt_c;

my %count; # count of different (sub)trees for each tokens-string
my %tree_tags;  # tags in different (sub)trees for each tokens-string
my %afuns; # afuns -||-
my %IDs;   # IDs of nodes from each tree
my %file;  # the file in which the nodes with IDs are

while ( defined (my $line = <> )) {
    chomp $line;
    my ($language, $tokens, $tree, $tags, $afuns, $file, $IDs) = split "\t", $line;

    # $forms are the words in the surface order, $tokens are in the "tree" (depth-first) order
    my %order = map { my ($form, $order) = split /~/; $form => $order } (split /\s+/, $tokens);
    my $forms = join ' ', sort { $order{$a} <=> $order{$b} } keys %order;

    # strip the tokens (leave only the wordforms)
    $tokens =~ s/~\d+//g;

    # remember the count
    $count{$tokens}{$tree}++;

    # the tags and afuns must be the same for the same tree,
    # but either can be different for a different tree even for the same tokens
    $tree_tags{$tokens}{$tree} = $tags;
    $afuns{$tokens}{$tree} = $afuns;

    # remember the IDs and the file they are from
    push @{$IDs{$tokens}{$tree}}, $IDs;
    push @{$file{$tokens}{$tree}{$IDs}}, $file;
}

# consider the most frequent tags for the given tokens the correct ones
my %tags;
for my $tokens (keys %tree_tags) {
    my @trees_by_count = sort { $count{$tokens}{$b} <=> $count{$tokens}{$a} } keys %{$tree_tags{$tokens}};
    my $most_frequent_tree = $trees_by_count[0];
    $tags{$tokens} = $tree_tags{$tokens}{$most_frequent_tree};
}

# the number of different trees representing the same tokens
my %trees_per_token;
for my $tokens (keys %count) {
    $trees_per_token{$tokens} = scalar (keys %{$count{$tokens}});
}

#inconsistencies

my %count_per_tags;
my %err_per_tags;
for my $tokens (sort { $trees_per_token{$b} <=> $trees_per_token{$b} } grep { $trees_per_token{$_} > 1 } keys %count ) {
    $err_per_tags{ $tags{$tokens} } .= "\n** " . $tokens . "\n";
    $count_per_tags{ $tags{$tokens} }++;
    for my $tree (sort {$count{$tokens}{$b} <=> $count{$tokens}{$a} } keys %{$count{$tokens}} ) {
        $err_per_tags{ $tags{$tokens} } .= "    **$count{$tokens}{$tree}  $tree\n";
    }
}

open my $INCONS, '>', $inconsistencies_output_file;
for my $tags (sort {$count_per_tags{$b} <=> $count_per_tags{$a}} keys %count_per_tags) {
    next if ( $tags =~ /(punc)|(prep)|(conj)/ );
    print $INCONS "\n------------- $tags ----------------------\n";
    #  if ($count_per_tags{$tags} > 1) {print "### $tags\n"};
    print $INCONS $err_per_tags{$tags};
}
close $INCONS;


# corrections

my @corrections;
foreach my $tokens ( grep { $trees_per_token{$_} > 1 } keys %count ) {
    my ($most_frequent_tree, $second_most_frequent_tree) = sort { $count{$tokens}{$b} <=> $count{$tokens}{$a} } keys %{$count{$tokens}};
    next if $count{$tokens}{$most_frequent_tree} == $count{$tokens}{$second_most_frequent_tree};
    my @correct_afuns = split /\s+/, $afuns{$tokens}{$most_frequent_tree};
    foreach my $tree ( keys %{$IDs{$tokens}} ) {
        my $current_afuns = $afuns{$tokens}{$tree};
        my @current_afuns = split /\s+/, $current_afuns;
        my @tokens = split /\s+/, $tokens;
        for my $IDs ( @{$IDs{$tokens}{$tree}} ) {
            my @IDs = split /\s+/, $IDs;
            for my $i (1..$#IDs-1) {
                if ( $current_afuns[$i] ne $correct_afuns[$i] ) {
                    for my $file ( @{$file{$tokens}{$tree}{$IDs}} ) {
                        push @corrections, join("\t", $file, $IDs[$i], $correct_afuns[$i]);
                    }
                }
            }
        }
    }
}

open my $CORRS, '>', $corrections_output_file;
for my $correction ( @corrections) {
    print $CORRS "$correction\n";
}
close $CORRS;




__END__
