LANGCODE=fa
TREEBANK=fa-ud11
include ../common.mak

SOURCEDIR=/net/data/treebanks/ud-1.1/$(LANGCODE)
source:
	cp $(SOURCEDIR)/$(LANGCODE)-ud-train.conllu data/source/train.conllu
	cp $(SOURCEDIR)/$(LANGCODE)-ud-dev.conllu data/source/dev.conllu
	cp $(SOURCEDIR)/$(LANGCODE)-ud-test.conllu data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
