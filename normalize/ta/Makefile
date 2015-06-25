LANGCODE=ta
TREEBANK=ta
include ../common.mak
TOOLS=/net/work/people/zeman/parsing/tools

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	$(TOOLS)/split_conll.pl < /net/data/TamilTB/train.conll -head 400 $(IN)/train.conll $(IN)/dev.conll
	ln -s /net/data/TamilTB/test.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
