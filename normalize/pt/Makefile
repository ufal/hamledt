LANGCODE=pt
TREEBANK=pt
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2006/pt/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2006/pt/test.conll $(IN)/test.conll

treex: conll_to_treex
