LANGCODE=it
TREEBANK=it
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2007/it/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2007/it/test.conll $(IN)/test.conll

treex: conll_to_treex
