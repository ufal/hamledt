#!/usr/bin/env perl
# Imports Universal Dependencies to the PML-TQ server at Lindat.
# Copyright © 2017, 2018 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Getopt::Long;
use cluster;
# The UD library is not in $PERL5LIB.
use lib '/net/work/people/zeman/unidep/tools';
use udlib;

sub usage
{
    my $er = '25'; # example release number
    print STDERR ("Usage: perl $0 --release $er --cluster [cs_pdt cs_cac]\n");
    print STDERR ("       ... run pmltq convert on all UD treebanks in parallel on the cluster\n");
    print STDERR ("       ... you must run this from the cluster head node (sol1 to sol10)\n");
    print STDERR ("       ... optional args: codes of treebanks to process (default: all)\n");
    print STDERR ("       perl $0 --release $er\n");
    print STDERR ("       ... without --cluster it will run pmltq load and the rest of actions\n");
    print STDERR ("       ... you must be somewhere with DBD::Pg module (not on the cluster)\n");
    print STDERR ("       perl $0 --release $er --configonly\n");
    print STDERR ("       ... generates the YAML configuration file for every treebank but does not do anything else\n");
    print STDERR ("       ... useful for checking that the configuration is correct before we attempt to use it\n");
    print STDERR ("       perl $0 --release $er --clean\n");
    print STDERR ("       ... it will run pmltq delete and webdelete, without attempting to re-upload\n");
    print STDERR ("       ... if we messed up names in the previous attempt, run the cleanup first,\n");
    print STDERR ("       ... then use the fixed script with new names to re-upload\n");
}

my $udrel; # e.g. '22' for UD release 2.2; to be used in treebank id ("ud22"), paths etc.
my $clean = 0;
my $cluster = 0;
my $configonly = 0;
GetOptions
(
    'release=s'  => \$udrel,
    'clean'      => \$clean,
    'cluster'    => \$cluster,
    'configonly' => \$configonly
);
if(!defined($udrel) || $udrel !~ m/^2[0-9]$/)
{
    print STDERR ("Missing or wrong release number. Expected e.g. '22' for UD release 2.2.\n");
    usage();
    die;
}

# Treebank codes to process. If this list does not exist or is empty, all treebanks will be processed.
#my @only = qw(ar be bg cs ca cop cs_cac cs_cltt cu da de el en_lines en_partut en es_ancora es et eu fa fi fi_ftb fr fr_partut fr_sequoia ga gl gl_treegal got grc grc_proiel he hi hr hu id it it_partut ja kk ko la la_ittb la_proiel lt lv nl nl_lassysmall no_bokmaal no_nynorsk pl pt pt_br ro ru ru_syntagrus sa sk sl sl_sst sv sv_lines ta tr ug uk ur vi zh);
my @only = @ARGV;

