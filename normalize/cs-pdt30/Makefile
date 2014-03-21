###!!! Pozor, tohle sice je kód jazyka, ale ten se dosud používal i pro tvorbu cest, a to teď už neplatí.
###!!! Asi potřebujeme ještě něco jako TREEBANK=cs-pdt30
LANGCODE=cs
include ../common.mak

# subdirs: amw, tamw / train-[1-8] dtest etest / *.a.gz
SOURCEDIR=/net/projects/pdt/pdt30/data
source:
	echo NOT YET IMPLEMENTED

SCHEMADIR=$(TMT_ROOT)/treex/lib/Treex/Block/Read/PDT_schema
treex:
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) t_layer=0 from='!$(IN)/train/*.a' \
		Write::Treex clobber=1 path=$(DIR0)/train/ compress=1
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) t_layer=0 from='!$(IN)/test/*.a' \
		Write::Treex clobber=1 path=$(DIR0)/test/  compress=1

TO_PDT_TRAIN_OPT := -p --jobs 26
