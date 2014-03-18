LANGCODE=en
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2007/en/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2007/en/test.conll $(IN)/test.conll

# Default would be
# treex: conll_to_treex
# The difference here is that we also perform lemmatization because the CoNLL 2007 English data do not contain lemmas.
treex:
	$(TREEX) $(IMPORT) from=$(IN)/train.conll W2A::EN::Lemmatize $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORT) from=$(IN)/test.conll  W2A::EN::Lemmatize $(WRITE0) path=$(DIR0)/test/

# Parallelize normalization to make it faster.
###!!! Vypadá to, že za současného nastavení se pro train i test dohromady použije počet úloh z ...TRAIN_OPT a ...TEST_OPT se ignoruje.
TO_PDT_TRAIN_OPT := -p --jobs 39
