LANGCODE=cs
TREEBANK=cs-ud12
UDCODE=cs
UDNAME=Czech
include ../common.mak

SOURCEDIR=/net/data/universal-dependencies-1.2/UD_$(UDNAME)
source:
	cat $(SOURCEDIR)/$(UDCODE)-ud-train-[clmv].conllu > data/source/train.conllu
	cp $(SOURCEDIR)/$(UDCODE)-ud-dev.conllu data/source/dev.conllu
	cp $(SOURCEDIR)/$(UDCODE)-ud-test.conllu data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
