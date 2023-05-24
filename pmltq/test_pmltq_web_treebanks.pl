#!/usr/bin/env perl
# Tests the speed of PMLTQ::Command::get_treebank().
# Copyright © 2023 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use JSON;
use PMLTQ::Command;
use cas;

my $config =
{
    'web_api' =>
    {
        'url'      => 'https://lindat.mff.cuni.cz/services/pmltq/',
        'dbserver' => 'euler',
        'user'     => 'DanZeman',
        'password' => 'klZ2yDWoAN'
    }
};

my $command = PMLTQ::Command->new('config' => $config);
my $ua = $command->ua();
$command->login($ua);
printf STDERR ("%s\tBefore requesting the list of treebanks.\n", cas::datumcas(cas::time2esek(time())));
my $treebanks = $command->get_all_treebanks($ua);
printf STDERR ("%s\tAfter receiving and JSON-decoding the list of treebanks.\n", cas::datumcas(cas::time2esek(time())));
# Categorize the treebanks.
my %categories;
foreach my $t (@{$treebanks})
{
    printf STDERR ("%s\n", $t->{name});
    my $c = 'other';
    if($t->{name} =~ m/^ud[a-z_]+([12][0-9]+)$/)
    {
        $c = 'ud'.$1;
    }
    push(@{$categories{$c}}, $t);
}
printf STDERR ("There are %d treebanks.\n", scalar(@{$treebanks}));
my @categories = sort(keys(%categories));
foreach my $c (@categories)
{
    printf STDERR ("%s\tBefore encoding category %s.\n", cas::datumcas(cas::time2esek(time())), $c);
    my $json = encode_json($categories{$c});
    my $l = length($json);
    printf STDERR ("%s\t%d treebanks\tJSON length %d\n", $c, scalar(@{$categories{$c}}), $l);
    printf STDERR ("%s\tBefore decoding category %s.\n", cas::datumcas(cas::time2esek(time())), $c);
    my $decoded_json = decode_json($json);
}
printf STDERR ("%s\tBefore encoding everything.\n", cas::datumcas(cas::time2esek(time())));
my $json = encode_json($treebanks);
my $l = length($json);
printf STDERR ("ALL\t%d treebanks\tJSON length %d\n", scalar(@{$treebanks}), $l);
printf STDERR ("%s\tBefore decoding everything.\n", cas::datumcas(cas::time2esek(time())));
my $decoded_json = decode_json($json);
printf STDERR ("%s\tEnd.\n", cas::datumcas(cas::time2esek(time())));
