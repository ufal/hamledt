#!/bin/bash
# Natrénuje projektivní MST parser druhého řádu.
# Pozor! Očekává vstupní data v jiném formátu než CoNLL.
# Vůbec zatím nevím, jaké používá rysy. Ale stejně to jde měnit jen zásahem do zdrojáku.

infile    = train.mst
outfile   = mcd_proj_o2.model
sharedir  = $TMT_ROOT/share
mcddir    = $sharedir/installed_tools/parser/mst/0.4.3b
scriptdir = $TMT_ROOT/treex/devel/hamledt/parsing

# Převést trénovací data z formátu CoNLL do formátu vyžadovaného parserem MST.
$scriptdir/conll2mst.pl < $infile > train.mst
java -cp $mcddir/mstparser.jar:$mcddir/lib/trove.jar -Xmx9g mstparser.DependencyParser train order:2 format:MST decode-type:proj train-file:train.mst model-name:$outfile

# qsub -hard -l mf=10g -l act_mem_free=10g -cwd -j yes $tento_skript

