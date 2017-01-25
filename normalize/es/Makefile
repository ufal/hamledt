LANGCODE=es
TREEBANK=es
UDCODE=es_ancora
UDNAME=Spanish-AnCora
include ../common.mak

IMPORTX = Read::CoNLL2009 lines_per_doc=100

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2009/es/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2009/es/dtest.conll $(IN)/dev.conll
	ln -s /net/data/conll/2009/es/etest.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
