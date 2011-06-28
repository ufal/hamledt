LANGCODE=ta
DATADIR=$(TMT_ROOT)/share/data/resources/normalized_treebanks/$(LANGCODE)

# treebank
TB=/net/data/TamilTB/TamilTB.v0.1/data/TamilTB.v0.1.conll

# orig conll
CONLL_FILE=$(DATADIR)/treex/000_orig/$(LANGCODE).conll
CONLL_TRAIN=$(DATADIR)/treex/000_orig/train/$(LANGCODE)_train.conll
CONLL_TEST=$(DATADIR)/treex/000_orig/test/$(LANGCODE)_test.conll

# pdt style treebank in treex format
TREEX_FILE=$(DATADIR)/treex/001_pdtstyle/$(LANGCODE).treex
TREEX_TRAIN=$(DATADIR)/treex/001_pdtstyle/train/$(LANGCODE)_train.treex
TREEX_TEST=$(DATADIR)/treex/001_pdtstyle/test/$(LANGCODE)_test.treex

all: clean prepare_dirs to_treex to_pdt

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
	@echo "\n"
	cp $(TB) $(CONLL_FILE)
	@echo "\n"
	@echo "Dividing the data into training and testing sets ==> \n"
	cat $(CONLL_FILE) | $(TMT_ROOT)/tools/data_partitioning/divide_data.pl -x $(CONLL_TRAIN) -y $(CONLL_TEST)

# make the trees as similar to the PDT-style as possible
# and store the result in 000_pdtstyle
to_pdt:
	@echo "\n"
	@echo "Converting conll files into pdt style treex format ==> \n"
	treex -Lta Read::CoNLLX from=$(CONLL_FILE) A2A::TA::CoNLL2PDTStyle Write::Treex to=$(TREEX_FILE)
	treex -Lta Read::CoNLLX from=$(CONLL_TRAIN) A2A::TA::CoNLL2PDTStyle Write::Treex to=$(TREEX_TRAIN)
	treex -Lta Read::CoNLLX from=$(CONLL_TEST) A2A::TA::CoNLL2PDTStyle Write::Treex to=$(TREEX_TEST)

clean:
	rm -rf $(DATADIR)/treex
