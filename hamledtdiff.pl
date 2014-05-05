#!/usr/bin/env perl
# Compares two versions of HamleDT. This script is used in regular regression testing.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use lib '/home/zeman/lib';
use dzsys;

sub usage
{
    print STDERR ("Usage: hamledtdiff.pl path1 path2\n");
}

my $n_differences = 0;
if(scalar(@ARGV) != 2)
{
    my $n = scalar(@ARGV);
    usage();
    die("Expecting exactly 2 arguments, found $n");
}
my $path0 = $ARGV[0];
my $path1 = $ARGV[1];
my @tbks0 = sort(dzsys::get_subfolders($path0));
my @tbks1 = sort(dzsys::get_subfolders($path1));
my $tbks0 = join(' ', @tbks0);
my $tbks1 = join(' ', @tbks1);
my @intersection;
if($tbks0 eq $tbks1)
{
    my $ntbks = scalar(@tbks0);
    print("Both versions contain the following $ntbks treebanks:\n");
    print("$tbks0\n");
    @intersection = @tbks0;
}
else
{
    my $ntbks0 = scalar(@tbks0);
    print("The sets of treebanks in the two versions differ.\n");
    print("Version 0 contains the following $ntbks0 treebanks:\n");
    print("$tbks0\n");
    my @additional = grep {my $x = $_; !grep {$_ eq $x} (@tbks0)} (@tbks1);
    my @missing = grep {my $x = $_; !grep {$_ eq $x} (@tbks1)} (@tbks0);
    printf("%d treebanks added in version 1: %s\n", scalar(@additional), join(' ', @additional)) if(@additional);
    printf("%d treebanks missing in version 1: %s\n", scalar(@missing), join(' ', @missing)) if(@missing);
    @intersection = grep {my $x = $_; grep {$_ eq $x} (@tbks1)} (@tbks0);
    $n_differences += scalar(@additional) + scalar(@missing);
}
foreach my $tbk (@intersection)
{
    my $tpath0 = "$path0/$tbk/treex/001_pdtstyle";
    my $tpath1 = "$path1/$tbk/treex/001_pdtstyle";
    my @desc0 = sort(dzsys::get_descendants($tpath0));
    my @desc1 = sort(dzsys::get_descendants($tpath1));
    my $desc0 = join(' ', @desc0);
    my $desc1 = join(' ', @desc1);
    if($desc0 ne $desc1)
    {
        print("----------------------------------------------\n");
        print("The list of files and folders in $tbk differs.\n");
        my %map;
        my %map0; map {$map0{$_}++; $map{$_}++} @desc0;
        my %map1; map {$map1{$_}++; $map{$_}++} @desc1;
        my $nadd = 0;
        my $ndel = 0;
        my $nsize = 0;
        foreach my $object (sort(keys(%map)))
        {
            if(!$map0{$object})
            {
                print("ADD $object\n");
                $nadd++;
                $n_differences++;
            }
            if(!$map1{$object})
            {
                print("DEL $object\n");
                $ndel++;
                $n_differences++;
            }
            if($map0{$object} && $map1{$object})
            {
                my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size0, $atime, $mtime, $ctime, $blksize, $blocks) = stat("$tpath0/$object");
                my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size1, $atime, $mtime, $ctime, $blksize, $blocks) = stat("$tpath1/$object");
                if($size0 != $size1)
                {
                    print("SIZE $object $size0 != $size1\n");
                    $nsize++;
                    $n_differences++;
                }
            }
        }
        printf("Total of $nadd objects added, $ndel objects deleted and $nsize objects differ in size.\n");
    }
}
if($n_differences)
{
    print("THERE ARE $n_differences DIFFERENCES.\n");
}
else
{
    print("THERE ARE NO DIFFERENCES.\n");
}
