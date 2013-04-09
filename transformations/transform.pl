#!/usr/bin/env perl

use strict;
use warnings;
use File::stat;

use Getopt::Long;
use Treex::Core::Config;

my ($help, $alll);
my $family = 'Moscow';
my $punctuation = 'previous';
my $conjunction = 'between';
my $head = 'left';
my $shared = 'nearest';

GetOptions(
    "help|h" => \$help,
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
  transform.pl [OPTIONS] [LANGUAGES]
     LANGUAGES     - list of ISO codes of languages to be processed
     -a,--all      - apply the transformations on all languages
     -h,--help     - print this help.
     See Treex::Block::A2A::Transform::CoordStyle for details on options
     --family, --punctuation, --conjunction, --head, --shared.
";
}

my $data_dir = Treex::Core::Config->share_dir()."/data/resources/hamledt";

sub find_available_languages {
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

# process language only if the 001_pdtstyle is newer than trans_*
@languages = grep {stat("$data_dir/$_/treex/001_pdtstyle/test/001.treex.gz")->mtime > stat("$data_dir/$_/treex/trans_fMhLsNcBpP/test/001.treex.gz")->mtime} @languages;
print STDERR "Languages to be processed: " . join(", ", @languages) . "\n";

my $langs_wildcard = '{' . join(',', @languages) . '}';
my $JOBS= 5 * @languages;

foreach my $f (split /,/, $family) {
    foreach my $p (split /,/, $punctuation) {
        foreach my $c (split /,/, $conjunction) {
            next if ($f eq 'Prague' && $c ne 'head') || ($f ne 'Prague' && $c eq 'head');
            foreach my $h (split /,/, $head) {
                foreach my $s (split /,/, $shared) {
                    my $name = 'f'.uc(substr($f,0,1)).'h'.uc(substr($h,0,1)).'s'.uc(substr($s,0,1)).'c'.uc(substr($c,0,1)).'p'.uc(substr($p,0,1));
                    my $command_line = "treex -p -j $JOBS "
                                     . "Util::Eval zone='\$zone->get_bundle()->remove_zone(\$zone->language,qw(orig))' " # Remove the original trees (before PDT styling).
                                     . "A2A::BackupTree to_selector=before "                            # Store the trees before transformation to zone "before".
                                     . "A2A::DeleteAfunCoordWithoutMembers "                            # TODO this should be done already within the normalization.
                                     . "A2A::SetSharedModifier "                                        # Attributes is_shared_modifier and wild->is_coord_conjunction
                                     . "A2A::SetCoordConjunction "                                      # must be filled before running the transformation.
                                     . "A2A::Transform::CoordStyle style=$name from_style=fPhRsHcHpB "  # Transform the zone with empty selector.
                                     . "A2A::BackupTree to_selector=inverse "                           # Copy the trees after transformation to zone "inverse".
                                     . "Util::SetGlobal selector=inverse "                              # The rest of the scenario operates on this "inverse" zone.
                                     #. "A2A::SetCoordConjunction " # is this needed?
                                     . "A2A::Transform::CoordStyle from_style=$name style=fPhRsHcHpB "  # Make the inverse transformation in zone "inverse"
                                     . "Align::AlignSameSentence to_selector=before "                   # and align it to the normalized tree.
                                     . "Write::Treex substitute={00._pdtstyle}{trans_$name} "           # Save the resulting treex files to a new directory.      
                                     . "Print::EvalAlignedAtrees report_errors=0 "                      # Compute UAS (output contains the new filename)
                                     . "-- '!$data_dir/$langs_wildcard/treex/*_pdtstyle/t*/*.treex.gz'" # Input files.
                                     . " > round_trip_$name.txt";                                       # Output round-trip statistics
                    open(BS, ">:utf8", "tr-$name.sh") or die;
                    print BS "#!/bin/bash\n\n$command_line\n";
                    close BS;
                    system "qsub -hard -l mf=1g -l act_mem_free=1g -l h_vmem=1g -cwd -j yes tr-$name.sh\n";
                }
            }
        }
    }
}
