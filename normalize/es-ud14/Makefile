LANGCODE=es
TREEBANK=es-ud14
UDCODE=es
UDNAME=Spanish
include ../common.mak

SOURCEDIR=/net/work/people/zeman/unidep/UD_$(UDNAME)
# We have to change the data split between 1.4 and 2.0 by moving 152 sentences from dev to test.
source:
	cp $(SOURCEDIR)/$(UDCODE)-ud-train.conllu data/source/train.conllu
	split_conll.pl < $(SOURCEDIR)/$(UDCODE)-ud-dev.conllu -head 1500 data/source/dev.conllu data/source/devtotest.conllu
	cat data/source/devtotest.conllu $(SOURCEDIR)/$(UDCODE)-ud-test.conllu > data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
