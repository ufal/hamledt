LANGCODE=nl
TREEBANK=nl
UDCODE=nl
UDNAME=Dutch
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	split_conll.pl < /net/data/conll/2006/nl/train.conll -head 13000 $(IN)/train.conll $(IN)/dev.conll
	ln -s /net/data/conll/2006/nl/test.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
