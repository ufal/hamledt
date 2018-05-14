LANGCODE=ko
TREEBANK=ko-pud
UDCODE=ko_pud
UDNAME=Korean-PUD
include ../common.mak
SOURCEDIR=/net/work/people/zeman/unidep/parallel-treebanks/ud2

#POST_IMPORTX_BLOCKS = W2W::EstimateNoSpaceAfter

# make dirs
# make source
# make ud

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cp $(SOURCEDIR)/ko.conllu $(IN)/test.conllu

#treex: conll_to_treex

# ud should map to one of prague_to_ud, orig_to_ud or conllu_to_treex.
ud: conllu_to_treex
