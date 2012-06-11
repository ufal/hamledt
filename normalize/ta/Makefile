LANGCODE=ta
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/TamilTB/train.conll $(IN)/train.conll
	ln -s /net/data/TamilTB/test.conll $(IN)/test.conll

treex: conll_to_treex
