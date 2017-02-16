LANGCODE=vi
TREEBANK=vi-ud14
UDCODE=vi
UDNAME=Vietnamese
include ../common.mak

SOURCEDIR=/net/work/people/zeman/unidep/UD_$(UDNAME)
# We have to re-split the data in order to achieve 10K dev and 10K test.
source:
	split_conll.pl < $(SOURCEDIR)/$(UDCODE)-ud-train.conllu -head 1400 data/source/train.conllu data/source/dev.conllu
	cat $(SOURCEDIR)/$(UDCODE)-ud-dev.conllu $(SOURCEDIR)/$(UDCODE)-ud-test.conllu > data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
