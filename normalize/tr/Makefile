LANGCODE=tr
TREEBANK=tr
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2007/tr/dtrain.conll $(IN)/train.conll
	ln -s /net/data/conll/2007/tr/dtest.conll $(IN)/dev.conll
	ln -s /net/data/conll/2007/tr/test.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
