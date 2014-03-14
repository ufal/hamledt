LANGCODE=cs
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2007/cs/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2007/cs/test.conll $(IN)/test.conll

treex: conll_to_treex

# make the trees as similar to the PDT-style as possible
# and store the result in 001_pdtstyle

# SCEN1 = HamleDT::CS::Harmonize HamleDT::Pdt2TreexIsMemberConversion HamleDT::SetSharedModifier HamleDT::SetCoordConjunction HamleDT::Pdt2HamledtApos
# the blocks are now called from within HamleDT::CS::Harmonize

TO_PDT_TRAIN_OPT := -p --jobs 26

