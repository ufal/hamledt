LANGCODE=cs
TREEBANK=cs-pdtm
UDCODE=cs_pdtm
UDNAME=Czech-PDTM
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords
include ../common.mak

SOURCEDIR=/net/projects/pdt/pdt30/data
# subdirs: mw, amw, tamw / train-[1-8] dtest etest / *.m.gz (ale co .a. tam, kde existuje?)
source:
	mkdir -p data/source/train
	mkdir -p data/source/dev
	mkdir -p data/source/test
	ln -s $(SOURCEDIR)/{tamw,amw,mw}/train-[1-8]/*.[amw].gz $(IN)/train
	ln -s $(SOURCEDIR)/{tamw,amw,mw}/dtest/*.[amw].gz $(IN)/dev
	ln -s $(SOURCEDIR)/{tamw,amw,mw}/etest/*.[amw].gz $(IN)/test

SCHEMADIR=$(TMT_ROOT)/treex/lib/Treex/Block/Read/PDT_schema
treex:
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=m from='!$(IN)/train/*.m.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/ compress=1
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=m from='!$(IN)/dev/*.m.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/ compress=1
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=m from='!$(IN)/test/*.m.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/  compress=1

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud_enhanced

