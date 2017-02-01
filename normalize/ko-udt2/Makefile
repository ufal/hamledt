LANGCODE=ko
TREEBANK=ko-udt2
UDCODE=ko
UDNAME=Korean
include ../common.mak
SOURCEDIR=/net/data/treebanks/universal_treebanks_v2.0/std/ko

POST_IMPORTX_BLOCKS = W2W::EstimateNoSpaceAfter

# make dirs
# make source
# make treex
# make ud

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	split_conll.pl < $(SOURCEDIR)/ko-universal-train.conll -head 5350 $(IN)/traindev.conll $(IN)/addtest.conll
	split_conll.pl < $(IN)/traindev.conll -head 4400 $(IN)/train.conll $(IN)/dev.conll
	cat $(IN)/addtest.conll $(SOURCEDIR)/ko-universal-dev.conll $(SOURCEDIR)/ko-universal-test.conll > $(IN)/test.conll

treex: conll_to_treex

# ud should map to one of prague_to_ud, orig_to_ud or conllu_to_treex.
ud: orig_to_ud
