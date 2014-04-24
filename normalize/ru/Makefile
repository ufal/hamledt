LANGCODE=ru
TREEBANK=ru
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	./copy_and_rename_files.pl

# run a conversion of the original data into the treex format
# and store the results in 000_orig/
treex:
	cat $(IN)/*.tgt | $(TREEX) \
		Read::Syntagrus lines_per_doc=500 \
		$(WRITE0) path=$(DIR0)/train/
	cat $(IN)/*.tgt.TEST | $(TREEX) \
		Read::Syntagrus lines_per_doc=500 \
		$(WRITE0) path=$(DIR0)/test/
