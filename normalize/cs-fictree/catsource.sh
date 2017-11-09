#!/bin/bash

rm -f data/source/train.conll
for i in Fictree-shuffled/train-*.conll ; do
  bn=`basename $i .conll`
  cat $i | perl -CDS -e \
    '$n = 1; while(<>) { if(m/^\s*$/) { $n++ } else { s/^(.*?\t.*?\t.*?\t.*?\t.*?\t)_/$1sid='$bn'-s$n/ } print }' \
    >> data/source/train.conll
done

rm -f data/source/dev.conll
for i in Fictree-shuffled/dev-*.conll ; do
  bn=`basename $i .conll`
  cat $i | perl -CDS -e \
    '$n = 1; while(<>) { if(m/^\s*$/) { $n++ } else { s/^(.*?\t.*?\t.*?\t.*?\t.*?\t)_/$1sid='$bn'-s$n/ } print }' \
    >> data/source/dev.conll
done

rm -f data/source/test.conll
for i in Fictree-shuffled/test-*.conll ; do
  bn=`basename $i .conll`
  cat $i | perl -CDS -e \
    '$n = 1; while(<>) { if(m/^\s*$/) { $n++ } else { s/^(.*?\t.*?\t.*?\t.*?\t.*?\t)_/$1sid='$bn'-s$n/ } print }' \
    >> data/source/test.conll
done

