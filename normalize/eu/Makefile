LANGCODE=eu
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat /net/data/basque-dt/trainingdataunificado2.conll /net/data/basque-dt/devdataunificado2.conll > $(IN)/train.conll
	cp /net/data/basque-dt/testdataunificado2.conll $(IN)/test.conll

treex: conll_to_treex
