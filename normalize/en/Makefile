LANGCODE=en
TREEBANK=en
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2007/en/dtrain.conll $(IN)/train.conll
	ln -s /net/data/conll/2007/en/dtest.conll $(IN)/dev.conll
	ln -s /net/data/conll/2007/en/test.conll $(IN)/test.conll

# Default would be
# treex: conll_to_treex
# The difference here is that we also perform lemmatization because the CoNLL 2007 English data do not contain lemmas.
treex:
	$(TREEX) $(IMPORTX) from=$(IN)/train.conll W2A::EN::Lemmatize $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORTX) from=$(IN)/dev.conll   W2A::EN::Lemmatize $(WRITE0) path=$(DIR0)/dev/
	$(TREEX) $(IMPORTX) from=$(IN)/test.conll  W2A::EN::Lemmatize $(WRITE0) path=$(DIR0)/test/

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
