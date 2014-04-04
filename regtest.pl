#!/usr/bin/env perl
# Regression testing of Treex and HamleDT.
# This script checks out a fresh copy of the HEAD revision of Treex and tests how processing of HamleDT data changed since the previous test run.
# The script invokes parallel processing and must be run on the head of the cluster. It is meant to be run nightly by cron.
# Usage: perl -I/home/zeman/lib regtest.pl |& tee regtest.log
# 0 2 * * * perl -I/home/zeman/lib /net/work/people/zeman/tectomt/treex/devel/hamledt/regtest.pl > /net/cluster/TMP/zeman/hamledt-regression-test/regtest.log 2>&1
# (Ssh to lrc1, call crontab -e and schedule the above command to be run regularly.)
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Config;
use lib '/home/zeman/lib';
use dzsys;
use cas;

# Where is our test room?
# Lot of disk space is required. Several previous logs and data snapshots will be kept there.
my $workroot = '/net/cluster/TMP/zeman/hamledt-regression-test';
dzsys::saferun("mkdir -p $workroot");
my $tmtroot = $workroot.'/tectomt';
# Remove previous revision of TectoMT, if present.
dzsys::saferun("rm -rf $tmtroot");
# Check out fresh working copy of TectoMT.
chdir($workroot);
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
foreach my $tbk (@treebanks)
{
    my $path = $normpath.'/'.$tbk;
    print("====================================================================================================\n");
    print("Entering $path...\n");
    print("====================================================================================================\n");
    chdir($path) or die("Cannot enter folder $path: $!");
    dzsys::saferun("make dirs");
    dzsys::saferun("make source");
    dzsys::saferun("make treex");
    dzsys::saferun("make pdt");
}
# Generate name for the data snapshot that we just created.
my $timestamp = cas::ted()->{rmdhms};
my $treex_revision = dzsys::chompticks("cd $tmtroot ; svn info | grep -P '^Revision:'");
$treex_revision =~ s/^Revision:\s*//;
my $snapshotid = "hamledt-$timestamp-r$treex_revision";
print("HamleDT snapshot ID = $snapshotid\n");
# Archive the snapshot.
dzsys::saferun("mv $datapath $workroot/$snapshotid");
