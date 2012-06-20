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

SCEN1 = A2A::CS::CoNLL2PDTStyle A2A::Pdt2TreexIsMemberConversion A2A::SetSharedModifier A2A::SetCoordConjunction #Util::Eval anode='$$node->set_is_member(0) if $$node->parent->afun eq "Apos"'

TO_PDT_TRAIN_OPT := -p --jobs 26

