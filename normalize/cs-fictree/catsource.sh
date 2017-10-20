#!/bin/bash

for i in Fictree-corr/*.conll ; do
  bn=`basename $i .conll`
  cat $i | perl -CDS -e \
    '$n = 1; while(<>) { if(m/^\s*$/) { $n++ } else { s/^(.*?\t.*?\t.*?\t.*?\t.*?\t)_/$1sid='$bn'-s$n/ } print }'
done

