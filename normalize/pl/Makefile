LANGCODE=pl
TREEBANK=pl
include ../common.mak
SRCDIR=/a/LRC_TMP/hamledt/data_translations/not_yet_hamledt_treebanks/pl
TOOLS=/net/work/people/zeman/parsing/tools

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	$(TOOLS)/split_conll.pl < $(SRCDIR)/train.conll -head 6800 $(IN)/train.conll $(IN)/dev.conll
	ln -s $(SRCDIR)/test.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
