LANGCODE=ca
TREEBANK=ca
UDCODE=ca
UDNAME=Catalan
include ../common.mak

IMPORTX = Read::CoNLL2009 lines_per_doc=100
POST_IMPORTX_BLOCKS = W2W::EstimateNoSpaceAfter

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2009/ca/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2009/ca/dtest.conll $(IN)/dev.conll
	ln -s /net/data/conll/2009/ca/etest.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
	@echo DO NOT GENERATE UD FROM THIS FOLDER UNLESS YOU KNOW WHAT YOU ARE DOING!
	@echo UD_Catalan-AnCora has been edited after the conversion.
	@echo A new conversion would destroy the changes that were done externally.
