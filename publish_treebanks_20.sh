#! /bin/bash

# From treebanks.ods I have chosen those licences which do not match /LDC|do not distribute/
PUBLISH="ar cs da nl fi grc la fa pt ro sv ta"
# de el ru - can we distribute it?
# et is    - normalization not ready
#PREFIX=${TMT_ROOT}/share/data/archive/hamledt2011
IN=${TMT_ROOT}/share/data/resources/hamledt
OUT=${TMT_ROOT}/share/hamledt/2.0/

for L in $PUBLISH; do
  echo $OUT/$L
  #mkdir -p $OUT/$L/source
  
  mkdir -p $OUT/$L/prague/treex/train
  mkdir -p $OUT/$L/prague/treex/test
  cp -r $IN/$L/treex/001_pdtstyle/train/*treex* $OUT/$L/prague/treex/train/
  cp -r $IN/$L/treex/001_pdtstyle/test/*treex*  $OUT/$L/prague/treex/test/
  
  mkdir -p $OUT/$L/prague/conll/train
  mkdir -p $OUT/$L/prague/conll/test
  cp -r $IN/$L/conll/train/*conll* $OUT/$L/prague/conll/train/
  cp -r $IN/$L/conll/test/*conll* $OUT/$L/prague/conll/test/
  
  mkdir -p $OUT/$L/stanford/treex/train
  mkdir -p $OUT/$L/stanford/treex/test
  cp -r $IN/$L/stanford/train/*treex* $OUT/$L/stanford/treex/train/
  cp -r $IN/$L/stanford/test/*treex*  $OUT/$L/stanford/treex/test/
  
  mkdir -p $OUT/$L/stanford/basic/train
  mkdir -p $OUT/$L/stanford/basic/test
  cp -r $IN/$L/stanford/train/*stanford* $OUT/$L/stanford/basic/train/
  cp -r $IN/$L/stanford/test/*stanford*  $OUT/$L/stanford/basic/test/
  
  mkdir -p $OUT/$L/stanford/conll/train
  mkdir -p $OUT/$L/stanford/conll/test
  cp -r $IN/$L/stanford/train/*conll* $OUT/$L/stanford/conll/train/
  cp -r $IN/$L/stanford/test/*conll*  $OUT/$L/stanford/conll/test/

done

chmod -R g+w $OUT

