#!/usr/bin/env perl
# A simple test of a HamleDT release. For each language, it compares the lists of files in individual formats.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use lib '/home/zeman/lib';
use dzsys;

my $full_release = '/net/projects/tectomt_shared/data/archive/hamledt/2.0_2014-05-24_treex-r12700';
my $free_release = '/net/projects/tectomt_shared/hamledt/2.0';
my $release = $ARGV[0] eq 'full' ? $full_release : $free_release;
print("Testing release $release\n");
my @treebanks = sort(dzsys::get_subfolders($release));
foreach my $treebank (@treebanks)
{
    print("Now testing $treebank...\n");
    my %traintestrows;
    foreach my $subfolder ('treex/001_pdtstyle', 'conll', 'stanford')
    {
        foreach my $dataset ('train', 'test')
        {
            my $path = "$release/$treebank/$subfolder/$dataset";
            next if(! -d $path);
            my @files = dzsys::get_files($path);
            if($subfolder eq 'treex/001_pdtstyle')
            {
                $map{$treebank}{ptreex}{$dataset} = scalar(grep {m/\.treex\.gz$/} (@files));
                push(@{$traintestrows{$dataset}}, $map{$treebank}{ptreex}{$dataset});
            }
            elsif($subfolder eq 'conll')
            {
                $map{$treebank}{pconll}{$dataset} = scalar(grep {m/\.conll\.gz$/} (@files));
                push(@{$traintestrows{$dataset}}, $map{$treebank}{pconll}{$dataset});
            }
            elsif($subfolder eq 'stanford')
            {
                $map{$treebank}{streex}{$dataset} = scalar(grep {m/\.treex\.gz$/} (@files));
                push(@{$traintestrows{$dataset}}, $map{$treebank}{streex}{$dataset});
                $map{$treebank}{sconll}{$dataset} = scalar(grep {m/\.conll\.gz$/} (@files));
                push(@{$traintestrows{$dataset}}, $map{$treebank}{sconll}{$dataset});
                $map{$treebank}{stanford}{$dataset} = scalar(grep {m/\.stanford\.gz$/} (@files));
                push(@{$traintestrows{$dataset}}, $map{$treebank}{stanford}{$dataset});
            }
        }
    }
    foreach my $dataset ('train', 'test')
    {
        print($dataset, ":\t", join(' ', @{$traintestrows{$dataset}}), "\n");
    }
}
