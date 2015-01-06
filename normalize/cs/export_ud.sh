#!/bin/bash
# Takes data/conll-u, creates large ungzipped files for release and copies them to the local clone of the Github repository.
zcat data/conll-u/dev/*.conllu.gz > cs-ud-dev.conllu
zcat data/conll-u/test/*.conllu.gz > cs-ud-test.conllu
zcat data/conll-u/train/cmpr94* > cs-ud-train-c.conllu
zcat data/conll-u/train/ln* > cs-ud-train-l.conllu
zcat data/conll-u/train/mf9* > cs-ud-train-m.conllu
zcat data/conll-u/train/vesm9* > cs-ud-train-v.conllu
cp *.conllu /ha/home/zeman/network/unidep/Czech

