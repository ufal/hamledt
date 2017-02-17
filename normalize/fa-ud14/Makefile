LANGCODE=fa
TREEBANK=fa-ud14
UDCODE=fa
UDNAME=Persian
include ../common.mak

SOURCEDIR=/net/work/people/zeman/unidep/UD_$(UDNAME)-2016
source:
	cp $(SOURCEDIR)/training-2016.conllu data/source/train.conllu
	cp $(SOURCEDIR)/dev-2016.conllu data/source/dev.conllu
	cp $(SOURCEDIR)/test-2016.conllu data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
