#!/bin/bash
# This script copies HamleDT and Universal Dependencies treebanks in the Treex format to the PML-TQ import folder.
# 2015, 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>

pmltqdir="/net/work/projects/pmltq/data"
tmtsharedir="/net/projects/tectomt_shared/data"
hamledt2dir="$tmtsharedir/archive/hamledt/2.0_2014-05-24_treex-r12700"
hamledt3dir="$tmtsharedir/resources/hamledt"
uddir="$tmtsharedir/resources/hamledt"

forpmltqdir="$pmltqdir/ud13/treex"
echo $forpmltqdir
rm -rf $forpmltqdir
mkdir -p $forpmltqdir

forpmltqdir="$pmltqdir/ud13/treex"
echo $forpmltqdir
rm -rf $forpmltqdir
mkdir -p $forpmltqdir
# Excluding UD_English-ESL and UD_Japanese-KTC because it does not include the underlying word forms (license issues).
for lng in ar bg ca cs cu da de el en es et eu fa fi fr ga gl got grc he hi hr hu id it kk la lv nl no pl pt ro ru sl sv ta tr zh ; do
  echo Universal Dependencies 1.3 $lng
  mkdir -p $forpmltqdir/$lng
  cp $uddir/$lng-ud13/pmltq/*.treex.gz $forpmltqdir/$lng
done
# Some languages have more than one treebank.
for tbk in cs-ud13cac cs-ud13cltt en-ud13lines es-ud13ancora fi-ud13ftb grc-ud13proiel la-ud13ittb la-ud13proiel nl-ud13lassysmall pt-ud13br ru-ud13syntagrus sl-ud13sst sv-ud13lines ; do
  withoutud=`echo -n $tbk | sed 's/-ud13/-/'`
  echo Universal Dependencies 1.3 $tbk '-->' $withoutud
  mkdir -p $forpmltqdir/$withoutud
  cp $uddir/$tbk/pmltq/*.treex.gz $forpmltqdir/$withoutud
done
