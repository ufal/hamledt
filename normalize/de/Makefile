LANGCODE=de
TREEBANK=de
include ../common.mak

IMPORTX = Read::CoNLL2009 lines_per_doc=100

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2009/de/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2009/de/dtest.conll $(IN)/dev.conll
	ln -s /net/data/conll/2009/de/etest.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
