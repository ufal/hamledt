LANGCODE=cs
TREEBANK=cs-pdt30
include ../common.mak

SOURCEDIR=/net/projects/pdt/pdt30/data
# subdirs: amw, tamw / train-[1-8] dtest etest / *.a.gz
source:
	mkdir -p data/source/train
	mkdir -p data/source/test
	ln -s $(SOURCEDIR)/{tamw,amw}/{train-[1-8],dtest}/*.[amw].gz $(IN)/train
	ln -s $(SOURCEDIR)/{tamw,amw}/etest/*.[amw].gz $(IN)/test

SCHEMADIR=$(TMT_ROOT)/treex/lib/Treex/Block/Read/PDT_schema
treex:
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) t_layer=0 from='!$(IN)/train/*.a.gz' \
		Write::Treex clobber=1 path=$(DIR0)/train/ compress=1
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) t_layer=0 from='!$(IN)/test/*.a.gz' \
		Write::Treex clobber=1 path=$(DIR0)/test/  compress=1

TO_PDT_TRAIN_OPT := -p --jobs 100
