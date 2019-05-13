#!/bin/bash
# This script copies HamleDT and Universal Dependencies treebanks in the Treex format to the PML-TQ import folder.
# 2015, 2016, 2017, 2018, 2019 Dan Zeman <zeman@ufal.mff.cuni.cz>

# Usage: $0 [--release 24 --only cs-cac] # limiting it to one treebank, identified by its target name
udrel="24" # default: UD 2.4
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
  -o|--only)
    ONLY="$2"
    shift # past argument
    shift # past value
  ;;
  -r|--release)
    udrel="$2"
    shift # past argument
    shift # past value
  ;;
  *) # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
  ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

pmltqdir="/net/work/projects/pmltq/data"
tmtsharedir="/net/projects/tectomt_shared/data"
hamledt2dir="$tmtsharedir/archive/hamledt/2.0_2014-05-24_treex-r12700"
hamledt3dir="$tmtsharedir/resources/hamledt"
uddir="/net/work/people/zeman/hamledt-data"
resourcedir="/net/work/people/zeman/treex/lib/Treex/Core/share/tred_extension/treex/resources"

forpmltqdir="$pmltqdir/ud$udrel/treex"
echo $forpmltqdir
if [[ -z "$ONLY" ]] ; then
  rm -rf $forpmltqdir
else
  rm -rf $forpmltqdir/$ONLY
fi
mkdir -p $forpmltqdir

# Excluding
#   UD_Arabic-NYUAD, UD_English-ESL, UD_French-FTB, UD_Hindi_English-HIENCS, UD_Japanese-BCCWJ and UD_Japanese-KTC
# because they do not include the underlying word forms (license issues).
# Pokus o automatické zjištění, jaké vlastně treebanky v novém vydání Universal Dependencies máme.
for tbkpath in $uddir/*-ud$udrel* ; do
  tbk=`basename $tbkpath`
  withoutud=`echo -n $tbk | sed s/-ud$udrel/-/ | sed 's/-$//'`
  if [[ -z "$ONLY" ]] || [[ "$withoutud" == "$ONLY" ]] ; then
    if [ "$withoutud" != "ar-nyuad" ] && [ "$withoutud" != "en-esl" ] && [ "$withoutud" != "fr-ftb" ] && [ "$withoutud" != "qhe-hiencs" ] && [ "$withoutud" != "ja-bccwj" ] && [ "$withoutud" != "ja-ktc" ] ; then
      echo Universal Dependencies $udrel $tbk '-->' $withoutud
      mkdir -p $forpmltqdir/$withoutud
      cp $tbkpath/pmltq/*.treex.gz $forpmltqdir/$withoutud
      # Trying to prevent a weird random error ("extra contents past XML doc end") in some .treex.gz files produced by parallel Treex.
      gunzip $forpmltqdir/$withoutud/*.treex.gz
      gzip $forpmltqdir/$withoutud/*.treex
    fi
  fi
done
# We will need access to the Treex schema when processing the data. Link the schema to the working folder (not to the "treex" subfolder!)
cd $forpmltqdir/..
if [[ ! -e "resources" ]] ; then
  ln -s $resourcedir
fi
