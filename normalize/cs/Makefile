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

SCEN1 = A2A::CS::Harmonize A2A::Pdt2TreexIsMemberConversion A2A::SetSharedModifier A2A::SetCoordConjunction A2A::Pdt2HamledtApos

TO_PDT_TRAIN_OPT := -p --jobs 26

