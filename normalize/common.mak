SHELL=/bin/bash

# To be included from the language-specific makefiles like this:
# include ../common.mak
DATADIR  = $(TMT_ROOT)/share/data/resources/hamledt/$(LANGCODE)
IN       = $(DATADIR)/source
DIR0     = $(DATADIR)/treex/000_orig
DIR1     = $(DATADIR)/treex/001_pdtstyle
TREEX    = treex -L$(LANGCODE)
IMPORT   = Read::CoNLLX lines_per_doc=500
WRITE0   = Write::Treex file_stem='' clobber=1
WRITE    = Write::Treex clobber=1
TRAIN    = $(IN)/train.conll
TEST     = $(IN)/test.conll
TO_PDT_TRAIN_OPT :=
TO_PDT_TEST_OPT  :=
POSTPROCESS1_SCEN_OPT :=
POSTPROCESS2_SCEN_OPT :=

check-source:
	[ -d $(IN) ] || (echo new $(LANGCODE) && make source)

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
#TODO: skip the A2A::DeleteAfunCoordWithoutMembers block, check the cases when it had to be applied (Test::A::MemberInEveryCoAp) and fix it properly
SCEN1  = A2A::$(UCLANG)::CoNLL2PDTStyle $(POSTPROCESS1_SCEN_OPT) A2A::SetSharedModifier A2A::SetCoordConjunction A2A::DeleteAfunCoordWithoutMembers $(POSTPROCESS2_SCEN_OPT)

pdt:
	$(TREEX) $(TO_PDT_TRAIN_OPT) $(SCEN1)  Write::Treex substitute={000_orig}{001_pdtstyle} -- '!$(DIR0)/{train,test}/*.treex.gz'

# This goal serves development and debugging of the CoNLL2PDTStyle block.
# Smaller data are processed faster.
# $(TREEX) is not used because we do not want to parallelize the task on the cluster.
# (By default, copies of logs from parallel jobs lack the TREEX-INFO level.)
test:
	treex -L$(LANGCODE) $(SCEN1) $(WRITE) path=$(DIR1)/test -- '!$(DIR0)/test/*.treex.gz'

clean:
	rm -rf $(DATADIR)/treex

pokus:
	echo $(SCEN1)