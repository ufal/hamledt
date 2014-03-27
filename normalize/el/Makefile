LANGCODE=el
TREEBANK=el
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s  /net/data/conll/2010-pred-publikaci/2007/multilingual_data/greek/gdt/train/greek_gdt_train.conll $(IN)/train.conll
	ln -s /net/data/conll/2010-pred-publikaci/2007/multilingual_test/greek/gdt/test/greek_gdt_test.conll  $(IN)/test.conll

treex: conll_to_treex

# Parallelize normalization to make it faster.
###!!! Vypadá to, že za současného nastavení se pro train i test dohromady použije počet úloh z ...TRAIN_OPT a ...TEST_OPT se ignoruje.
TO_PDT_TRAIN_OPT := -p --jobs 52
