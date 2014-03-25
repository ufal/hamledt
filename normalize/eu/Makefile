LANGCODE=eu
TREEBANK=eu
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat /net/data/basque-dt/trainingdataunificado2.conll /net/data/basque-dt/devdataunificado2.conll | ../conll_break_cycles.pl > $(IN)/train.conll
	cat /net/data/basque-dt/testdataunificado2.conll | ../conll_break_cycles.pl > $(IN)/test.conll 

treex: conll_to_treex

TO_PDT_TRAIN_OPT := -p --jobs 11
TO_PDT_TEST_OPT  := -p --jobs 2
