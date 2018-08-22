LANGCODE=cs
TREEBANK=cs
UDCODE=cs_pdt
UDNAME=Czech-PDT
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords
include ../common.mak

SOURCEDIR=/net/projects/pdt/pdt30/data
# subdirs: amw, tamw / train-[1-8] dtest etest / *.a.gz
source:
	mkdir -p data/source/train
	mkdir -p data/source/dev
	mkdir -p data/source/test
	ln -s $(SOURCEDIR)/{tamw,amw}/train-[1-8]/*.[amw].gz $(IN)/train
	ln -s $(SOURCEDIR)/{tamw,amw}/dtest/*.[amw].gz $(IN)/dev
	ln -s $(SOURCEDIR)/{tamw,amw}/etest/*.[amw].gz $(IN)/test

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

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud_enhanced

