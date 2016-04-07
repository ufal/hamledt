#!/usr/bin/env perl
# Přečte soubor PML, odstraní z něj chyby, které brání načtení do Treexu, a výsledek vypíše.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use xmltree;

# Slovenský treebank obsahuje prázdné uzly (prvky <LM> s prázdným id a ordem):
#  <LM id="">
#   <ord></ord>
#  </LM>

###!!! Momentálně umíme číst pouze z pojmenovaného (a nekomprimovaného) souboru, ale ne ze standardního vstupu.
my $file = shift(@ARGV);
my $xmltree = xmltree::read($file);
# Projít všechny prvky LM. Do hloubky, mohou být vnořené.
remove_idless_lms($xmltree);
xmltree::print_xml($xmltree);



#------------------------------------------------------------------------------
# Searches the tree depth-first. If it finds a LM element without id, deletes
# it. The root element will not be checked!
#------------------------------------------------------------------------------
sub remove_idless_lms
{
    my $tree = shift;
    if(exists($tree->{children}) && scalar(@{$tree->{children}}))
    {
        for(my $i = 0; $i <= $#{$tree->{children}}; $i++)
        {
            my $child = $tree->{children}[$i];
            if($child->{element} eq 'LM')
            {
                my $id = $child->{attributes}{id};
                if(!defined($id) || $id =~ m/^\s*$/)
                {
                    splice(@{$tree->{children}}, $i, 1);
                    $i--;
                }
                else
                {
                    remove_idless_lms($child);
                }
            }
            else
            {
                remove_idless_lms($child);
            }
        }
    }
}
