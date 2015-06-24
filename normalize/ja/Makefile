LANGCODE=ja
TREEBANK=ja
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	split_conll.pl < /net/data/conll/2006/ja/train.conll -head 16400 $(IN)/train.conll $(IN)/dev.conll
	ln -s /net/data/conll/2006/ja/test.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
