LANGCODE=bg
TREEBANK=bg
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	/net/work/people/zeman/parsing/tools/split_conll.pl < /net/data/conll/2006/bg/train.conll -head 12000 $(IN)/train.conll $(IN)/dev.conll
	ln -s /net/data/conll/2006/bg/test.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
