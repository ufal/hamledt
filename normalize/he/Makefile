LANGCODE = he
include ../common.mak
IMPORT = Read::CoNLLXfp lines_per_doc=500

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/projects/tectomt_shared/data/resources/treebanks/$(LANGCODE)/data/autotags.train.utf8 $(IN)/train_only.conll
	ln -s /net/projects/tectomt_shared/data/resources/treebanks/$(LANGCODE)/data/autotags.dev.utf8 $(IN)/dev_only.conll
	cat $(IN)/train_only.conll $(IN)/dev_only.conll > $(IN)/train.conll
	ln -s /net/projects/tectomt_shared/data/resources/treebanks/$(LANGCODE)/data/autotags.test.utf8 $(IN)/test.conll
	ln -s /a/LRC_TMP/hamledt/data_translations/not_yet_hamledt_treebanks/$(LANGCODE)/ $(IN)/translation

# the ords are floating point numbers, encoding token segmentation
treex: conll_to_treex

