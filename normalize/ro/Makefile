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

treex:
	$(TREEX) $(IMPORT) from=$(IN)/test.xml  $(WRITE0) path=$(DIR0)/test/
	$(TREEX) $(IMPORT) from=$(IN)/train.xml $(WRITE0) path=$(DIR0)/train/

# make the trees as similar to the PDT-style as possible
# and store the result in 001_pdtstyle
# SCEN1 = HamleDT::RO::Harmonize HamleDT::SetSharedModifier HamleDT::SetCoordConjunction
# the block are now called from within HamleDT::RO::Harmonize