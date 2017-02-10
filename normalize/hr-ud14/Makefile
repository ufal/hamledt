LANGCODE=hr
TREEBANK=hr-ud14
UDCODE=hr
UDNAME=Croatian
include ../common.mak

# New (post-1.4 but v1) data from Željko.
SOURCEDIR=/net/work/people/zeman/unidep/UD_Croatian-2017-02-09
source:
	cp $(SOURCEDIR)/$(UDCODE)-ud-train.conllu data/source/train.conllu
	cp $(SOURCEDIR)/$(UDCODE)-ud-dev.conllu data/source/dev.conllu
	cp $(SOURCEDIR)/$(UDCODE)-ud-test.conllu data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
