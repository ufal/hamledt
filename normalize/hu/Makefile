LANGCODE=hu
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2007/hu/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2007/hu/test.conll $(IN)/test.conll

treex: conll_to_treex


# make the trees as similar to the PDT-style as possible
# and store the result in 001_pdtstyle

# Parallel Treex is buggy. Restarting it several times would not make the process any faster.
#SCEN1 = A2A::HU::CoNLL2PDTStyle A2A::Pdt2TreexIsMemberConversion A2A::SetSharedModifier A2A::SetCoordConjunction #Util::Eval anode='$$node->set_is_member(0) if $$node->parent->afun eq "Apos"'
#pdt:
#	$(TREEX) -e ALL -E ALL --jobs 51 $(SCEN1) $(WRITE) path=$(DIR1)/train/ -- $(DIR0)/train/*.treex.gz
#	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/  -- $(DIR0)/test/*.treex.gz
