#!/bin/bash
SHARE=/net/projects/tectomt_shared
WORK=$SHARE/data/resources/hamledt
ARCH=$SHARE/data/archive/hamledt/2.0_2014-05-24_treex-r12700
DIST=$SHARE/hamledt/2.0
FREELANGS="ar cs da et fa fi grc la nl pt ro sv ta"
PATCHLANGS="bg bn ca de el en es eu hi hu it ja ru sk sl te tr"
LANGS="$FREELANGS $PATCHLANGS"
for i in $LANGS ; do
  echo $i
  mkdir -p $ARCH/$i/treex/001_pdtstyle/train
  mkdir -p $ARCH/$i/treex/001_pdtstyle/test
  mkdir -p $ARCH/$i/conll/train
  mkdir -p $ARCH/$i/conll/test
  mkdir -p $ARCH/$i/stanford/train
  mkdir -p $ARCH/$i/stanford/test
  cp $WORK/$i/treex/001_pdtstyle/train/*.treex.gz $ARCH/$i/treex/001_pdtstyle/train
  cp $WORK/$i/treex/001_pdtstyle/test/*.treex.gz $ARCH/$i/treex/001_pdtstyle/test
  cp $WORK/$i/conll/train/*.conll.gz $ARCH/$i/conll/train
  cp $WORK/$i/conll/test/*.conll.gz $ARCH/$i/conll/test
  cp $WORK/$i/stanford/train/*.treex.gz $ARCH/$i/stanford/train
  cp $WORK/$i/stanford/test/*.treex.gz $ARCH/$i/stanford/test
  cp $WORK/$i/stanford/train/*.conll $ARCH/$i/stanford/train
  cp $WORK/$i/stanford/test/*.conll $ARCH/$i/stanford/test
  cp $WORK/$i/stanford/train/*.stanford $ARCH/$i/stanford/train
  cp $WORK/$i/stanford/test/*.stanford $ARCH/$i/stanford/test
  gzip $ARCH/$i/stanford/{train,test}/*.{conll,stanford}
done
mkdir -p $DIST
for i in $FREELANGS ; do
  echo free $i
  cp -r $ARCH/$i $DIST/$i
done
for i in $PATCHLANGS ; do
  echo patch $i
  for style in conll stanford ; do
    for dataset in train test ; do
      cd $ARCH/$i/$style/$dataset
      mkdir -p $DIST/$i/$style/$dataset
      for file in *.conll.gz ; do
        gunzip -c $file | /net/work/people/zeman/tectomt/treex/devel/hamledt/create_conll_patch.pl | gzip -c > $DIST/$i/$style/$dataset/$file
      done
    done
  done
done
echo Packing $SHARE/hamledt/hamledt-2.0-free.tar
cd $DIST
cd ..
tar cf hamledt-2.0-free.tar 2.0
