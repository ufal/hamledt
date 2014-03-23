LANGCODE=sl
TREEBANK=sl
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2006/sl/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2006/sl/test.conll $(IN)/test.conll

treex: conll_to_treex
