#!/usr/bin/perl
# Searches experimental folders of all languages and prints a summary of successes and failures.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

sub usage
{
    my $usage = "status.pl --wdir experimentRootFolder [OPTIONS] |& tee status.log\n";
    $usage   .= "                 expected storage hierarchy: \${experimentRootFolder}/\${LANGUAGE}/\${TRANSFORMATION}\n";
    $usage   .= "          --eqw-resubmit\n";
    $usage   .= "                 cluster jobs that failed to start, their state is Eqw and their script is known will be resubmitted\n";
    $usage   .= "          --mem-resubmit\n";
    $usage   .= "                 cluster jobs that failed because Java did not have enough memory will be resubmitted\n";
    $usage   .= "          --net-resubmit\n";
    $usage   .= "                 cluster jobs that failed because of IO/network problems, including sudden deaths, will be resubmitted\n";
    $usage   .= "          --nojob-resubmit\n";
    $usage   .= "                 scripts that were not even submitted (or no log found), will be submitted now\n";
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
use cas;

GetOptions
(
    'help|h'         => \$help,
    'wdir=s'         => \$wdirroot,
    'eqw-resubmit'   => \$eqw_resubmit,
    'mem-resubmit'   => \$mem_resubmit,
    'net-resubmit'   => \$net_resubmit,
    'nojob-resubmit' => \$nojob_resubmit
);

if($help || !$wdirroot)
{
    die(usage());
}
# Get the list of jobs currently running or waiting on the cluster.
# We will compare it with the logs we find in the experiment folders.
my %qstat = cluster::qstat0();
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
        my $scripttrans = $trans;
        $scripttrans =~ s/^trans_/t/;
        my %scripts =
        (
            'malt_nivreeager.mco'  => "mlt-$lang-$scripttrans.sh",
            'malt_stacklazy.mco'   => "smf-$lang-$scripttrans.sh",
            'mcd_proj_o2.model'    => "mcp-$lang-$scripttrans.sh",
            'mcd_nonproj_o2.model' => "mcd-$lang-$scripttrans.sh"
        );
        foreach my $model (@models)
        {
            # Remember for every model of every experiment whether we found it.
            my $mpath = "$tpath/$model";
            $models{$mpath}{filename} = $model;
            if(!-e $model)
            {
                $models{$mpath}{found} = 0;
                print("$model not found\n");
                # We are going to search job logs and assign jobs to intended target models.
                # However, it is possible that a target has no job log because the job did not even start.
                # In such a case we want to know whether there is the script for the job or not.
                if(-f $scripts{$model})
                {
                    $models{$mpath}{script} = $scripts{$model};
                    $models{$mpath}{spath} = "$tpath/$scripts{$model}";
                }
            }
            else
            {
                $models{$mpath}{found} = 1;
                # If we found the model but it was too old, it may also mean that the current run has failed.
                my $timestamp = cas::esek2datumcas(cas::cassoubor($model));
                print("$model ... $timestamp\n");
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
            # Classify the job as training or parsing.
            my ($type, $output);
            if($script =~ m/^(mlt|smf|mcd|mcp)-/)
            {
                my $parser = $1;
                $type = 'training';
                # Remember the expected output name for every job.
                if($parser eq 'mlt')
                {
                    $output = 'malt_nivreeager.mco';
                }
                elsif($parser eq 'smf')
                {
                    $output = 'malt_stacklazy.mco';
                }
                elsif($parser eq 'mcd')
                {
                    $output = 'mcd_nonproj_o2.model';
                }
                else
                {
                    $output = 'mcd_proj_o2.model';
                }
                # At the same time, for every expected output remember the jobs that attempted to create it
                # (there may be more than one job that attempted to create a particular model).
                my $mpath = "$tpath/$output";
                push(@{$models{$mpath}{jobs}}, $jobid);
            }
            else
            {
                $type = 'unknown';
            }
            my %job =
            (
                'id'     => $jobid,
                'path'   => $tpath,
                'log'    => $log,
                'lpath'  => "$tpath/$log",
                'spath'  => "$tpath/$script",
                'script' => $script,
                'type'   => $type,
                'output' => $output,
                'opath'  => "$tpath/$output",
            );
            $jobs{$jobid} = \%job;
        }
    }
}
# Are any related jobs still running on the cluster?
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
        $jobs{$jobid}{running} = 1;
    }
    elsif($job->{state} eq 'qw')
    {
        # From the point of view of hope for success, this is as if it was running.
        ###!!! We won't see it in statistics anyway because it has not produced a log yet, so we cannot bind it to a target.
        ###!!! We could bind it using the job name, though.
        $jobs{$jobid}{running} = 1;
    }
    elsif($job->{state} eq 'Eqw')
    {
        # Even jobs that failed to start may have produced a log file that helps us to bind them to their experiment.
        if(exists($jobs{$jobid}))
        {
            $jobs{$jobid}{waiting} = 1;
            print("Job $jobid failed to start: $jobs{$jobid}{spath}\n");
            system("qstat -j $jobid | grep 'error reason'");
            if($eqw_resubmit)
            {
                resubmit($jobs{$jobid});
            }
        }
        else
        {
            print("Job $jobid failed to start: unknown experiment\n");
        }
    }
}
# Identify jobs that have finished but their output was not found.
foreach my $jobid (keys(%jobs))
{
    my $job = $jobs{$jobid};
    if(!$job->{running} && !-f $job->{opath})
    {
        # Get the full log of the job. Perhaps it contains the reason for the failure.
        $job->{logtext} = `cat $job->{lpath}`;
        # Many jobs fail because Java VM does not have enough memory.
        if($job->{logtext} =~ m/Could not reserve enough space for object heap/)
        {
            #print("Missing $job->{opath}, found corresponding log $job->{lpath}: $reason\n");
            $job->{lowmem} = 1;
        }
        # A job may also fail to read the input or write the output (due to network problem).
        # This is what the Malt parser would say in such a case:
        elsif($job->{logtext} =~ m/The learner cannot write to the instance file/ ||
              $job->{logtext} =~ m/error reading zip file/)
        {
            $job->{io} = 1;
        }
        # NullPointerException in MST Parser reader probably indicates failed reading input.
        elsif($job->{logtext} =~ m/java\.lang\.NullPointerException/)
        {
            $job->{nullpointer} = 1;
        }
        # Sometimes the Malt Parser throws this exception. I do not have a solution yet.
        elsif($job->{logtext} =~ m/The learner class 'org\.maltparser\.ml\.lib\.LibSvm' cannot be initialized./)
        {
            $job->{libsvm} = 1;
        }
    }
}
# Loop over all expected outputs, determine whether they exist and if not, determine the cause.
my @models = sort(keys(%models));
foreach my $mpath (@models)
{
    my $type = $models{$mpath}{filename};
    $m_total{$type}++;
    if($models{$mpath}{found})
    {
        $m_found{$type}++;
    }
    else
    {
        # Identify the most recent job that attempts or attempted to build this model.
        my @jobids = sort {$b<=>$a} (@{$models{$mpath}{jobs}});
        if(@jobids)
        {
            my $jobid = $jobids[0];
            my $job = $jobs{$jobid};
            if($job->{running})
            {
                $m_running{$type}++;
            }
            else
            {
                $m_lost{$type}++;
                if($job->{lowmem})
                {
                    print("LOWMEM $job->{opath}\n");
                    print("   see $job->{lpath}\n");
                    $m_lowmem{$type}++;
                    resubmit($job) if($mem_resubmit);
                }
                elsif($job->{io})
                {
                    print("IO/NET $job->{opath}\n");
                    print("   see $job->{lpath}\n");
                    $m_io{$type}++;
                    resubmit($job) if($net_resubmit);
                }
                elsif($job->{nullpointer})
                {
                    print("NULLPT $job->{opath}\n");
                    print("   see $job->{lpath}\n");
                    $m_nullpointer{$type}++;
                    resubmit($job) if($net_resubmit);
                }
                elsif($job->{libsvm})
                {
                    print("LIBSVM $job->{opath}\n");
                    print("   see $job->{lpath}\n");
                    $m_libsvm{$type}++;
                }
                else
                {
                    $m_sudden{$type}++;
                    print("-------------\n");
                    print("SUDDEN DEATH?\n");
                    print("$job->{opath}\n");
                    print("$job->{logtext}");
                    print("$job->{opath}\n");
                    resubmit($job) if($net_resubmit);
                }
            }
        }
        # No job found for the target!
        else
        {
            print("NO JOB $mpath\n");
            $m_nojob{$type}++;
            if($models{$mpath}{spath})
            {
                print(" rerun $models{$mpath}{spath}\n");
                if($nojob_resubmit)
                {
                    my $spath = $models{$mpath}{spath};
                    my ($path, $script);
                    if($spath =~ m-^(.+)/([^/]+\.sh)$-)
                    {
                        $path = $1;
                        $script = $2;
                    }
                    else
                    {
                        die("Cannot parse $spath.");
                    }
                    my %job = ('spath' => $spath, 'path' => $path, 'script' => $script);
                    resubmit(\%job);
                }
            }
        }
    }
}
print("====================\n");
foreach my $state (keys(%jobstates))
{
    my $estate = $state;
    $estate = 'r (running)' if($estate eq 'r');
    $estate = 'qw (waiting for machine)' if($estate eq 'qw');
    $estate = 'Eqw (failed to start)' if($estate eq 'Eqw');
    print("Number of jobs in state $estate = $jobstates{$state}\n");
}
print("====================\n");
foreach my $mt (sort(keys(%m_total)))
{
    printf("%20s: expected %3d times, found %3d times, nojob %3d times, running %3d times, lost %3d times: lowmem %3d, io %3d, null %3d, svm %3d, suddendeath %3d\n", $mt,
        $m_total{$mt}, $m_found{$mt}, $m_nojob{$mt}, $m_running{$mt}, $m_lost{$mt},
        $m_lowmem{$mt}, $m_io{$mt}, $m_nullpointer{$mt}, $m_libsvm{$mt}, $m_sudden{$mt});
}



