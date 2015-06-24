LANGCODE=pt
TREEBANK=pt
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	split_conll.pl < /net/data/conll/2006/pt/train.conll -head 8800 $(IN)/train.conll $(IN)/dev.conll
	ln -s /net/data/conll/2006/pt/test.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
