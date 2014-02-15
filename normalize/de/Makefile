LANGCODE=de
include ../common.mak

IMPORT = Read::CoNLL2009 lines_per_doc=500

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2009/de/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2009/de/dev.conll $(IN)/test.conll

treex: conll_to_treex

# Temporarily add two specialized blocks; what they do should be solved directly in Harmonize.
POSTPROCESS2_SCEN_OPT := A2A::DE::RehangJunctors A2A::DE::RehangAuxc
# Parallel Treex is buggy. Restarting it several times would not make the process any faster.
#TO_PDT_TRAIN_OPT := -p --jobs 37
#TO_PDT_TEST_OPT  := -p --jobs 2