###############################################################################
# SUBROUTINES
###############################################################################



#------------------------------------------------------------------------------
# Resubmits a job that previously failed.
#------------------------------------------------------------------------------
sub resubmit
{
    my $job = shift; # ref to hash
    if(-f $job->{spath})
    {
        print("$job->{spath} will be resubmitted.\n");
        update_script($job->{spath});
        # Go to the folder of the script so that the logs are written there again.
        print("Going back to $job->{path}.\n");
        chdir($job->{path}) or die("Cannot change to $job->{path}: $!\n");
        # We do not know the original memory requirements for the job.
        # Let's reserve a whole 32GB machine for it.
        $job->{new_jobid} = cluster::qsub('script' => $job->{script}, 'memory' => '31g');
        print("New job id = $job->{new_jobid}\n");
        if($job->{waiting})
        {
            dzsys::saferun("qdel $job->{id}") or die;
        }
    }
    else
    {
        die("Cannot resubmit job $job->{id} because $job->{spath} does not exist.\n");
    }
}



#------------------------------------------------------------------------------
# Modifies a shell script to be submitted as a cluster job.
#------------------------------------------------------------------------------
sub update_script
{
    my $spath = shift;
    # Read and modify script.
    open(SCRIPT, $spath) or die("Cannot read script $spath: $!\n");
    my ($mem_free, $act_mem_free);
    my $script = '';
    while(<SCRIPT>)
    {
        ###!!! The operation here must be manually adjusted every time to the current needs!
        # Current operation: Every script that calls java should report the current cluster sensors for memory so that we can confirm whether our request has been met.
        $mem_free = 1 if(m-/mem_free\.sh-);
        $act_mem_free = 1 if(m-/act_mem_free\.sh-);
        if(m/java/)
        {
            if(!$mem_free)
            {
                $script .= "echo jednou | /net/projects/SGE/sensors/mem_free.sh\n";
                $mem_free = 1;
            }
            if(!$act_mem_free)
            {
                $script .= "echo jednou | /net/projects/SGE/sensors/act_mem_free.sh\n";
                $act_mem_free = 1;
            }
        }
        $script .= $_;
    }
    close(SCRIPT);
    # Write modified script.
    open(SCRIPT, ">$spath") or die("Cannot write script $spath: $!\n");
    print SCRIPT ($script);
    close(SCRIPT);
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
