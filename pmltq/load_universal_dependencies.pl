#!/usr/bin/env perl
# Imports Universal Dependencies to the PML-TQ server at Lindat.
# Copyright © 2017 Dan Zeman <zeman@ufal.mff.cuni.cz>
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
    print STDERR ("Usage: perl $0 --cluster\n");
    print STDERR ("       ... run pmltq convert on all UD treebanks in parallel on the cluster\n");
    print STDERR ("       ... you must run this from the cluster head node (lrc1 or lrc2)\n");
    print STDERR ("       perl $0\n");
    print STDERR ("       ... without --cluster it will run pmltq load and the rest of actions\n");
    print STDERR ("       ... you must be somewhere with DBD::Pg module (not on the cluster)\n");
}

my $udrel = '21'; # to be used in treebank id ("ud21"), paths etc.
my $cluster = 0;
GetOptions
(
    'cluster' => \$cluster
);

# Treebank codes to process. If this list does not exist or is empty, all treebanks will be processed.
#my @only = qw(ar be bg cs ca cop cs_cac cs_cltt cu da de el en_lines en_partut en es_ancora es et eu fa fi fi_ftb fr fr_partut fr_sequoia ga gl gl_treegal got grc grc_proiel he hi hr hu id it it_partut ja kk ko la la_ittb la_proiel lt lv nl nl_lassysmall no_bokmaal no_nynorsk pl pt pt_br ro ru ru_syntagrus sa sk sl sl_sst sv sv_lines ta tr ug uk ur vi zh);
#my @only = qw(sa sk sl sl_sst sv sv_lines ta tr ug uk ur vi zh);

# Assumption:
# - All UD treebanks have been converted to small Treex files using the HamleDT infrastructure.
# - The Treex files have been copied to /net/work/projects/pmltq/data/ud$udrel using the get_ud.sh script.
# We must work in the treebank folder under pmltq. We will generate files there.
my $wdir = "/net/work/projects/pmltq/data/ud$udrel";
my $data = "$wdir/treex";
chdir($wdir) or die("Cannot enter $wdir: $!");
my $ltcodes_from_json = udlib::get_ltcode_hash('/net/work/people/zeman/unidep');
# The JSON hash converts names to codes. We need the reverse conversion.
# $lcodes->{'Finnish-FTB'} eq 'fi_ftb'
my %ltcode2name;
foreach my $ltname (keys(%{$ltcodes_from_json}))
{
    $ltcode2name{$ltcodes_from_json->{$ltname}} = $ltname;
}
# Not all UD currently existing UD treebanks will be processed (e.g. dev-only versions or non-free treebanks will be skipped).
# Get the list of treebanks actually copied to the data folder.
opendir(DIR, $data) or die('Cannot read the contents of the data folder');
my @folders = sort(grep {-d "$data/$_" && m/^[a-z]/} (readdir(DIR)));
closedir(DIR);
my $i = 0;
foreach my $folder (@folders)
{
    my $ltcode = $folder;
    $ltcode =~ s/-/_/;
    if(scalar(@only)>0 && !grep {$_ eq $ltcode} (@only))
    {
        next;
    }
    $i++;
    my $ltname = $ltcode2name{$ltcode};
    if(!defined($ltname))
    {
        die("Cannot determine language and treebank code for folder '$folder'");
    }
    my $lname = $ltname;
    $lname =~ s/-.*//;
    $lname =~ s/_/ /g;
    my $tname = '';
    if($ltname =~ m/-(.+)$/)
    {
        $tname = $1;
    }
    my $yamlfilename = "pmltq-$ltcode.yml";
    print("$i.\t$folder\t$ltcode\t$ltname\t$lname\t$tname\t$yamlfilename\n");
    my $command = "../../bin/generate_pmltq_yml_for_ud.pl --udrel $udrel --ltcode $ltcode --lname '$lname'";
    $command .= " --tname '$tname'" unless($tname eq '');
    $command .= " > $yamlfilename";
    print("\t$command\n");
    system($command);
    # We want to run the Treex-to-SQL conversion on the cluster and spare some time.
    # We cannot run on the cluster the actual loading of the data to the database
    # because the DBD::Pg module is not properly installed on the cluster.
    my $script = "\#!/bin/bash\n";
    $script .= "cd /net/work/projects/pmltq/data/ud$udrel\n";
    $script .= "date\n";
    if($cluster)
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
