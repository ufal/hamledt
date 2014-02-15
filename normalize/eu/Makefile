LANGCODE=eu
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat /net/data/basque-dt/trainingdataunificado2.conll /net/data/basque-dt/devdataunificado2.conll > $(IN)/train.conll
	cp /net/data/basque-dt/testdataunificado2.conll $(IN)/test.conll

treex: conll_to_treex

# Parallel Treex is buggy. Restarting it several times would not make the process any faster.
#TO_PDT_TRAIN_OPT := -p --jobs 11
#TO_PDT_TEST_OPT  := -p --jobs 2
