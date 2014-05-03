#!/usr/bin/env perl
# Regression testing of Treex and HamleDT.
# This script checks out a fresh copy of the HEAD revision of Treex and tests how processing of HamleDT data changed since the previous test run.
# The script invokes parallel processing and must be run on the head of the cluster. It is meant to be run nightly by cron.
# Note that cron should know that we want to use bash (SHELL=/bin/bash).
# Even then it will not load ~/.bash_profile automatically. We must do it to get the environment and paths right.
# Otherwise we will end up running Perl 5.10 instead of 5.12 and missing forks.pm in @INC.
# Usage: perl -I/home/zeman/lib regtest.pl |& tee regtest.log
# 0 2 * * * source ~/.bash_profile ; perl -I/home/zeman/lib /net/work/people/zeman/tectomt/treex/devel/hamledt/regtest.pl > /net/cluster/TMP/zeman/hamledt-regression-test/regtest.log 2>&1
# (Ssh to lrc1, call crontab -e and schedule the above command to be run regularly.)
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
use IO::Handle; # fdopen()
use Config;
use lib '/home/zeman/lib';
use dzsys;
use cas;
use cluster;

# Where is our test room?
# Lot of disk space is required. Several previous logs and data snapshots will be kept there.
my $testdir = '/net/cluster/TMP/zeman/hamledt-regression-test';
# Get timestamp to label the results we are going to generate.
my $timestamp = cas::ted()->{rmdhms};
my $testid = "$timestamp-$$";
my $workdir = "$testdir/$testid";
dzsys::saferun("mkdir -p $workdir");
# Keep the whole log in the working folder. Redirect STDOUT and STDERR there.
my $log = "$workdir/regtest.log";
open(LOG, ">$log") or die("Cannot write to $log: $!");
# Last information printed to the original STDOUT:
print("Redirecting STDOUT and STDERR to $log...\n");
STDOUT->fdopen(\*LOG, 'w') or die $!;
STDERR->fdopen(\*LOG, 'w') or die $!;
# For the record: what version of Perl are we using?
dzsys::saferun("perl --version | grep -i 'this is perl'");
# Get the path to this script so we can instruct the cluster to run related scripts.
my $myscriptdir = dzsys::get_script_path();
# Prepare TectoMT, including Treex and Tred.
my $tmtroot = $workdir.'/tectomt';
# Remove previous revision of TectoMT, if present.
dzsys::saferun("rm -rf $tmtroot");
# Check out fresh working copy of TectoMT.
chdir($workdir);
dzsys::saferun("svn checkout https://svn.ms.mff.cuni.cz/svn/tectomt_devel/trunk tectomt");
# Make sure that any subsequent calls to Treex and other TectoMT code will use the current version.
$ENV{TMT_ROOT} = $tmtroot;
$ENV{TMT_SHARED} = $tmtroot.'/share';
$ENV{TMT_TEMP} = $tmtroot.'/tmp';
$ENV{TRED_DIR} = $tmtroot.'/share/tred';
my $treddir = $ENV{TRED_DIR};
# Remove previous TectoMT paths, keep the rest.
my @paths = split(/:/, $ENV{PATH});
my $oldtmtroot;
my @treexpaths = grep {$_ =~ m-/treex/-} (@paths);
if(@treexpaths)
{
    $oldtmtroot = $treexpaths[0];
    $oldtmtroot =~ s-/treex/.*--;
    @paths = grep {$_ !~ m-^$oldtmtroot-} (@paths);
}
# Add new TectoMT paths.
@paths = ($tmtroot.'/treex/bin', $tmtroot.'/tools/format_validators', $tmtroot.'/tools/general', @paths);
$ENV{PATH} = join(':', @paths);
print("PATH = $ENV{PATH}\n");
# Remove previous TectoMT Perl libraries, keep the rest.
my @plibs = split(/:/, $ENV{PERL5LIB});
if(defined($oldtmtroot))
{
    @plibs = grep {$_ !~ m-^$oldtmtroot-} (@plibs);
}
# Add new TectoMT Perl libraries.
@plibs =
(
    $tmtroot.'/share/installed_libs/lib/perl5',
    $tmtroot.'/share/installed_libs/lib/perl5/'.$Config{archname},
    $tmtroot.'/libs/core',
    $tmtroot.'/libs/blocks',
    $tmtroot.'/libs/other',
    $tmtroot.'/treex/lib',
    $treddir.'/tredlib',
    $treddir.'/tredlib/libs/fslib',
    $treddir.'/tredlib/libs/pml-base',
    $treddir.'/tredlib/libs/backends',
    @plibs
);
$ENV{PERLLIB} = join(':', @plibs);
$ENV{PERL5LIB} = $ENV{PERLLIB};
print("PERL5LIB = $ENV{PERL5LIB}\n");
# Prepare the folder where HamleDT will be generated according to its Makefiles.
my $datapath = $tmtroot.'/share/data/resources/hamledt';
dzsys::saferun("mkdir -p $datapath");
# Figure out the current set of languages and treebanks in HamleDT.
my $normpath = $tmtroot.'/treex/devel/hamledt/normalize';
opendir(DIR, $normpath) or die("Cannot access $normpath: $!");
my @treebanks = sort(grep {$_ !~ m/^\./ && -d "$normpath/$_"} (readdir(DIR)));
closedir(DIR);
printf("There are %d treebanks in $normpath:\n%s\n", scalar(@treebanks), join(' ', @treebanks));
my @jobs;
foreach my $tbk (@treebanks)
{
    my $path = $normpath.'/'.$tbk;
    print("====================================================================================================\n");
    print("Entering $path...\n");
    print("====================================================================================================\n");
    chdir($path) or die("Cannot enter folder $path: $!");
    my $jobid = create_script_for_treebank($workdir, $normpath, $tbk);
    push(@jobs, $jobid);
}
create_waiting_script($workdir, $myscriptdir, @jobs);



