#!/usr/bin/env perl
# Processes a set of Treex files in the HamleDT ecosystem, in parallel on the
# cluster. Writes the modified files to the target folder.
# Copyright © 2023 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Cwd;
use cluster; # Dan's library for the ÚFAL cluster

sub usage
{
    print STDERR ("Usage: parallel_treex.pl <input_step> <scenario>\n");
    print STDERR ("    <input_step> is one of:\n");
    print STDERR ("        00 ... the unharmonized Treex files\n");
    print STDERR ("        01 ... the Prague-style HamleDT files (default)\n");
    print STDERR ("        02 ... the Universal Dependencies Treex files\n");
    print STDERR ("    <scenario> will be passed to treex as is.\n");
    print STDERR ("    List of input files will be appended at the end.\n");
    print STDERR ("    The input files are 'data/{00,01,...}/{train,dev,test}/*.treex'.\n");
}

my $input_step;
if(scalar(@ARGV) > 0 && $ARGV[0] =~ m/^[0-9][0-9]$/)
{
    $input_step = shift(@ARGV);
}
# This script may be called the same way as the original treex -p was called.
# Then the call ends with '--' and the glob pattern for the input files. We want
# to remove this part (it will be later replaced with the lists of files in
# chunks) but we can also infer the input step from it.
# -- '!/net/work/people/zeman/hamledt-data/cs-cltt/treex/00/{train,dev,test}/*.treex'
if(scalar(@ARGV) > 1 && $ARGV[-2] eq '--')
{
    my $pattern = pop(@ARGV);
    if($pattern =~ m:/treex/(0[0-9])/:)
    {
        $input_step = $1;
    }
    pop(@ARGV); # remove the '--'
}
elsif(scalar(@ARGV) > 1 && $ARGV[0] eq 'Read::Treex' && $ARGV[1] =~ m/^from=/)
{
    shift(@ARGV); # remove 'Read::Treex'
    my $pattern = shift(@ARGV);
    if($pattern =~ m:/treex/(0[0-9])/:)
    {
        $input_step = $1;
    }
}
if(!defined($input_step))
{
    die("Unknown HamleDT input step");
}
if(scalar(@ARGV) == 0)
{
    die("Unknown Treex scenario");
}

# Typically we either run make prague or make ud. The former converts the input
# Treex files (00) to Prague-style HamleDT (01), the latter converts this to
# Universal Dependencies (02). If we are in the HamleDT normalize subfolder of
# the given treebank, the Treex files are accessible via a path like this:
# data/treex/{00,01,02}/{train,dev,test}/*.treex (or *.treex.gz)
# The total number of files can range from 1 to over 5000.

if(!-d "data/treex/$input_step")
{
    die("Cannot find 'data/treex/$input_step'");
}
my @files_treex = glob("data/treex/$input_step/{train,dev,test}/*.treex");
my @files_treex_gz = glob("data/treex/$input_step/{train,dev,test}/*.treex.gz");
my $nt = scalar(@files_treex);
my $ntg = scalar(@files_treex_gz);
print("In data/treex/$input_step, there are $nt treex files and $ntg treex.gz files (train, dev and test combined).\n");
if($ntg > 0)
{
    die("Processing treebanks with gzipped Treex files is currently not supported");
}
# The job names on the cluster will be derived from the current treebank folder.
my $jobname = getcwd();
$jobname =~ s:^.+/([^/]+)$:$1:;
# For each planned job, collect the names of the files it will process.
my $njobs = 300;
my @jobfiles = ();
my $ijob = 0;
foreach my $f (@files_treex)
{
    push(@{$jobfiles[$ijob]}, $f);
    $ijob++;
    $ijob = 0 if($ijob >= $njobs);
}
# Submit the jobs to the cluster.
my @chunks = ();
my $command = join(' ', ('treex', @ARGV));
my $i = 1;
for my $j (@jobfiles)
{
    # Do not submit empty jobs if there are fewer files than the pre-set $njobs.
    my $n = scalar(@{$j});
    last if($n == 0);
    my $files = join(' ', @{$j});
    my $fcommand = "$command -- $files";
    my $jobid = cluster::qsub('name' => $jobname, 'command' => $fcommand);
    print STDERR ("$jobid: $n files\n");
    push(@chunks, {'number' => $i++, 'job_id' => $jobid});
}
while(cluster::qstat_resubmit(\@chunks))
{
    sleep(5);
}
