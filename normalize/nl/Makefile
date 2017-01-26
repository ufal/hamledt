LANGCODE=nl
TREEBANK=nl
UDCODE=nl
UDNAME=Dutch
include ../common.mak

POST_IMPORTX_BLOCKS = W2W::EstimateNoSpaceAfter

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	split_conll.pl < /net/data/conll/2006/nl/train.conll -head 13050 $(IN)/traindev.conll $(IN)/testplus.conll
	cat $(IN)/testplus.conll /net/data/conll/2006/nl/test.conll > $(IN)/test.conll
	split_conll.pl < $(IN)/traindev.conll -head 12330 $(IN)/train.conll $(IN)/dev.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
