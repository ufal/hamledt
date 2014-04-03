LANGCODE=ca
TREEBANK=ca
include ../common.mak

IMPORT = Read::CoNLL2009 lines_per_doc=500

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2009/ca/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2009/ca/dev.conll $(IN)/test.conll

treex: conll_to_treex
