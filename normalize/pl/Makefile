LANGCODE=pl
TREEBANK=pl
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /a/LRC_TMP/hamledt/data_translations/not_yet_hamledt_treebanks/pl/train.conll $(IN)/train.conll
	ln -s /a/LRC_TMP/hamledt/data_translations/not_yet_hamledt_treebanks/pl/test.conll $(IN)/test.conll

treex:  # there already is a treex conversion together with a Google Translate English translation
	mkdir -p $(DIR0)/train
	mkdir -p $(DIR0)/test
	cp /a/LRC_TMP/hamledt/data_translations/not_yet_hamledt_treebanks/pl/train/*.treex.gz $(DIR0)/train/
	cp /a/LRC_TMP/hamledt/data_translations/not_yet_hamledt_treebanks/pl/test/*.treex.gz $(DIR0)/test/
