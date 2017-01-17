LANGCODE=pt
TREEBANK=pt-udt2
UDCODE=pt_br
UDNAME=Portuguese-BR
HARMONIZE=HarmonizeGoogle
include ../common.mak
SOURCEDIR=/net/data/treebanks/universal_treebanks_v2.0/std/pt-br

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cp $(SOURCEDIR)/pt-br-universal-train.conll $(IN)/train.conll
	cp $(SOURCEDIR)/pt-br-universal-dev.conll $(IN)/dev.conll
	cp $(SOURCEDIR)/pt-br-universal-test.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map to one of prague_to_ud, orig_to_ud or conllu_to_treex.
ud: orig_to_ud
