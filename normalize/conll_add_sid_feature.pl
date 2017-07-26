#!/usr/bin/env perl
# Reads CoNLL-X files from folder (argument) 1. Adds a sid (sentence id) feature
# to every node and writes the result to folder (argument) 2. The sentence id
# has the following form: fileName-s<NUMBER>, e.g. sid=laskaneX01_01-s1.
# Copyright © 2017 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

sub usage
{
    print STDERR ("Usage: conll_add_sid_feature.pl in_folder out_folder\n");
}

if(scalar(@ARGV) < 2)
{
    usage();
    die;
}
my $infolder = $ARGV[0];
my $outfolder = $ARGV[1];
opendir(DIR, $infolder) or die("Cannot read folder $infolder: $!");
my @files = readdir(DIR);
closedir(DIR);
foreach my $file (@files)
{
    if($file =~ m/\.conll$/)
    {
        my $basename = $file;
        $basename =~ s/\.conll$//;
        my $sid = 1;
        open(IFILE, "$infolder/$file") or die("Cannot read $infolder/$file: $!");
        open(OFILE, ">$outfolder/$file") or die("Cannot write $outfolder/$file: $!");
        while(<IFILE>)
        {
            my @f = split(/\t/, $_);
            # In CoNLL-X, features are column index 5.
            if(scalar(@f) >= 6)
            {
                my @feats;
                unless($f[5] eq '_')
                {
                    @feats = split(/\|/, $f[5]);
                }
                push(@feats, "sid=$basename-s$sid");
                $f[5] = join('|', @feats);
                $_ = join("\t", @f);
            }
            print OFILE;
            # Empty lines signal the end of the sentence.
            if(m/^\s*$/)
            {
                $sid++;
            }
        }
        close(IFILE);
        close(OFILE);
    }
}
