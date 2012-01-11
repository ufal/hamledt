LANGCODE=en
include ../common.mak

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
to_pdt:
	$(TREEX) -e ALL -E ALL --jobs 79 $(SCEN1) $(WRITE) path=$(DIR1)/train/ -- $(DIR0)/train/*.treex.gz
	$(TREEX) -e ALL -E ALL --jobs 3 $(SCEN1) $(WRITE) path=$(DIR1)/test/  -- $(DIR0)/test/*.treex.gz
