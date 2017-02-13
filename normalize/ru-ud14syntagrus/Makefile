LANGCODE=ru
TREEBANK=ru-ud14syntagrus
UDCODE=ru_syntagrus
UDNAME=Russian-SynTagRus
include ../common.mak

SOURCEDIR=/net/work/people/zeman/unidep/UD_$(UDNAME)
source:
	cat $(SOURCEDIR)/$(UDCODE)-ud-train.conllu | perl -pe 's/Variant=Brev/Variant=Short/' > data/source/train.conllu
	cat $(SOURCEDIR)/$(UDCODE)-ud-dev.conllu   | perl -pe 's/Variant=Brev/Variant=Short/' > data/source/dev.conllu
	cat $(SOURCEDIR)/$(UDCODE)-ud-test.conllu  | perl -pe 's/Variant=Brev/Variant=Short/' > data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
