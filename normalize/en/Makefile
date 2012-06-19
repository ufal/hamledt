LANGCODE=en
include ../common.mak

IMPORT = Read::CoNLL2009 lines_per_doc=500

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2009/en/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2009/en/dev.conll $(IN)/test.conll

treex: conll_to_treex

# make the trees as similar to the PDT-style as possible
# and store the result in 001_pdtstyle
#SCEN1 = A2A::EN::CoNLL2PDTStyle
SCEN1= en2pdt.scen A2A::SetSharedModifier A2A::SetCoordConjunction

TO_PDT_TRAIN_OPT := -p --jobs 40
TO_PDT_TEST_OPT  := -p --jobs 2
