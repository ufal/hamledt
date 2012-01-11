LANGCODE=ca
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2009/ca/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2009/ca/dev.conll $(IN)/test.conll

treex: conll_to_treex
