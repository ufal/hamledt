LANGCODE=fa
TREEBANK=fa
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/persian-dt/data/train.conll $(TRAIN)
	ln -s /net/data/persian-dt/data/test.conll $(TEST)

treex: conll_to_treex
