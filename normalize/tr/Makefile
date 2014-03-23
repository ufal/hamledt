LANGCODE=tr
TREEBANK=tr
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2007/tr/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2007/tr/test.conll $(IN)/test.conll

treex: conll_to_treex
