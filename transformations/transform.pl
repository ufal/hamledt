#!/usr/bin/env perl
use strict;
use warnings;

use Getopt::Long;
use Treex::Core::Config;

my ($parallel, $help, $alll);
my $family = 'Moscow';
my $punctuation = 'previous';
my $conjunction = 'between';
my $head = 'left';
my $shared = 'nearest';

GetOptions(
    "help|h" => \$help,
    "parallel|p" => \$parallel,
    "alll" => \$alll,
    "family=s" => \$family,
    "punctuation=s" => \$punctuation,
    "conjunction=s" => \$conjunction,
    "head=s" => \$head,
    "shared=s" => \$shared,
);

sub error {
    my $message = shift;
    die "ERROR: $message
Run transform.pl --help to see its correct usage.
";
}

sub usage {
    die "Usage:
  transform.pl [OPTIONS] [LANGUAGES] [TRANSFORMERS]
     LANGUAGES     - list of ISO codes of languages to be processed
     --alll        - apply the listed transformations on all languages
     -a,--all      - apply all transformations on all languages (implies --alll and --allt)
     -p,--parallel - submit transformations to the cluster
     -h,--help  -  print this help.
";
}

my $data_dir = Treex::Core::Config->share_dir()."/data/resources/normalized_treebanks/";

sub find_available_languages {
    my $share_dir = Treex::Core::Config->share_dir();
    my @languages = grep {/^.{2,3}$/}
        map {/(\w+)$/;$1}
            grep {
                 my @files = glob "$_/treex/*_pdtstyle/*/*.treex.gz";
                 @files > 0;
            }
            glob "$data_dir/*";

    print STDERR scalar(@languages)," languages with available PDT-styled data: ",(join " ",sort @languages),"\n\n";
    return @languages;
}

sub find_available_transformers {
    my $transformer_dir = Treex::Core::Config->lib_core_dir()."/../Block/A2A/Transform/";
    my @transformers = grep {not /^(Base|Inv)/}
        map {/(\w+).pm$/;$1}
            glob "$transformer_dir/*.pm";
    print (STDERR scalar(@transformers)," available transformers: ",(join " ",sort @transformers),"\n\n");
    return @transformers;
}

if ($help) {
    usage('');
}

my @languages;

my @available_languages = find_available_languages();

my @listed_languages;
foreach my $arg (@ARGV) {
    if ($arg =~ /^[a-z]{2,3}$/) {
        push @listed_languages, $arg;
    }
    else {
        error("Unrecognized argument '$arg'. Not an option, not a language code.\n");
    }

};

foreach my $language (@listed_languages) {
    if (not grep {$_ eq $language} @available_languages) {
        error("Language '$language' is not among available languages");
    }
}

if ($alll) {
    if ( @listed_languages) {
        error "No language list can be specified if --alll is present";
    }
    @languages = @available_languages;
}
else {
    @languages = @listed_languages;
}


if (not @languages) {
    error "Languages to be processed must be specified, either by listing them or by --alll or --all options.";
}

foreach my $language (@languages) {
    my $jobs = '';
    if ($language =~ /en|de|cs|ru/){ # these datasets are bigger, so more jobs make it faster # TODO more elegant
        $jobs = '-p -j 5';
    }
    foreach my $f (split /,/, $family) {
        foreach my $p (split /,/, $punctuation) {
            foreach my $c (split /,/, $conjunction) {
                next if ($f eq 'Prague' && $c ne 'head') || ($f ne 'Prague' && $c eq 'head');
                foreach my $h (split /,/, $head) {
                    foreach my $s (split /,/, $shared) {
                        my $name = 'f'.uc(substr($f,0,1)).'h'.uc(substr($h,0,1)).'s'.uc(substr($s,0,1)).'c'.uc(substr($c,0,1)).'p'.uc(substr($p,0,1));
                        my $command_line = "treex $jobs -L$language "
                                         . "Util::Eval bundle='\$bundle->remove_zone(qw($language),qw(orig))' " # remove the original trees (before PDT styling)
                                         . "A2A::CopyAtree selector=before "                                    # store the trees before transformation to zone "before"
                                         . "A2A::DeleteAfunCoordWithoutMembers "                                # TODO this should be done already within the normalization
                                         . "A2A::Transform::CoordStyle2 style=$name from_style=fPhRsHcHpB "     # transform the zone with empty selector
                                         . "A2A::CopyAtree selector=inverse "                                   # copy the trees after transformation to zone "inverse"
                                         . "A2A::Transform::CoordStyle2 from_style=$name style=fPhRsHcHpB selector=inverse "  # make the inverse transformation in zone "inverse"
                                         . "Util::Eval document='my \$path=\$document->path; \$path=~s/00._pdtstyle/trans_$name/;use File::Path qw(mkpath); mkpath(\$path);\$document->set_path(\$path);' "
                                         . "Write::Treex -- $data_dir/$language/treex/*_pdtstyle/t*/*.treex.gz";
                        open(BS, ">:utf8", "tr-$language-$name.sh") or die;
                        print BS "#!/bin/bash\n\n$command_line\n";
                        close BS;
                        system "qsub -hard -l mf=1g -l act_mem_free=1g -cwd -j yes tr-$language-$name.sh\n";
                        #sleep 2; # wait few secs, so the jobs can be send to the cluster
                    }
                }
            }
        }
    }
}

