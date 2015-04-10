LANGCODE=cs
TREEBANK=cs-ud1
include ../common.mak

SOURCEDIR=/net/data/universal-dependencies-1.0/$(LANGCODE)
source:
	cat $(SOURCEDIR)/$(LANGCODE)-ud-train-c.conllu $(SOURCEDIR)/$(LANGCODE)-ud-train-l.conllu $(SOURCEDIR)/$(LANGCODE)-ud-train-m.conllu $(SOURCEDIR)/$(LANGCODE)-ud-train-v.conllu > data/source/train.conllu
	cp $(SOURCEDIR)/$(LANGCODE)-ud-dev.conllu data/source/dev.conllu
	cp $(SOURCEDIR)/$(LANGCODE)-ud-test.conllu data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex

###!!! The following goal has been copied from another Makefile but it does not apply in this form to this dataset. It has to be adjusted!
SCHEMADIR=$(TMT_ROOT)/treex/lib/Treex/Block/Read/PDT_schema
treex:
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/train/*.a.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/ compress=1
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/dev/*.a.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/ compress=1
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/test/*.a.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/  compress=1
