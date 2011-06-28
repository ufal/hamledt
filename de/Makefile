LANGCODE=de
DATADIR=$(TMT_ROOT)/share/data/resources/normalized_treebanks/$(LANGCODE)

prepare_source:
	mkdir -p $(DATADIR)
	mkdir -p $(DATADIR)/source
	ln -s /net/data/conll/2009/de/train.conll $(DATADIR)/source/train.conll
	ln -s /net/data/conll/2009/de/dev.conll $(DATADIR)/source/test.conll

prepare_dirs:
	@echo The root data directory for $(LANGCODE): $(DATADIR)
	mkdir -p $(DATADIR)
	if [ ! -e data ]; then ln -s $(DATADIR) data; fi
	mkdir -p $(DATADIR)/treex/000_orig
	mkdir -p $(DATADIR)/treex/000_orig/train
	mkdir -p $(DATADIR)/treex/000_orig/test
	mkdir -p $(DATADIR)/treex/001_pdtstyle
	mkdir -p $(DATADIR)/treex/001_pdtstyle/train
	mkdir -p $(DATADIR)/treex/001_pdtstyle/test

# run a conversion of the original data into the treex format
# and store the results in 000_orig/
to_treex:

# make the trees as similar to the PDT-style as possible
# and store the result in 001_pdtstyle
to_pdt:

clean:
	rm -rf $(DATADIR)/treex


