LANGCODE=de
include ../common.mak

IMPORT = Read::CoNLL2009 lines_per_doc=500

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2009/de/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2009/de/dev.conll $(IN)/test.conll

treex: conll_to_treex

SCEN1 = HamleDT::DE::CoNLL2PDTStyle HamleDT::DE::RehangJunctors HamleDT::DE::RehangAuxc

TO_PDT_TRAIN_OPT := -p --jobs 37
TO_PDT_TEST_OPT  := -p --jobs 2
