#!/bin/bash
# Regression testing of Prague-style data harmonized without and with the phrase model in Treex.
mkdir regression
cd regression
cp -r ../data/treex/01/* .
gunzip */*.treex.gz
git init .
git add *
git commit -m 'Initial commit.'
# Now checkout the Treex branch to be tested (cd $TREEX ; git checkout phrase),
# go back to the normalization folder and re-run normalization (make prague),
# then compare the two versions:
cd regression
cp -r ../data/treex/01/* .
gunzip -f */*.treex.gz
git diff
# This second part can be repeated as long as the tested code is debugged.
