#!/usr/bin/env perl
# Combines a HamleDT CoNLL patch with the original treebank in the CoNLL-X format.
# Copyright © 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

# We expect two arguments in this order: 1. the original file; 2. the patch file.
sub usage
{
    print STDERR ("Usage: perl apply_conll_patch.pl original.conll patch\n");
    print STDERR ("       original.conll ... the original treebank (only one file)\n");
    print STDERR ("       patch ... path to the folder with patch files\n");
    print STDERR ("                 all *.conll.gz files in that folder will be used, in alphabetical order\n");
}
my $nargs = scalar(@ARGV);
unless($nargs==2)
{
    usage();
    die("Expected 2 arguments, got $nargs");
}
my $orig = $ARGV[0];
my $patch = $ARGV[1];
open(ORIG, $orig) or die("Cannot read original treebank $orig: $!");
opendir(PATCH, $patch) or die("Cannot scan patch folder $patch: $!");
my @pfiles = sort(grep {m/\.conll\.gz$/} (readdir(PATCH)));
closedir(PATCH);
my $ipfile = -1; # the index of the current pfile; to be manipulated by next_pline()
# Index of the current line for debugging indices, starting at 1.
my $ioline = 0;
my $ipline = 0;
while(my $oline = <ORIG>)
{
    $ioline++;
    my $pline = next_pline();
    chomp($oline);
    chomp($pline);
    my $oempty = $oline =~ m/^\s*$/;
    my $pempty = $pline =~ m/^\s*$/;
    if($oempty && !$pempty)
    {
        print STDERR ("orig line $ioline, patch file $pfiles[$ipfile], patch line $ipline\n");
        die("Synchronization error: original line empty, patch line not empty");
    }
    elsif($pempty && !$oempty)
    {
        print STDERR ("orig line $ioline, patch file $pfiles[$ipfile], patch line $ipline\n");
        die("Synchronization error: original line not empty, patch line empty");
    }
    if($oempty)
    {
        print("\n");
    }
    else # a node has been read
    {
        my @of = split(/\t/, $oline);
        my @pf = split(/\t/, $pline);
        # Check synchronization.
        if($of[0] != $pf[0])
        {
            print STDERR ("orig line $ioline, patch file $pfiles[$ipfile], patch line $ipline\n");
            die("Synchronization error: original word index $of[0] and patch word index $pf[0] do not match");
        }
        # From time to time the patch contains word forms, too. Then we can check synchro also on the word forms.
        if($pf[1] ne '' && $pf[1] ne $of[1])
        {
            print STDERR ("orig line $ioline, patch file $pfiles[$ipfile], patch line $ipline\n");
            die("Synchronization error: original word '$of[1]' and patch word '$pf[1]' do not match");
        }
        # Synchronization is OK. Combine the sources and print the result.
        ###!!! Problem! We removed fields 1 through 4 when creating the patch (word form, lemma, cpos and pos).
        ###!!! But the HamleDT files (from which the patch was created) actually contained CPOS and POS different from the original treebank!
        ###!!! This is confusing because users think they should check these fields at synchronization points as well.
        ###!!! Moreover, we do not get the HamleDT values of these fields during synchronization.
        my @rf = @pf;
        $rf[1] = $of[1]; # word form
        $rf[2] = $of[2]; # lemma
        $rf[3] = $of[3]; # original cpos (in HamleDT 2.0, there would be the first letter of the PDT tag instead)
        $rf[4] = $of[4]; # original pos (in HamleDT 2.0, there would be the PDT tag instead)
        my $rline = join("\t", @rf);
        print("$rline\n");
    }
}
close(ORIG);
close(PATCH);



#------------------------------------------------------------------------------
# Returns the next patch line. If EOF is detected and there is another patch
# file, closes the current file, opens the next file and returns its first
# line.
#------------------------------------------------------------------------------
sub next_pline
{
    my $pline = <PATCH>;
    $ipline++;
    if(!defined($pline))
    {
        # Go to the next $pfile, if any.
        $ipfile++;
        if($ipfile <= $#pfiles)
        {
            my $pfile = "$patch/$pfiles[$ipfile]";
            close(PATCH);
            open(PATCH, "gunzip -c $pfile |") or die("Cannot read patch file $pfile: $!");
            $pline = <PATCH>;
            $ipline = 1;
            if(!defined($pline))
            {
                die("The patch file $pfile is empty");
            }
        }
        else
        {
            die("The patch files ended prematurely. The file number $ipfile ($pfiles[$ipfile]) has ended and it is the last file in $patch");
        }
    }
    return $pline;
}
