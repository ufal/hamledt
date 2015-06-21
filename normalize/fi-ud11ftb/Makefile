LANGCODE=fi
TREEBANK=fi-ud11ftb
include ../common.mak

SOURCEDIR=/net/data/treebanks/ud-1.1/$(LANGCODE)-ftb
source:
	cp $(SOURCEDIR)/$(LANGCODE)_ftb-ud-train.conllu data/source/train.conllu
	cp $(SOURCEDIR)/$(LANGCODE)_ftb-ud-dev.conllu data/source/dev.conllu
	cp $(SOURCEDIR)/$(LANGCODE)_ftb-ud-test.conllu data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
