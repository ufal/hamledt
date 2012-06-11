LANGCODE=el
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s  /net/data/conll/2010-pred-publikaci/2007/multilingual_data/greek/gdt/train/greek_gdt_train.conll $(IN)/train.conll
	ln -s /net/data/conll/2010-pred-publikaci/2007/multilingual_test/greek/gdt/test/greek_gdt_test.conll  $(IN)/test.conll

treex: conll_to_treex