#------------------------------------------------------------------------------
# Generate variable settings for Bash scripts that recover our environment,
# especially the paths to our revision of Treex.
#------------------------------------------------------------------------------
sub get_bash_environment
{
    my $script;
    foreach my $variable qw(PATH PERLLIB PERL5LIB TMT_ROOT TMT_SHARED TMT_TEMP TRED_DIR)
    {
        $script .= "$variable=$ENV{$variable}\n";
    }
    return $script;
}



#------------------------------------------------------------------------------
# Generate script that makes all steps for one language/treebank and that can
# be submitted to the cluster.
#------------------------------------------------------------------------------
sub get_script_for_treebank
{
    my $normpath = shift;
    my $tbk = shift;
    my $path = "$normpath/$tbk";
    my $script = "#!/bin/bash\n";
    # If we submit the script to the cluster, it will execute ~/.bash_profile
    # and thus reset the default path to Treex etc. Make sure that it uses
    # our current environment instead.
    $script .= get_bash_environment();
    $script .= "cd $path\n";
    $script .= "make dirs\n";
    $script .= "make source\n";
    $script .= "make treex\n";
    $script .= "make pdt\n";
    return $script;
}



#------------------------------------------------------------------------------
# Writes a script to the disk.
#------------------------------------------------------------------------------
sub write_script
{
    my $script = shift; # source code of the script
    my $path = shift; # where to write the script
    open(SCRIPT, ">$path") or print STDERR ("Cannot write to $path: $!");
    print SCRIPT ($script);
    close(SCRIPT);
    chmod(0755, $path);
    return $path;
}



#------------------------------------------------------------------------------
# Create script that makes all steps for one language/treebank and that can be
# submitted to the cluster.
#------------------------------------------------------------------------------
sub create_script_for_treebank
{
    my $workdir = shift;
    my $normpath = shift;
    my $tbk = shift;
    my $script = get_script_for_treebank($normpath, $tbk);
    my $scriptname = "ham$tbk.sh";
    my $scriptpath = "$workdir/$scriptname";
    write_script($script, $scriptpath);
    # Go to the working folder to make sure that output of the cluster jobs will be saved there.
    chdir($workdir) or die("Cannot enter $workdir: $!");
    my $jobid = cluster::qsub('script' => $scriptpath);
    return $jobid;
}



#------------------------------------------------------------------------------
# Create script that will wait for the cluster jobs of all treebanks and when
# they are done it will do the rest of the work.
#------------------------------------------------------------------------------
sub create_waiting_script
{
    my $workdir = shift;
    my $myscriptdir = shift;
    my @jobs = @_;
    my $script = "#!/bin/bash\n";
    $script .= "# Submit this script to cluster, waiting on jobs ".join(' ', @jobs)."\n";
    # If we submit the script to the cluster, it will execute ~/.bash_profile
    # and thus reset the default path to Treex etc. Make sure that it uses
    # our current environment instead.
    $script .= get_bash_environment();
    $script .= "cd $workdir\n";
    $script .= "perl -I/home/zeman/lib $myscriptdir/regtest2.pl $workdir\n";
    my $scriptname = "hamledtest.sh";
    my $scriptpath = "$workdir/$scriptname";
    write_script($script, $scriptpath);
    # Go to the working folder to make sure that output of the cluster jobs will be saved there.
    chdir($workdir) or die("Cannot enter $workdir: $!");
    my $jobid = cluster::qsub('script' => $scriptpath, 'deps' => \@jobs);
    return $jobid;
}
