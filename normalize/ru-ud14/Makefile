LANGCODE=ru
TREEBANK=ru-ud14
UDCODE=ru
UDNAME=Russian
include ../common.mak

SOURCEDIR=/net/work/people/zeman/unidep/UD_$(UDNAME)
source:
	cat $(SOURCEDIR)/oldtraina.conllu                                     | perl -pe 's/Variant=Brev/Variant=Short/' > data/source/train.conllu
	cat $(SOURCEDIR)/oldtrainb.conllu $(SOURCEDIR)/olddeva.conllu         | perl -pe 's/Variant=Brev/Variant=Short/' > data/source/dev.conllu
	cat $(SOURCEDIR)/olddevb.conllu $(SOURCEDIR)/$(UDCODE)-ud-test.conllu | perl -pe 's/Variant=Brev/Variant=Short/' > data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
