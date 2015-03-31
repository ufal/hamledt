LANGCODE=pl
TREEBANK=pl
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	/net/work/people/zeman/parsing/tools/split_conll.pl < /a/LRC_TMP/hamledt/data_translations/not_yet_hamledt_treebanks/pl/train.conll -head 6800 $(IN)/train.conll $(IN)/dev.conll
	ln -s /a/LRC_TMP/hamledt/data_translations/not_yet_hamledt_treebanks/pl/test.conll $(IN)/test.conll

treex: conll_to_treex

treex_rur:  # there already is a treex conversion together with a Google Translate English translation (but it does not have dev set)
	mkdir -p $(DIR0)/train
	mkdir -p $(DIR0)/test
	cp /a/LRC_TMP/hamledt/data_translations/not_yet_hamledt_treebanks/pl/train/*.treex.gz $(DIR0)/train/
	cp /a/LRC_TMP/hamledt/data_translations/not_yet_hamledt_treebanks/pl/test/*.treex.gz $(DIR0)/test/
