SHELL:=/bin/bash
LANGCODE=et
DATADIR=$(TMT_ROOT)/share/data/resources/normalized_treebanks/$(LANGCODE)
IN       = $(DATADIR)/source
DIR0     = $(DATADIR)/treex/0000_constituents
DIR1     = $(DATADIR)/treex/000_orig
DIR2     = $(DATADIR)/treex/001_pdtstyle
TREEX    = treex -L$(LANGCODE)
IMPORT   = Read::Tiger
WRITE0   = Write::Treex file_stem='001'
WRITE    = Write::Treex


EXTRACT_BODY:=sed -n '/<body>/ {n;b c}; d;:c {\%</body>% {d};p;n;b c}'
prepare_source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	( echo '<corpus><body>'; \
	for file in /net/data/estonian-treebank/{arborest,piialaused,ratsepalaused,sul}.xml ; do \
		$(EXTRACT_BODY) $$file ; \
	done ; echo '</body></corpus>' ) | ./repair_encoding.pl > $(IN)/corpus.xml

prepare_dirs:
	@echo The root data directory for $(LANGCODE): $(DATADIR)
	mkdir -p $(DATADIR)
	if [ ! -e data ]; then ln -s $(DATADIR) data; fi
	for dir in $(DIR0) $(DIR1) $(DIR2) ; do \
		mkdir -p "$$dir"; \
		mkdir -p "$$dir"/train; \
		mkdir -p "$$dir"/test; \
	done
	chmod -R g+w data/. data/*

# run a conversion of the original data into the treex format
# and store the results in 0000_constituents/
to_treex:
	$(TREEX) $(IMPORT) from=$(IN)/corpus.xml Filter::NthSentence n=10 keep=0 $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORT) from=$(IN)/corpus.xml Filter::NthSentence n=10 keep=1 $(WRITE0) path=$(DIR0)/test/

# converts trees from phrase to dependency style
SCEN1 = P2A::TigerET
to_dep:
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/train/ -- $(DIR0)/train/*.treex.gz
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/  -- $(DIR0)/test/*.treex.gz

# converts dependencies to pdt style dependencies
SCEN2 = A2A::ET::TigerDep2PDT A2A::SetSharedModifier A2A::SetCoordConjunction
to_pdt:
	$(TREEX) $(SCEN2) $(WRITE) path=$(DIR2)/train/ -- $(DIR1)/train/*.treex.gz
	$(TREEX) $(SCEN2) $(WRITE) path=$(DIR2)/test/  -- $(DIR1)/test/*.treex.gz


# This goal serves development and debugging of the CoNLL2PDTStyle block.
test:
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/ -- $(DIR0)/test/*.treex.gz

clean:
	rm -rf $(DATADIR)/treex


