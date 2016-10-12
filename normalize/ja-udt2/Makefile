LANGCODE=ja
TREEBANK=ja-udt2
UDCODE=ja
UDNAME=Japanese
HARMONIZE=HarmonizeGoogle
include ../common.mak
SOURCEDIR=/net/data/treebanks/universal_treebanks_v2.0/std/ja

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cp $(SOURCEDIR)/ja-universal-train.conll $(IN)/train.conll
	cp $(SOURCEDIR)/ja-universal-dev.conll $(IN)/dev.conll
	cp $(SOURCEDIR)/ja-universal-test.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map to one of prague_to_ud, orig_to_ud or conllu_to_treex.
ud: orig_to_ud
