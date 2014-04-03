LANGCODE=bg
TREEBANK=bg
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2006/bg/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2006/bg/test.conll $(IN)/test.conll

treex: conll_to_treex
