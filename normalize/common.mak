SHELL=/bin/bash

# To be included from the language-specific makefiles like this:
# include ../common.mak
DATADIR  = $(TMT_ROOT)/share/data/resources/hamledt/$(LANGCODE)
IN       = $(DATADIR)/source
DIR0     = $(DATADIR)/treex/000_orig
DIR1     = $(DATADIR)/treex/001_pdtstyle
TREEX    = treex -L$(LANGCODE)
IMPORT   = Read::CoNLLX lines_per_doc=500
WRITE0   = Write::Treex file_stem=''
WRITE    = Write::Treex clobber=1
TRAIN    = $(IN)/train.conll
TEST     = $(IN)/test.conll

dirs:
	@echo The root data directory for $(LANGCODE): $(DATADIR)
	mkdir -p $(DATADIR)
	if [ ! -e data ]; then ln -s $(DATADIR) data; fi
	mkdir -p {$(DIR0),$(DIR1)}/{train,test}
	chmod -R g+w data/. data/*

# Run a conversion of the original data into the treex format
# and store the results in 000_orig. This default assumes CoNLL-X,
# our most-widely used source format. If a different conversion
# is needed, override in the language-specific Makefile.
# Otherwise, define the language-specific "treex" goal as dependent
# on "conll_to_treex".
conll_to_treex:
	$(TREEX) $(IMPORT) from=$(IN)/train.conll $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORT) from=$(IN)/test.conll  $(WRITE0) path=$(DIR0)/test/

# Make the trees as similar to the PDT-style as possible
# and store the result in 001_pdtstyle.
UCLANG = $(shell perl -e 'print uc "$(LANGCODE)"')
SCEN1  = A2A::$(UCLANG)::CoNLL2PDTStyle A2A::SetSharedModifier A2A::SetCoordConjunction
pdt:
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/train/ -- $(DIR0)/train/*.treex.gz
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/  -- $(DIR0)/test/*.treex.gz

# This goal serves development and debugging of the CoNLL2PDTStyle block.
# Smaller data are processed faster.
# $(TREEX) is not used because we do not want to parallelize the task on the cluster.
# (By default, copies of logs from parallel jobs lack the TREEX-INFO level.)
test:
	treex -L$(LANGCODE) $(SCEN1) $(WRITE) path=$(DIR1)/test -- $(DIR0)/test/*.treex.gz

clean:
	rm -rf $(DATADIR)/treex
