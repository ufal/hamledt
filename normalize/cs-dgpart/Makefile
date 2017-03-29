LANGCODE=cs
TREEBANK=cs-dgpart
UDCODE=cs_dgpart
UDNAME=Czech-DGParT
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords
include ../common.mak

# DFKI-Google Parallel Treebank
# Intermediate processing of the Czech part: take XPOSTAG+lemma annotation from Milan, process it as if it was Prague Dependency Treebank.

SOURCE=/home/straka/small_projects/conll17_cs_data/tagged-2-conllu-xpos/Data_Czech_morpho_1000.conllu
source:
	mkdir -p data/source
	cp $(SOURCE) data/source/train.conllu
	ln -s data/source/train.conllu data/source/dev.conllu
	ln -s data/source/train.conllu data/source/test.conllu

treex:
	$(TREEX) \
		Read::CoNLLU from='!$(IN)/test.conllu' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/ compress=1

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud

