LANGCODE=de
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2009/de/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2009/de/dev.conll $(IN)/test.conll

treex: conll_to_treex

SCEN1 = A2A::DE::CoNLL2PDTStyle A2A::DE::RehangJunctors A2A::DE::RehangAuxc
