LANGCODE=cs
TREEBANK=cs-conll2007
HARMONIZE=HarmonizeCoNLL
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2007/cs/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2007/cs/test.conll $(IN)/test.conll

treex: conll_to_treex