# Assumption:
# - All UD treebanks have been converted to small Treex files using the HamleDT infrastructure.
# - The Treex files have been copied to /net/work/projects/pmltq/data/ud$udrel using the get_ud.sh script.
# We must work in the treebank folder under pmltq. We will generate files there.
my $wdir = "/net/work/projects/pmltq/data/ud$udrel";
my $data = "$wdir/treex";
chdir($wdir) or die("Cannot enter $wdir: $!");
# Get mapping between language codes and names.
my $languages = udlib::get_language_hash('/net/work/people/zeman/unidep/docs-automation/codes_and_flags.yaml');
# The language hash converts names to codes. We need the reverse conversion.
# $lcode2name{'Ancient Greek'} eq 'grc'
my %lcode2name;
foreach my $lname (keys(%{$languages}))
{
    $lcode2name{$languages->{$lname}{lcode}} = $lname;
}
# Get mapping between treebank codes and names (they differ only in letter case).
# Normally we would see the treebank name in the folder name. But folder names
# in PMLTQ are different from UD releases, so we must look in a UD folder.
my @udfolders = udlib::list_ud_folders('/net/work/people/zeman/unidep');
my %tcode2name;
my %summary;
foreach my $folder (@udfolders)
{
    my $record1 = udlib::get_ud_files_and_codes($folder, '/net/work/people/zeman/unidep');
    $tcode2name{$record1->{tcode}} = $record1->{tname};
    my $record2 = udlib::read_readme($folder, '/net/work/people/zeman/unidep');
    $summary{$folder} = defined($record2->{summary}) ? $record2->{summary} : $folder;
    # We want to be able to put the summary on a command line in single quotes.
    $summary{$folder} =~ s/'/ /g; # '
    print("\$summary{$folder} = '$summary{$folder}'\n");
}
# Not all currently existing UD treebanks will be processed (e.g. dev-only versions or non-free treebanks will be skipped).
# Get the list of treebanks actually copied to the data folder.
opendir(DIR, $data) or die('Cannot read the contents of the data folder');
my @folders = sort(grep {-d "$data/$_" && m/^[a-z]/} (readdir(DIR)));
closedir(DIR);
my $i = 0;
foreach my $folder (@folders)
{
    next if($folder eq 'resources');
    print("\$summary{$folder} = '$summary{$folder}'\n");
    my $ltcode = $folder;
    # In names of treebank folders for PML-TQ, language code is separated from treebank code by a hyphen ('-').
    # However, the script generate_pmltq_yml_for_ud.pl expects a code as in names of UD CoNLL-U files, separated by underscore ('_').
    $ltcode =~ s/-/_/;
    my $lcode = $ltcode;
    my $tcode = '';
    if($ltcode =~ m/^([a-z]+)_([a-z]+)$/)
    {
        $lcode = $1;
        $tcode = $2;
    }
    # If we wanted to process only a subset of the treebanks, check that this one is listed.
    if(scalar(@only)>0 && !grep {$_ eq $ltcode} (@only))
    {
        next;
    }
    $i++;
    my $lname = $lcode2name{$lcode};
    if(!defined($lname))
    {
        die("Cannot determine language name for folder '$folder'");
    }
    # Treebank name and code only differ in case (CamelCase vs. all lowercase).
    # We currently do not have a list of tbkname => TbkName correspondences.
    my $tname = $tcode2name{$tcode};
    if(!defined($tname))
    {
        die("Cannot determine treebank name for folder '$folder'");
    }
    my $yamlfilename = "pmltq-$ltcode.yml";
    print("$i.\t$folder\t$ltcode\t$ltname\t$lname\t$tname\t$yamlfilename\n");
    my $command = "../../bin/generate_pmltq_yml_for_ud.pl --udrel $udrel --ltcode $ltcode --lname '$lname'";
    $command .= " --tname '$tname'" unless($tname eq '');
    $command .= " --summary '$summary{$folder}'";
    $command .= " > $yamlfilename";
    print("\t$command\n");
    system($command);
    # Do not create and run a script if we only want to generate the config files.
    next if($configonly);
    # We want to run the Treex-to-SQL conversion on the cluster and spare some time.
    # We cannot run on the cluster the actual loading of the data to the database
    # because the DBD::Pg module is not properly installed on the cluster.
    my $script = "\#!/bin/bash\n";
    $script .= "cd /net/work/projects/pmltq/data/ud$udrel\n";
    $script .= "date\n";
    if($clean)
    {
        $script .= "echo pmltq webdelete --config=\"$yamlfilename\"\n";
        $script .= "pmltq webdelete --config=\"$yamlfilename\"\n";
        $script .= "echo pmltq delete --config=\"$yamlfilename\"\n";
        $script .= "pmltq delete --config=\"$yamlfilename\"\n";
    }
    elsif($cluster)
    {
        # PMLTQ does not create the output folder if it does not exist.
        # Moreover, it emits a confusing message that $output_dir is undefined (although the config file defines it).
        $script .= "mkdir -p sql_dump/$folder\n";
        $script .= "echo pmltq convert --config=\"$yamlfilename\"\n";
        $script .= "pmltq convert --config=\"$yamlfilename\"\n";
    }
    else
    {
        $script .= "echo pmltq webdelete --config=\"$yamlfilename\"\n";
        $script .= "pmltq webdelete --config=\"$yamlfilename\"\n";
        $script .= "echo pmltq delete --config=\"$yamlfilename\"\n";
        $script .= "pmltq delete --config=\"$yamlfilename\"\n";
        $script .= "echo pmltq initdb --config=\"$yamlfilename\"\n";
        $script .= "pmltq initdb --config=\"$yamlfilename\"\n";
        $script .= "echo pmltq load --config=\"$yamlfilename\"\n";
        $script .= "pmltq load --config=\"$yamlfilename\"\n";
        $script .= "echo pmltq verify --config=\"$yamlfilename\"\n";
        $script .= "pmltq verify --config=\"$yamlfilename\"\n";
        $script .= "echo pmltq webload --config=\"$yamlfilename\"\n";
        $script .= "pmltq webload --config=\"$yamlfilename\"\n";
        $script .= "echo pmltq webverify --config=\"$yamlfilename\"\n";
        $script .= "pmltq webverify --config=\"$yamlfilename\"\n";
        $script .= "date\n";
    }
    my $scriptname = "process-$ltcode.sh";
    open(SCRIPT, "> $scriptname") or die("Cannot write '$scriptname': $!");
    print SCRIPT ($script);
    close(SCRIPT);
    chmod(0755, $scriptname) or die("Cannot chmod 0755 '$scriptname': $!");
    # Cluster or local processing?
    # We must be logged in to lrc1 or lrc2 to be able to submit jobs to the cluster.
    if($cluster)
    {
        my $jobid = cluster::qsub('script' => $scriptname, 'name' => $ltcode);
    }
    else
    {
        $command = "$scriptname 2>&1 | tee log-$ltcode.log";
        print("\t$command\n");
        system($command);
    }
}
