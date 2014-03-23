LANGCODE=hu
TREEBANK=hu
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2007/hu/train.conll $(IN)/train.conll
	ln -s /net/data/conll/2007/hu/test.conll $(IN)/test.conll

treex: conll_to_treex


# make the trees as similar to the PDT-style as possible
# and store the result in 001_pdtstyle

# SCEN1 = HamleDT::HU::Harmonize HamleDT::Pdt2TreexIsMemberConversion HamleDT::SetSharedModifier HamleDT::SetCoordConjunction #Util::Eval anode='$$node->set_is_member(0) if $$node->parent->afun eq "Apos"'
# the blocks are now called from HamleDT::HU::Harmonize

pdt:
	$(TREEX) -e ALL -E ALL --jobs 51 $(SCEN1) $(WRITE) path=$(DIR1)/train/ -- $(DIR0)/train/*.treex.gz
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/  -- $(DIR0)/test/*.treex.gz
