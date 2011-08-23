SHELL:=/bin/bash
LANGCODE=et
DATADIR=$(TMT_ROOT)/share/data/resources/normalized_treebanks/$(LANGCODE)
IN       = $(DATADIR)/source
DIR0     = $(DATADIR)/treex/000_orig
DIR1     = $(DATADIR)/treex/001_pdtstyle
TREEX    = treex -L$(LANGCODE)
IMPORT   = Read::Tiger
WRITE0   = Write::Treex file_stem='et'
WRITE    = Write::Treex


EXTRACT_BODY:=sed -n '/<body>/ {n;b c}; d;:c {\%</body>% {d};p;n;b c}'
prepare_source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	( echo '<corpus><body>'; \
	for file in /net/data/estonian-treebank/{piialaused,ratsepalaused,sul}.xml ; do \
		$(EXTRACT_BODY) $$file ; \
	done ; echo '</body></corpus>' ) > $(IN)/train.xml
	( echo '<corpus><body>' ; \
	$(EXTRACT_BODY) /net/data/estonian-treebank/arborest.xml; \
	echo '</body></corpus>' ) > $(IN)/test.xml

prepare_dirs:
	@echo The root data directory for $(LANGCODE): $(DATADIR)
	mkdir -p $(DATADIR)
	if [ ! -e data ]; then ln -s $(DATADIR) data; fi
	mkdir -p $(DIR0)
	mkdir -p $(DIR0)/train
	mkdir -p $(DIR0)/test
	mkdir -p $(DIR1)
	mkdir -p $(DIR1)/train
	mkdir -p $(DIR1)/test
	chmod -R g+w data/. data/*

# run a conversion of the original data into the treex format
# and store the results in 000_orig/
to_treex:
	$(TREEX) $(IMPORT) from=$(IN)/train.xml $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORT) from=$(IN)/test.xml  $(WRITE0) path=$(DIR0)/test/

# make the trees as similar to the PDT-style as possible
# and store the result in 001_pdtstyle
SCEN1 = A2A::TEMPLATE::CoNLL2PDTStyle
to_pdt:
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/train/ -- $(DIR0)/train/*.treex
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/  -- $(DIR0)/test/*.treex

# This goal serves development and debugging of the CoNLL2PDTStyle block.
test:
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/ -- $(DIR0)/test/*.treex

clean:
	rm -rf $(DATADIR)/treex


