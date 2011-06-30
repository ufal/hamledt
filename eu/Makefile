LANGCODE=eu
DATADIR=$(TMT_ROOT)/share/data/resources/normalized_treebanks/$(LANGCODE)
IN       = $(DATADIR)/source
DIR0     = $(DATADIR)/treex/000_orig
DIR1     = $(DATADIR)/treex/001_pdtstyle
TREEX    = treex -L$(LANGCODE)
IMPORT   = Read::CoNLLX lines_per_doc=500
WRITE    = Write::Treex

prepare_source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat /net/data/basque-dt/trainingdataunificado2.conll /net/data/basque-dt/devdataunificado2.conll > $(IN)/train.conll
	cp /net/data/basque-dt/testdataunificado2.conll $(IN)/test.conll

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

# run a conversion of the original data into the treex format
# and store the results in 000_orig/
to_treex:
	$(TREEX) $(IMPORT) from=$(IN)/train.conll $(WRITE) path=$(DIR0)/train/
	$(TREEX) $(IMPORT) from=$(IN)/test.conll  $(WRITE) path=$(DIR0)/test/

# make the trees as similar to the PDT-style as possible
# and store the result in 001_pdtstyle
SCEN1 = A2A::EU::CoNLL2PDTStyle
to_pdt:
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/train/ -- $(DIR0)/train/*.treex
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/  -- $(DIR0)/test/*.treex

clean:
	rm -rf $(DATADIR)/treex


