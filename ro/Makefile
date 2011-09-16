SHELL=bash
LANGCODE=ro
ORIG_TREEBANK=${TMT_ROOT}/share/data/resources/treebanks/ro
DATADIR=${TMT_ROOT}/share/data/resources/normalized_treebanks/$(LANGCODE)
IN       = $(DATADIR)/source
DIR0     = $(DATADIR)/treex/000_orig
DIR1     = $(DATADIR)/treex/001_pdtstyle
TREEX    = treex -L$(LANGCODE)
IMPORT   = Read::DGA bundles_per_doc=500
WRITE0   = Write::Treex file_stem=''
WRITE    = Write::Treex

prepare_source: $(IN)/test.xml $(IN)/train.xml

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

prepare_dirs:
	@echo The root data directory for $(LANGCODE): $(DATADIR)
	mkdir -p $(DATADIR)
	if [ ! -e data ]; then ln -s $(DATADIR) data; fi
	mkdir -p {$(DIR0),$(DIR1)}/{train,test}
	chmod -R g+w data/. data/*

# run a conversion of the original data into the treex format
# and store the results in 000_orig/
to_treex:
	$(TREEX) $(IMPORT) from=$(IN)/train.xml $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORT) from=$(IN)/test.xml  $(WRITE0) path=$(DIR0)/test/

# make the trees as similar to the PDT-style as possible
# and store the result in 001_pdtstyle
SCEN1 = A2A::RO::RDT2PDTStyle
to_pdt:
	$(TREEX) -p -e ALL -E ALL --jobs 8 $(SCEN1) $(WRITE) path=$(DIR1)/train/ -- $(DIR0)/train/*.treex.gz
	$(TREEX) -p -e ALL -E ALL --jobs 1 $(SCEN1) $(WRITE) path=$(DIR1)/test/  -- $(DIR0)/test/*.treex.gz

# This goal serves development and debugging of the CoNLL2PDTStyle block.
test:
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/ -- $(DIR0)/test/*.treex.gz

clean:
	rm -rf $(DATADIR)/treex


