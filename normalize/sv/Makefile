LANGCODE=sv
TREEBANK=sv
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2006/sv/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2006/sv/test.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
