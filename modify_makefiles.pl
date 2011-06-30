#!/usr/bin/perl
# Batch modification of the makefiles for all languages.
# Copyright © 2011 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use lib '/home/zeman/lib';
use find;

find::go('.', \&process_object);



#------------------------------------------------------------------------------
# Callback function from find::go() is called for every folder and file.
#------------------------------------------------------------------------------
sub process_object
{
    my $path = shift;
    my $object = shift;
    my $type = shift;
    # If this is a Makefile in a subfolder of the root folder, process it.
    if($path =~ m-^\./\w+$- && $object eq 'Makefile')
    {
        process_makefile("$path/Makefile");
    }
    # If this is a subfolder of the root folder, proceed one level down.
    return $path eq '.' && $type eq 'drx';
}



#------------------------------------------------------------------------------
# Modify the Makefile (changes hardwired here). First save as Makefile1, then
# move to the original name.
#------------------------------------------------------------------------------
sub process_makefile
{
    my $path = shift;
    my $path1 = $path.'1';
    print STDERR ("$path => $path1\n");
    my $lang;
    if($path =~ m-^\./(\w+)/Makefile$-)
    {
        $lang = uc($1);
    }
    else
    {
        die("Cannot identify language in path $path");
    }
    open(MAKEFILE, $path) or die("Cannot read $path: $!\n");
    open(MF1, ">$path1") or die("Cannot write $path1: $!\n");
    my $i_line = 0;
    while(<MAKEFILE>)
    {
        $i_line++;
        # Apply new shortcuts.
        s-\$\(DATADIR\)/source-\$(IN)-g;
        s-\$\(DATADIR\)/treex/000_orig-\$(DIR0)-g;
        s-\$\(DATADIR\)/treex/001_pdtstyle-\$(DIR1)-g;
        print MF1;
        # Insert new variable definitions after line 2.
        if($i_line==2)
        {
            print MF1 <<EOF
IN       = \$(DATADIR)/source
DIR0     = \$(DATADIR)/treex/000_orig
DIR1     = \$(DATADIR)/treex/001_pdtstyle
TREEX    = treex -L\$(LANGCODE)
IMPORT   = Read::CoNLLX lines_per_doc=500
WRITE    = Write::Treex
EOF
            ;
            $i_line += 6;
        }
        # Insert commands for goal to_treex.
        if(m/^to_treex:$/)
        {
            print MF1 ("\t", '$(TREEX) $(IMPORT) from=$(IN)/train.conll $(WRITE) path=$(DIR0)/train/', "\n");
            print MF1 ("\t", '$(TREEX) $(IMPORT) from=$(IN)/test.conll  $(WRITE) path=$(DIR0)/test/', "\n");
            $i_line += 2;
        }
        # Define the to_pdt scenario.
        if(m/and store the result in 001_pdtstyle/)
        {
            print MF1 ("SCEN1 = A2A::", $lang, "::CoNLL2PDTStyle\n");
            $i_line++;
        }
        # Insert commands for goal to_pdt.
        if(m/^to_pdt:$/)
        {
            print MF1 ("\t", '$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/train/ -- $(DIR0)/train/*.treex', "\n");
            print MF1 ("\t", '$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/  -- $(DIR0)/test/*.treex', "\n");
            $i_line += 2;
        }
    }
    close(MAKEFILE);
    close(MF1);
    # Replace the original Makefile with the modified one.
    mv($path1, $path);
}



#------------------------------------------------------------------------------
# Move file 1 to file 2.
#------------------------------------------------------------------------------
sub mv
{
    my $file1 = shift;
    my $file2 = shift;
    open(F1, $file1) or die("Cannot read $file1: $!\n");
    open(F2, ">$file2") or die("Cannot write $file2: $!\n");
    while(<F1>)
    {
        print F2;
    }
    close(F1);
    close(F2);
    unlink($file1) or die("Cannot unlink $file1: $1\n");
}
