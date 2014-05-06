#!/usr/bin/env perl
# Regression testing of Treex and HamleDT, part 2.
# This script should be called after all HamleDT treebanks have been built and harmonized using the desired revision of Treex.
# The idea is that the harmonization runs in parallel on the cluster and this script waits until all treebanks are ready, then it does the rest.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
use IO::Handle; # fdopen()
use lib '/home/zeman/lib';
use dzsys;

sub usage
{
    print STDERR ("Usage: regtest2.pl working_folder\n");
}

# The only and obligatory argument of the script is the path to the working folder with TectoMT.
# The environment variables (paths to Treex revision) must be set before this script is invoked!
if(scalar(@ARGV)<1)
{
    usage();
    die("Missing argument: path to the working folder");
}
my $workdir = $ARGV[0];
# Keep the whole log in the working folder. Redirect STDOUT and STDERR there.
my $log = "$workdir/regtest.log";
open(LOG, ">>$log") or die("Cannot write to $log: $!");
# Last information printed to the original STDOUT:
print("Redirecting STDOUT and STDERR to $log...\n");
STDOUT->fdopen(\*LOG, 'w') or die $!;
STDERR->fdopen(\*LOG, 'w') or die $!;
print("--------------------------------------------------------------------------------\n");
print("Parallel processing finished for all treebanks.\n");
print("--------------------------------------------------------------------------------\n");
# Get the path to this script so we can instruct the cluster to run related scripts.
my $myscriptdir = dzsys::get_script_path();
# Get the other important paths.
my $tmtroot = $workdir.'/tectomt';
my $datapath = $tmtroot.'/share/data/resources/hamledt';
my $testingroot;
my $timestamp;
if($workdir =~ m:^(.+)/(\d+)-\d+$:)
{
    $testingroot = $1;
    $timestamp = $2;
}
else
{
    die("The name of the working folder has an unexpected form: '$workdir'");
}
# Test the newly generated treebank.
my $hatestpath = "$tmtroot/treex/devel/hamledt/tests";
print("Running HamleDT / Prague tests.\n");
dzsys::saferun("cd $hatestpath ; while ! make tests ; do echo New attempt... ; done ; make table | tee $datapath/test.txt");
# Generate name for the data snapshot that we just created.
my $treex_revision = dzsys::chompticks("cd $tmtroot ; svn info | grep -P '^Revision:'");
$treex_revision =~ s/^Revision:\s*//;
my $snapshotid = "hamledt-$timestamp-r$treex_revision";
print("HamleDT snapshot ID = $snapshotid\n");
# Archive the snapshot.
dzsys::saferun("mv $datapath $testingroot/$snapshotid");
# Compare the new snapshot with a previously archived reference snapshot.
if(-d "$testingroot/hamledt-reference")
{
    dzsys::saferun("$myscriptdir/hamledtdiff.pl $testingroot/hamledt-reference $testingroot/$snapshotid");
}
else
{
    print("Reference snapshot of HamleDT '$testingroot/hamledt-reference' not found.\n");
}
