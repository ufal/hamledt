LANGCODE=la
TREEBANK=la-it
HARMONIZE=HarmonizeIT
include ../common.mak
SRCDIR=/net/data/treebanks/la/it-tb-2015-06-30

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat $(SRCDIR)/train2.conll $(SRCDIR)/train3.conll > $(IN)/train.conll
	cat $(SRCDIR)/dev2.conll $(SRCDIR)/dev3.conll | ../conll_break_cycles.pl > $(IN)/dev.conll
	cat $(SRCDIR)/test2.conll $(SRCDIR)/test3.conll | ../conll_break_cycles.pl > $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
