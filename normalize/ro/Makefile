LANGCODE=ro
include ../common.mak
ORIG_TREEBANK=${TMT_ROOT}/share/data/resources/treebanks/ro
IMPORT   = Read::DGA bundles_per_doc=500

source: $(IN)/test.xml $(IN)/train.xml

$(IN)/%.xml: $(ORIG_TREEBANK)/*.xml
	mkdir -p $(IN)
	echo '<?xml version="1.0" encoding="utf-8"?>' > $@
	echo '<!DOCTYPE DGAdoc SYSTEM "dga.dtd">' >> $@
	echo '<DGAdoc>' >> $@
	[ $* = train ] && SOURCE='tp*.xml' || SOURCE='t[0-9]*.xml';\
	for FILE in $(ORIG_TREEBANK)/$$SOURCE ; do\
	  head -n -1 $$FILE | tail -n +5 | iconv -f l1 -t utf8  >> $@;\
        done
	echo '</DGAdoc>' >> $@

treex: conll_to_treex

# make the trees as similar to the PDT-style as possible
# and store the result in 001_pdtstyle
SCEN1 = A2A::RO::RDT2PDTStyle A2A::SetSharedModifier A2A::SetCoordConjunction
pdt:
	$(TREEX) -p -e ALL -E ALL --jobs 8 $(SCEN1) $(WRITE) path=$(DIR1)/train/ -- $(DIR0)/train/*.treex.gz
	$(TREEX) -p -e ALL -E ALL --jobs 1 $(SCEN1) $(WRITE) path=$(DIR1)/test/  -- $(DIR0)/test/*.treex.gz
