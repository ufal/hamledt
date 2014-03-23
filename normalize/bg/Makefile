LANGCODE=bg
TREEBANK=bg
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2006/bg/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2006/bg/test.conll $(IN)/test.conll

treex: conll_to_treex

# Parallelize normalization to make it faster.
###!!! Vypadá to, že za současného nastavení se pro train i test dohromady použije počet úloh z ...TRAIN_OPT a ...TEST_OPT se ignoruje.
TO_PDT_TRAIN_OPT := -p --jobs 27
TO_PDT_TEST_OPT  := -p --jobs 2
