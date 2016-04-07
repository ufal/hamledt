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
my $lmsubtree = xmltree::find_element('LM', $xmltree);
my $id = $lmsubtree->{attributes}{id};
if(defined($id) && $id !~ m/^\s*$/)
{
    print("element LM id $id\n");
}
else
{
    die("Undefined attribute id of element LM");
}
