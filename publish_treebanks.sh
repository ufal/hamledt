#! /bin/bash

# From treebanks.ods I have chosen those licences which do not match /LDC|do not distribute/
PUBLISH="ar cs da nl fi de grc la fa pt ro ru sv ta"
# el    - can we distribute it?
# et is - normalization not ready
#PREFIX=${TMT_ROOT}/share/data/archive/hamledt2011
IN=${TMT_ROOT}/share/data/resources/hamledt
OUT=${TMT_ROOT}/share/hamledt

for L in $PUBLISH; do
  mkdir -p $OUT/$L
  echo cp -r $IN/$L/treex/001_pdtstyle/{train,test} $OUT/$L
  cp -r $IN/$L/treex/001_pdtstyle/{train,test} $OUT/$L
done
