#!/bin/bash
# This script copies HamleDT and Universal Dependencies treebanks in the Treex format to the PML-TQ import folder.
# 2015, 2016, 2017 Dan Zeman <zeman@ufal.mff.cuni.cz>

pmltqdir="/net/work/projects/pmltq/data"
tmtsharedir="/net/projects/tectomt_shared/data"
hamledt2dir="$tmtsharedir/archive/hamledt/2.0_2014-05-24_treex-r12700"
hamledt3dir="$tmtsharedir/resources/hamledt"
uddir="/net/work/people/zeman/hamledt-data"

udrel="21"
forpmltqdir="$pmltqdir/ud$udrel/treex"
echo $forpmltqdir
rm -rf $forpmltqdir
mkdir -p $forpmltqdir

# Excluding UD_Arabic-NYUAD, UD_English-ESL, UD_French-FTB and UD_Japanese-KTC because it does not include the underlying word forms (license issues).
# Pokus o automatické zjištění, jaké vlastně treebanky v novém vydání Universal Dependencies máme.
for tbkpath in $uddir/*-ud$udrel* ; do
  tbk=`basename $tbkpath`
  withoutud=`echo -n $tbk | sed s/-ud$udrel/-/ | sed 's/-$//'`
  if ["$withoutud" != "ar-nyuad"] && ["$withoutud" != "en-esl"] && ["$withoutud" != "fr-ftb"] && ["$withoutud" != "ja-ktc"] ; then
    echo Universal Dependencies $udrel $tbk '-->' $withoutud
    mkdir -p $forpmltqdir/$withoutud
    cp $tbkpath/pmltq/*.treex.gz $forpmltqdir/$withoutud
  fi
done

