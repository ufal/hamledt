LANGCODE=ca
TREEBANK=ca
include ../common.mak

IMPORTX = Read::CoNLL2009 lines_per_doc=500

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2009/ca/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2009/ca/dtest.conll $(IN)/dev.conll
	ln -s /net/data/conll/2009/ca/etest.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
