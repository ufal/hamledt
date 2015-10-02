#!/bin/bash
# Takes data/conllu, creates large ungzipped files for release and copies them to the local clone of the Github repository.

# Usage:
#   cd $HAMLEDT/normalize/cs
#   ../export_ud.sh cs Czech

lcode=$1
lname=$2
zcat data/conllu/dev/*.conllu.gz > $lcode-ud-dev.conllu
zcat data/conllu/test/*.conllu.gz > $lcode-ud-test.conllu
if [ "$lcode" == "cs" ] ; then
  zcat data/conllu/train/cmpr94*.conllu.gz > cs-ud-train-c.conllu
  zcat data/conllu/train/ln*.conllu.gz > cs-ud-train-l.conllu
  zcat data/conllu/train/mf9*.conllu.gz > cs-ud-train-m.conllu
  zcat data/conllu/train/vesm9*.conllu.gz > cs-ud-train-v.conllu
else
  zcat data/conllu/train/*.conllu.gz > $lcode-ud-train.conllu
fi
UDDIR=/net/work/people/zeman/unidep
UDTOOLS=$UDDIR/tools
mkdir -p $UDDIR/UD_$lname
cat *.conllu | $UDTOOLS/conllu-stats.pl > $UDDIR/UD_$lname/stats.xml
for i in *.conllu ; do
  echo $i
  python $UDTOOLS/validate.py --noecho --lang=$lcode $i
  mv $i $UDDIR/UD_$lname
done

