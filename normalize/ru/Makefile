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
		Read::Syntagrus lines_per_doc=100 \
		$(WRITE0) path=$(DIR0)/train/
	cat $(IN)/*.tgt.DEV | $(TREEX) \
		Read::Syntagrus lines_per_doc=100 \
		$(WRITE0) path=$(DIR0)/dev/
	cat $(IN)/*.tgt.TEST | $(TREEX) \
		Read::Syntagrus lines_per_doc=100 \
		$(WRITE0) path=$(DIR0)/test/

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
