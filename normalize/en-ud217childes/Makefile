LANGCODE=en
TREEBANK=en-ud217childes
UDCODE=en_childes
UDNAME=English-CHILDES
include ../common.mak

ALTSRCDIR1=/net/data/universal-dependencies-2.17/UD_$(UDNAME)
ALTSRCDIR2=/net/work/people/zeman/unidep/UD_$(UDNAME)
SOURCEDIR=$(ALTSRCDIR1)

source:
	cp $(SOURCEDIR)/$(UDCODE)-ud-train.conllu data/source/train.conllu
	cp $(SOURCEDIR)/$(UDCODE)-ud-dev.conllu data/source/dev.conllu
	cp $(SOURCEDIR)/$(UDCODE)-ud-test.conllu data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
