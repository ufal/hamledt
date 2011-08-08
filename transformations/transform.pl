#!/usr/bin/env perl
use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my ($parallel,$help,$all,$alll,$allt);

GetOptions(
    "help|h" => \$help,
    "parallel|p" => \$parallel,
    "all|a" => \$all,
    "alll" => \$alll,
    "allt" => \$allt,
);

sub error {
    my $message = shift;
    die "ERROR: $message
Usage:
  transform.pl [OPTIONS] [LANGUAGES] [TRANSFORMERS]
     LANGUAGES     - list of ISO codes of languages to be processed
     TRANSFORMERS  - list of transformation blocks (short module names, without namespace)
     --alll        - apply the listed transformations on all languages
     --allt        - apply all transformations on the listed languages
     -a,--all      - apply all transformations on all languages (implies --alll and --allt)
     -p,--parallel - submit transformations to the cluster
     -h,--help  -  print this help.
";
}

sub find_available_languages {
    my $share_dir = Treex::Core::Config::share_dir();
    my @languages = grep {/^.{2,3}$/}
        map {/(\w+)$/;$1}
            grep {glob "$_/treex/001_pdtstyle/*/*treex"}
            glob "../../../../share/data/resources/normalized_treebanks/*";
    print STDERR scalar(@languages)," languages with available PDT-styled data: ",(join " ",sort @languages),"\n\n";
    return @languages;
}

sub find_available_transformers {
    my $transformer_dir = Treex::Core::Config::lib_core_dir()."/../Block/A2A/Transform/";
    my @transformers = grep {not /^Base/}
        map {/(\w+).pm$/;$1}
            glob "$transformer_dir/*.pm";
    print (STDERR scalar(@transformers)," available transformers: ",(join " ",sort @transformers),"\n\n");
    return @transformers;
}

if ($help) {
    error('Missing arguments');
}

my @transformers;
my @languages;

my @available_languages = find_available_languages();
my @available_transformers = find_available_transformers();

my @listed_languages;
my @listed_transformers;
foreach my $arg (@ARGV) {
    if ($arg =~ /^[a-z]{2,3}$/) {
        push @listed_languages, $arg;
    }
    elsif ($arg=~ /[A-Z]\w+/) {
        push @listed_transformers, $arg;
    }
    else {
        error("Unrecognized argument '$arg'. Not an option, not a language code, not a transformer name.\n");
    }

};

foreach my $language (@listed_languages) {
    if (not grep {$_ eq $language} @available_languages) {
        error("Language '$language' is not among available languages");
    }
}

if ($alll or $all) {
    if ( @listed_languages) {
        error "No language list can be specified if --all or --alll is present";
    }
    @languages = @available_languages;
}
else {
    @languages = @listed_languages;
}

if ($allt) {
    if (@listed_transformers) {
        error "No transformation list can be specified if --all or --allt is present";
    }
    @transformers = @available_transformers;
}
else {
    @transformers = @listed_transformers;
}

