#!/bin/bash
# Takes data/conllu, creates large ungzipped files for release and copies them to the local clone of the Github repository.

# Usage:
#   cd $HAMLEDT/normalize/cs
#   ../export_ud.sh cs cs_pdt Czech-PDT
#   cd $HAMLEDT/normalize/la-it
#   ../export_ud.sh la la_ittb Latin-ITTB
#   cd $HAMLEDT/normalize/uk-ud25iu
#   UDDIR=/net/work/people/zeman/unidep/forks ../export_ud.sh uk uk_iu Ukrainian-IU

echo `date` export_ud.sh started | tee -a time.log
lcode=$1
ltcode=$2
lname=$3
if [ -z "$UDDIR" ] ; then
  UDDIR=/net/work/people/zeman/unidep
fi
UDTOOLS=$UDDIR/tools
if [ "$ltcode" == "cs_pdt" ] ; then
  echo `date` cat train-c started | tee -a time.log
  cat data/conllu/train/cmpr94*.conllu | ../conllu_docpar_from_sentid.pl > $ltcode-ud-train-c.conllu
  $UDTOOLS/fix-space-after-paragraph.pl $ltcode-ud-train-c.conllu
  echo `date` cat train-l started | tee -a time.log
  cat data/conllu/train/ln*.conllu     | ../conllu_docpar_from_sentid.pl > $ltcode-ud-train-l.conllu
  $UDTOOLS/fix-space-after-paragraph.pl $ltcode-ud-train-l.conllu
  echo `date` cat train-m started | tee -a time.log
  cat data/conllu/train/mf9*.conllu    | ../conllu_docpar_from_sentid.pl > $ltcode-ud-train-m.conllu
  $UDTOOLS/fix-space-after-paragraph.pl $ltcode-ud-train-m.conllu
  echo `date` cat train-v started | tee -a time.log
  cat data/conllu/train/vesm9*.conllu  | ../conllu_docpar_from_sentid.pl > $ltcode-ud-train-v.conllu
  $UDTOOLS/fix-space-after-paragraph.pl $ltcode-ud-train-v.conllu
  echo `date` cat dev started | tee -a time.log
  cat data/conllu/dev/*.conllu         | ../conllu_docpar_from_sentid.pl > $ltcode-ud-dev.conllu
  $UDTOOLS/fix-space-after-paragraph.pl $ltcode-ud-dev.conllu
  echo `date` cat test started | tee -a time.log
  cat data/conllu/test/*.conllu        | ../conllu_docpar_from_sentid.pl > $ltcode-ud-test.conllu
  $UDTOOLS/fix-space-after-paragraph.pl $ltcode-ud-test.conllu
elif [ "$ltcode" == "ar_padt" ] || [ "$ltcode" == "cs_cac" ] || [ "$ltcode" == "cs_fictree" ] || [ "$ltcode" == "cs_pcedt" ] || [ "$ltcode" == "en_pcedt" ] || [ "$ltcode" == "lt_alksnis" ] ; then
  echo `date` cat train started | tee -a time.log
  cat data/conllu/train/*.conllu | ../conllu_docpar_from_sentid.pl > $ltcode-ud-train.conllu
  echo `date` cat dev started | tee -a time.log
  cat data/conllu/dev/*.conllu   | ../conllu_docpar_from_sentid.pl > $ltcode-ud-dev.conllu
  echo `date` cat test started | tee -a time.log
  cat data/conllu/test/*.conllu  | ../conllu_docpar_from_sentid.pl > $ltcode-ud-test.conllu
elif [ "$ltcode" == "hr" ] || [ "$ltcode" == "el" ] ; then
  # Udapi can convert what we cannot: some of the remnant relations.
  echo `date` cat train started | tee -a time.log
  cat data/conllu/train/*.conllu | udapy -s ud.Convert1to2 | perl -pe 's/\tremnant\t/\tdep:remnant\t/' > $ltcode-ud-train.conllu
  echo `date` cat dev started | tee -a time.log
  cat data/conllu/dev/*.conllu   | udapy -s ud.Convert1to2 | perl -pe 's/\tremnant\t/\tdep:remnant\t/' > $ltcode-ud-dev.conllu
  echo `date` cat test started | tee -a time.log
  cat data/conllu/test/*.conllu  | udapy -s ud.Convert1to2 | perl -pe 's/\tremnant\t/\tdep:remnant\t/' > $ltcode-ud-test.conllu
else
  echo `date` cat train started | tee -a time.log
  cat data/conllu/train/*.conllu > $ltcode-ud-train.conllu
  echo `date` cat dev started | tee -a time.log
  cat data/conllu/dev/*.conllu > $ltcode-ud-dev.conllu
  echo `date` cat test started | tee -a time.log
  cat data/conllu/test/*.conllu > $ltcode-ud-test.conllu
fi
mkdir -p $UDDIR/UD_$lname
echo `date` check sentence ids started | tee -a time.log
cat *.conllu | $UDTOOLS/check_sentence_ids.pl
echo `date` conllu stats started | tee -a time.log
$UDTOOLS/conllu-stats.pl *.conllu > $UDDIR/UD_$lname/stats.xml
echo `date` udapy mark bugs started | tee -a time.log
cat *.conllu | udapy -HMAC ud.MarkBugs skip=no- > bugs.html
#udapy -HMAC ud.MarkBugs skip=no- < hsb-ud-test.conllu > bugs-hsb.html 2> >(tee log.txt >&2)
for i in *.conllu ; do
  # Some treebanks do not have training data. Skip CoNLL-U files that have zero size.
  if [ -s $i ] ; then
    echo `date` validate $i started | tee -a time.log
    # Language-specific Udapi block to fix case-enhanced deprels.
    if [ "$lcode" == "cs" ] ; then
      FIXEDEPRELS='ud.cs.FixEdeprels'
    elif [ "$lcode" == "sk" ] ; then
      FIXEDEPRELS='ud.sk.FixEdeprels'
    else
      FIXEDEPRELS=''
    fi
    # If the corpus contains coreference annotation, use Udapi to convert it to the new format.
    udapy -s read.OldCorefUD corefud.FixInterleaved corefud.MergeSameSpan util.Eval node='for m in node.coref_mentions: m.head = m.words[0]' corefud.MoveHead $FIXEDEPRELS < $i > fixed.conllu
    mv fixed.conllu $i
    python3 $UDTOOLS/validate.py --lang=$lcode $i
    mv $i $UDDIR/UD_$lname
  else
    rm $i
  fi
done
echo `date` export_ud.sh ended | tee -a time.log
