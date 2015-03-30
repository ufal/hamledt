LANGCODE=sl
TREEBANK=sl
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	/net/work/people/zeman/parsing/tools/split_conll.pl < /net/data/conll/2006/sl/train.conll -head 1200 $(IN)/train.conll $(IN)/dev.conll
	ln -s /net/data/conll/2006/sl/test.conll $(IN)/test.conll

treex: conll_to_treex
