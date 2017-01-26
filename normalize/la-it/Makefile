LANGCODE=la
TREEBANK=la-it
UDCODE=la_ittb
UDNAME=Latin-ITTB
HARMONIZE=HarmonizeIT
include ../common.mak
SRCDIR=/net/data/treebanks/la/it-tb-2016-05-04

POST_IMPORTX_BLOCKS = W2W::EstimateNoSpaceAfter

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s $(SRCDIR)/train.conll $(IN)/train.conll
	ln -s $(SRCDIR)/dev.conll $(IN)/dev.conll
	ln -s $(SRCDIR)/test.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
