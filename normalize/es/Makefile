LANGCODE=es
include ../common.mak

IMPORT = Read::CoNLL2009 lines_per_doc=500

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2009/es/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2009/es/dev.conll $(IN)/test.conll

treex: conll_to_treex

# Parallel Treex is buggy. Restarting it several times would not make the process any faster.
#TO_PDT_TRAIN_OPT := -p --jobs 15
#TO_PDT_TEST_OPT  := -p --jobs 2
