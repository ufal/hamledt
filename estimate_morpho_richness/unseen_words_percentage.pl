#!/usr/bin/env perl

use strict;
use warnings;

my $window_size = 1000;

my %size;
my %unseen_in_window;

my %tokens_in_window;
my %is_in_window;

my $window_lenght;

while (<>) {
    chomp;
    my ($language,$token) = split /\t/, lc($_);
    next if $token =~ /^[\p{IsPunct}\d]+$/;

#    next if $language ne 'cs';
    $size{$language}++;

    if ( $size{$language} > $window_size ) {

        if (not exists $is_in_window{$language}{$token}) {
            $unseen_in_window{$language}++;
#            print "unseen: $token\n";
        }
        else {
#            print "seen: $token\n";
        }

        # remove the oldest token from the window
        my $token_to_forgot = shift @{$tokens_in_window{$language}};
        $is_in_window{$language}{$token_to_forgot}--;
        if ($is_in_window{$language}{$token_to_forgot} == 0) {
            delete $is_in_window{$language}{$token_to_forgot};
        }
    }

    # push the newest token into the window
    if (not $tokens_in_window{$language}) {
        $tokens_in_window{$language} = [];
    }
    push @{$tokens_in_window{$language}}, $token;
    $is_in_window{$language}{$token}++;

}

my %unseen_percentage;
foreach my $language (keys %size) {
    $unseen_percentage{$language} = $unseen_in_window{$language}/$size{$language};
}

foreach my $language (sort {$unseen_percentage{$a}<=>$unseen_percentage{$b}} keys %size) {
    print "$language\t$unseen_percentage{$language}\n";
}
