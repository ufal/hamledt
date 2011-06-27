LANGCODE=ta
DATADIR=$(TMT_ROOT)/share/data/resources/normalized_treebanks/$(LANGCODE)

# input treebank
CONLL_FILE=/net/data/TamilTB/TamilTB.v0.1/data/TamilTB.v0.1.conll

# treebank in treex format
TREEX_ORIG=$(DATADIR)/treex/000_orig/ta.treex

all: clean prepare_dirs to_treex 

prepare_dirs:
	@echo The root data directory for $(LANGCODE): $(DATADIR)
	mkdir -p $(DATADIR)
	mkdir -p $(DATADIR)/treex/000_orig
	mkdir -p $(DATADIR)/treex/000_orig/train
	mkdir -p $(DATADIR)/treex/000_orig/test
	mkdir -p $(DATADIR)/treex/001_pdtstyle
	mkdir -p $(DATADIR)/treex/001_pdtstyle/train
	mkdir -p $(DATADIR)/treex/001_pdtstyle/test

# run a conversion of the original data into the treex format
# and store the results in 000_orig/
to_treex:	
	treex -Lta Read::CoNLLX from=$(CONLL_FILE) A2A::TA::CoNLL2PDTStyle Write::Treex to=$(TREEX_ORIG)

# make the trees as similar to the PDT-style as possible
# and store the result in 000_pdtstyle
to_pdt:

clean:
	rm -rf $(DATADIR)/treex
