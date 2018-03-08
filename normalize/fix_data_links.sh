#!/bin/bash

cd /net/work/people/zeman/hamledt/normalize
for i in * ; do
  # Old links: data -> /a/LRC_TMP/zeman/hamledt/$i
  # New links: data -> /net/work/people/zeman/hamledt-data/$i
  if [ -d $i ] ; then
    echo $i
    cd $i
    if [ -L data ] ; then rm data ; fi
    ln -s /net/work/people/zeman/hamledt-data/$i ./data
    cd ..
  fi
done

