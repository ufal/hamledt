#!/usr/bin/perl
# Searches experimental folders of all languages and prints a summary of successes and failures.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

sub usage
{
    my $usage = "status.pl --wdir experimentRootFolder\n";
    $usage   .= "                 expected storage hierarchy: \${experimentRootFolder}/\${LANGUAGE}/\${TRANSFORMATION}\n";
    $usage   .= "          --eqw-resubmit\n";
    $usage   .= "                 cluster jobs that failed to start, their state is Eqw and their script is known will be resubmitted\n";
    return $usage;
}

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use Getopt::Long;
use lib '/home/zeman/lib';
use dzsys;
use cluster;

GetOptions
(
    'help|h'       => \$help,
    'wdir=s'       => \$wdirroot,
    'eqw-resubmit' => \$eqw_resubmit
);

if($help || !$wdirroot)
{
    die(usage());
}
# Switch to the experiment root folder.
# Absolutize it first so that we can return there from everywhere.
$wdirroot = dzsys::absolutize_path($wdirroot);
print("Experiment root folder = $wdirroot\n");
chdir($wdirroot) or die("Cannot enter $wdirroot: $!\n");
# All subfolders of the current folder are languages.
my @languages = sort(dzsys::get_subfolders('.'));
my $n_langs = scalar(@languages);
print("Found $n_langs languages: ", join(' ', @languages), "\n");
# Search through every language.
foreach my $lang (@languages)
{
    print("===== LANGUAGE $lang =====\n");
    my $lpath = "$wdirroot/$lang";
    chdir($lpath) or die("Cannot enter $lpath: $!\n");
    # All subfolders of the current folder are transformations (including the 000_orig and 001_pdtstyle baselines).
    my @transformations = sort(dzsys::get_subfolders('.'));
    my $n_trans = scalar(@transformations);
    my @compressed = map {my $x = $_; $x =~ s/^(00[01])_.*$/$1/; $x =~ s/^trans_//; $x} (@transformations);
    print("Found $n_trans transformations: ", join(' ', @compressed), "\n");
    # Search through every transformation.
    foreach my $trans (@transformations)
    {
        my $tpath = "$lpath/$trans";
        chdir($tpath) or die("Cannot enter $tpath: $!\n");
        print("Current path = $tpath\n");
        #system('ls -al');
        # Check that all parser models have been trained.
        my @models = qw(malt_nivreeager.mco malt_stacklazy.mco mcd_proj_o2.model mcd_nonproj_o2.model);
        foreach my $model (@models)
        {
            if(!-e $model)
            {
                print("$model not found\n");
                $missing{$model}++;
            }
        }
        # Collect numbers of cluster jobs related to this transformation.
        my @cluster_logs = grep {m/\.sh\.o\d+$/} (dzsys::get_files('.'));
        foreach my $log (@cluster_logs)
        {
            my ($script, $jobid);
            if($log =~ m/^(.*\.sh)\.o(\d+)$/)
            {
                $script = $1;
                $jobid = $2;
            }
            else
            {
                die("Unknown job ID for log $log.");
            }
            my %job =
            (
                'path'   => $tpath,
                'lpath'  => "$tpath/$log",
                'spath'  => "$tpath/$script",
                'script' => $script,
            );
            $jobs{$jobid} = \%job;
        }
    }
}
# Are any related jobs still running on the cluster?
my %qstat = cluster::qstat0();
my @my_jobs = grep {$qstat{$_}{user} eq $ENV{USER}} (sort {$a<=>$b} (keys(%qstat)));
print("Current user = $ENV{USER}\n");
my $n_jobs = scalar(@my_jobs);
print("This user has $n_jobs jobs on the cluster.\n");
foreach my $jobid (@my_jobs)
{
    my $job = $qstat{$jobid};
    $jobstates{$job->{state}}++;
    if($job->{state} eq 'r' && exists($jobs{$jobid}))
    {
        print("Job $jobid still running: $jobs{$jobid}{spath}\n");
    }
    elsif($job->{state} eq 'Eqw')
    {
        # Even jobs that failed to start may have produced a log file that helps us to bind them to their experiment.
        if(exists($jobs{$jobid}))
        {
            print("Job $jobid failed to start: $jobs{$jobid}{spath}\n");
            system("qstat -j $jobid | grep 'error reason'");
            if($eqw_resubmit)
            {
                my $job = $jobs{$jobid};
                if(-f $job->{spath})
                {
                    print("$job->{spath} will be resubmitted.\n");
                    # Go to the folder of the script so that the logs are written there again.
                    print("Going back to $job->{path}.\n");
                    chdir($job->{path}) or die("Cannot change to $job->{path}: $!\n");
                    # We do not know the original memory requirements for the job.
                    # Let's reserve a whole 32GB machine for it.
                    $job->{new_jobid} = cluster::qsub('script' => $job->{script}, 'memory' => '31g');
                    print("New job id = $job->{new_jobid}\n");
                    dzsys::saferun("qdel $jobid");
                }
            }
        }
        else
        {
            print("Job $jobid failed to start: unknown experiment\n");
        }
    }
}
foreach my $state (keys(%jobstates))
{
    my $estate = $state;
    $estate = 'r (running)' if($estate eq 'r');
    $estate = 'Eqw (failed to start)' if($estate eq 'Eqw');
    print("Number of jobs in state $estate = $jobstates{$state}\n");
}
print("==========\n");
foreach my $model (sort(keys(%missing)))
{
    print("Missing $model $missing{$model} times.\n");
}



#------------------------------------------------------------------------------
# Jednorázová oprava resubmitu, který jsem zkazil (a ty úlohy už jsou smazané z qstatu).
#------------------------------------------------------------------------------
sub oprava
{
    my $log = <<EOF
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/en/trans_fMpPcBhRsH/smf-en-tfMpPcBhRsH.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/000_orig/mcd-ar-000_orig.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/000_orig/mcp-ar-000_orig.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/001_pdtstyle/mcd-ar-001_pdtstyle.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/001_pdtstyle/mcp-ar-001_pdtstyle.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fMpPcBhLsN/mcd-ar-tfMpPcBhLsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fMpPcBhLsN/mcp-ar-tfMpPcBhLsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fMpPcBhMsN/mcd-ar-tfMpPcBhMsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fMpPcBhMsN/mcp-ar-tfMpPcBhMsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fMpPcBhRsH/mcd-ar-tfMpPcBhRsH.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fMpPcBhRsH/mcp-ar-tfMpPcBhRsH.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fMpPcBhRsN/mcd-ar-tfMpPcBhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fMpPcBhRsN/mcp-ar-tfMpPcBhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fMpPcPhLsN/mcd-ar-tfMpPcPhLsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fMpPcPhLsN/mcp-ar-tfMpPcPhLsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fMpPcPhRsN/mcd-ar-tfMpPcPhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fMpPcPhRsN/mcp-ar-tfMpPcPhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fPpBcHhRsH/mcd-ar-tfPpBcHhRsH.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fPpBcHhRsH/mcp-ar-tfPpBcHhRsH.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fPpBcHhRsN/mcd-ar-tfPpBcHhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fPpBcHhRsN/mcp-ar-tfPpBcHhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fSpPcBhLsN/mcd-ar-tfSpPcBhLsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fSpPcBhLsN/mcp-ar-tfSpPcBhLsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fSpPcBhMsN/mcd-ar-tfSpPcBhMsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fSpPcBhMsN/mcp-ar-tfSpPcBhMsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fSpPcBhRsH/mcd-ar-tfSpPcBhRsH.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fSpPcBhRsH/mcp-ar-tfSpPcBhRsH.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fSpPcBhRsN/mcd-ar-tfSpPcBhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/ar/trans_fSpPcBhRsN/mcp-ar-tfSpPcBhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/000_orig/mcd-bg-000_orig.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/000_orig/mcp-bg-000_orig.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/001_pdtstyle/mcd-bg-001_pdtstyle.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/001_pdtstyle/mcp-bg-001_pdtstyle.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fMpPcBhLsN/mcd-bg-tfMpPcBhLsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fMpPcBhLsN/mcp-bg-tfMpPcBhLsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fMpPcBhMsN/mcd-bg-tfMpPcBhMsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fMpPcBhMsN/mcp-bg-tfMpPcBhMsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fMpPcBhRsH/mcd-bg-tfMpPcBhRsH.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fMpPcBhRsN/mcd-bg-tfMpPcBhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fMpPcBhRsN/mcp-bg-tfMpPcBhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fMpPcPhLsN/mcd-bg-tfMpPcPhLsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fMpPcPhLsN/mcp-bg-tfMpPcPhLsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fMpPcPhRsN/mcd-bg-tfMpPcPhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fMpPcPhRsN/mcp-bg-tfMpPcPhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fPpBcHhRsH/mcd-bg-tfPpBcHhRsH.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fPpBcHhRsH/mcp-bg-tfPpBcHhRsH.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fPpBcHhRsN/mcd-bg-tfPpBcHhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fPpBcHhRsN/mcp-bg-tfPpBcHhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fSpPcBhLsN/mcd-bg-tfSpPcBhLsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fSpPcBhLsN/mcp-bg-tfSpPcBhLsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fSpPcBhMsN/mcd-bg-tfSpPcBhMsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fSpPcBhMsN/mcp-bg-tfSpPcBhMsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fSpPcBhRsH/mcd-bg-tfSpPcBhRsH.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fSpPcBhRsH/mcp-bg-tfSpPcBhRsH.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fSpPcBhRsN/mcd-bg-tfSpPcBhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/bg/trans_fSpPcBhRsN/mcp-bg-tfSpPcBhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/cs/000_orig/mcd-cs-000_orig.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/cs/000_orig/mcp-cs-000_orig.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/cs/trans_fMpPcBhLsN/mcd-cs-tfMpPcBhLsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/cs/trans_fMpPcBhLsN/mcp-cs-tfMpPcBhLsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/cs/trans_fMpPcBhMsN/mcd-cs-tfMpPcBhMsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/cs/trans_fMpPcBhMsN/mcp-cs-tfMpPcBhMsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/cs/trans_fMpPcBhRsH/mcd-cs-tfMpPcBhRsH.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/cs/trans_fMpPcBhRsH/mcp-cs-tfMpPcBhRsH.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/cs/trans_fMpPcBhRsN/mcd-cs-tfMpPcBhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/cs/trans_fMpPcBhRsN/mcp-cs-tfMpPcBhRsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/cs/trans_fMpPcPhLsN/mcd-cs-tfMpPcPhLsN.sh would be resubmitted.
/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus/cs/trans_fMpPcPhLsN/mcp-cs-tfMpPcPhLsN.sh would be resubmitted.
EOF
    ;
    my @skripty = split(/\r?\n/, $log);
    my $n = scalar(@skripty);
    print("Zkazil jsem $n úloh.\n");
    my $koren = '/ha/work/people/zeman/tectomt/treex/devel/normalize_treebanks/parsing/pokus';
    foreach my $radek (@skripty)
    {
        $radek =~ s/ would be resubmitted\.$//;
        $radek =~ s-$koren/--;
        if($radek =~ m-^([^/]+)/([^/]+)/([^/]+\.sh)$-)
        {
            my $jazyk = $1;
            my $trans = $2;
            my $skript = $3;
            my $cesta = "$koren/$jazyk/$trans";
            # Go to the folder of the script so that the logs are written there again.
            print("Going back to $cesta.\n");
            chdir($cesta) or die("Cannot change to $cesta: $!\n");
            # Pro jistotu znovu ověřit, že skript existuje.
            if(!-f $skript)
            {
                die("$skript does not exist.");
            }
            # We do not know the original memory requirements for the job.
            # Let's reserve a whole 32GB machine for it.
            my $jobid = cluster::qsub('script' => $skript, 'memory' => '31g');
            print("New job id = $jobid\n");
        }
        else
        {
            die("Cannot understand script path $radek.");
        }
    }
}
