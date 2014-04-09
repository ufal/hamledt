LANGCODE=hu
TREEBANK=hu
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2007/hu/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2007/hu/test.conll $(IN)/test.conll

treex: conll_to_treex
