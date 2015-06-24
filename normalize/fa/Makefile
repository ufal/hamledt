LANGCODE=fa
TREEBANK=fa
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/persian-dt/data/train.conll $(TRAIN)
	ln -s /net/data/persian-dt/data/dev.conll $(DEV)
	ln -s /net/data/persian-dt/data/test.conll $(TEST)

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
