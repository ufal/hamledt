#!/bin/bash
# Takes data/conllu, creates large ungzipped files for release and copies them to the local clone of the Github repository.
zcat data/conllu/dev/*.conllu.gz > cs-ud-dev.conllu
zcat data/conllu/test/*.conllu.gz > cs-ud-test.conllu
zcat data/conllu/train/cmpr94* > cs-ud-train-c.conllu
zcat data/conllu/train/ln* > cs-ud-train-l.conllu
zcat data/conllu/train/mf9* > cs-ud-train-m.conllu
zcat data/conllu/train/vesm9* > cs-ud-train-v.conllu
for i in *.conllu ; do
  echo $i
  /net/work/people/zeman/unidep/release1/universal-dependencies-1.0-tools/validate.py $i --no-lists --noecho
  cp $i /ha/home/zeman/network/unidep/UD_Czech
done

