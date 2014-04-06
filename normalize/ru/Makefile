LANGCODE=ru
TREEBANK=ru
include ../common.mak
IMPORT   = Read::Syntagrus lines_per_doc=500

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	./copy_and_rename_files.pl

# run a conversion of the original data into the treex format
# and store the results in 000_orig/
treex:
	cat $(IN)/*.tgt | $(TREEX) $(IMPORT) $(WRITE0) path=$(DIR0)/train/
	cat $(IN)/*.tgt.TEST | $(TREEX) $(IMPORT) $(WRITE0) path=$(DIR0)/test/
