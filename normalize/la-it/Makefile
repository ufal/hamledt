LANGCODE=la
TREEBANK=la-it
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat /net/data/treebanks/la/IT-TB_01-Sept-2014/CONLL/IT-TB.conll | split_conll.pl -head 13375 $(IN)/traindev.conll $(IN)/test.conll
	cat $(IN)/traindev.conll | split_conll.pl -head 13000 $(IN)/train.conll $(IN)/dev.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
