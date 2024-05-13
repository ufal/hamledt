#!/usr/bin/perl
# This script copies HamleDT and Universal Dependencies treebanks in the Treex format to the PML-TQ import folder.
# Copyright © 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL
# Usage: $0 [--release 213 --only cs-cac] # limiting it to one treebank, identified by its target name

use strict;
use warnings;

# Default values
my $udrel = "214";
my $only;
my $pmltqdir = "/net/work/projects/pmltq/data";
my $uddir = "/net/work/people/zeman/hamledt-data";
my $resourcedir = "/net/work/people/zeman/treex/lib/Treex/Core/share/tred_extension/treex/resources";

# Parse command line arguments
while (my $key = shift @ARGV)
{
    if ($key eq "--only" or $key eq "-o")
    {
        $only = shift @ARGV;
    }
    elsif ($key eq "--release" or $key eq "-r")
    {
        $udrel = shift @ARGV;
    }
    else
    {
        print STDERR ("Unknown argument '$key'.\n");
    }
}

my $forpmltqdir = "$pmltqdir/ud$udrel/treex";
print "$forpmltqdir\n";

if (!$only)
{
    system("rm -rf $forpmltqdir");
}
else
{
    system("rm -rf $forpmltqdir/$only");
}

system("mkdir -p $forpmltqdir");

# Excluding specific treebanks because they do not include the underlying word
# forms (license issues).
# Check the text-less treebanks like this (do not forget to update the release number):
#   grep -i -P '^Includes text: *no' /net/data/universal-dependencies-2.13/UD_*/README*
# However, we should be able to directly query the README files from here.
my @excluded_treebanks = qw(ar-nyuad en-esl en-gumreddit fr-ftb gun-dooley qhe-hiencs ja-bccwj ja-bccwjluw ja-ktc);

for my $tbkpath (glob("$uddir/*-ud$udrel*"))
{
    my $src = (split("/", $tbkpath))[-1];
    my $tgt = $src;
    $tgt =~ s/-ud$udrel/-/;
    $tgt =~ s/-$//;
    if (!$only || $tgt eq $only)
    {
        if (!grep { $_ eq $tgt } @excluded_treebanks)
        {
            print "Universal Dependencies $udrel $src --> $tgt\n";
            system("mkdir -p $forpmltqdir/$tgt");
            system("cp $tbkpath/pmltq/*.treex.gz $forpmltqdir/$tgt");
            system("gunzip $forpmltqdir/$tgt/*.treex.gz");
            system("gzip $forpmltqdir/$tgt/*.treex");
        }
    }
}

# Link the Treex schema to the working folder
chdir("$forpmltqdir/..");
if (!-e "resources")
{
    system("ln -s $resourcedir");
}
