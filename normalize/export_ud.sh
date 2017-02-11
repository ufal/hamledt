#!/bin/bash
# Takes data/conllu, creates large ungzipped files for release and copies them to the local clone of the Github repository.

# Usage:
#   cd $HAMLEDT/normalize/cs
#   ../export_ud.sh cs Czech
# If this is not the default treebank for the language:
#   cd $HAMLEDT/normalize/la-it
#   ../export_ud.sh la_itt Latin-ITT

lcode=$1
lname=$2
if [ "$lcode" == "cs" ] ; then
  zcat data/conllu/train/cmpr94*.conllu.gz | ../conllu_docpar_from_sentid.pl > cs-ud-train-c.conllu
  zcat data/conllu/train/ln*.conllu.gz     | ../conllu_docpar_from_sentid.pl > cs-ud-train-l.conllu
  zcat data/conllu/train/mf9*.conllu.gz    | ../conllu_docpar_from_sentid.pl > cs-ud-train-m.conllu
  zcat data/conllu/train/vesm9*.conllu.gz  | ../conllu_docpar_from_sentid.pl > cs-ud-train-v.conllu
  zcat data/conllu/dev/*.conllu.gz         | ../conllu_docpar_from_sentid.pl > cs-ud-dev.conllu
  zcat data/conllu/test/*.conllu.gz        | ../conllu_docpar_from_sentid.pl > cs-ud-test.conllu
elif [ "$lcode" == "ar" ] || [ "$lcode" == "cs_cac" ] ; then
  zcat data/conllu/train/*.conllu.gz | ../conllu_docpar_from_sentid.pl > $lcode-ud-train.conllu
  zcat data/conllu/dev/*.conllu.gz   | ../conllu_docpar_from_sentid.pl > $lcode-ud-dev.conllu
  zcat data/conllu/test/*.conllu.gz  | ../conllu_docpar_from_sentid.pl > $lcode-ud-test.conllu
elif [ "$lcode" == "hr" ] ; then
  # Udapi can convert what we cannot: some of the remnant relations.
  zcat data/conllu/train/*.conllu.gz | udapy -s ud.Convert1to2 > $lcode-ud-train.conllu
  zcat data/conllu/dev/*.conllu.gz   | udapy -s ud.Convert1to2 > $lcode-ud-dev.conllu
  zcat data/conllu/test/*.conllu.gz  | udapy -s ud.Convert1to2 > $lcode-ud-test.conllu
else
  zcat data/conllu/train/*.conllu.gz > $lcode-ud-train.conllu
  zcat data/conllu/dev/*.conllu.gz > $lcode-ud-dev.conllu
  zcat data/conllu/test/*.conllu.gz > $lcode-ud-test.conllu
fi
UDDIR=/net/work/people/zeman/unidep
UDTOOLS=$UDDIR/tools
mkdir -p $UDDIR/UD_$lname
cat *.conllu | $UDTOOLS/check_sentence_ids.pl
cat *.conllu | $UDTOOLS/conllu-stats.pl > $UDDIR/UD_$lname/stats.xml
for i in *.conllu ; do
  echo $i
  python $UDTOOLS/validate.py --noecho --lang=$lcode $i
  mv $i $UDDIR/UD_$lname
done
