LANGCODE=cs
TREEBANK=cs-cltt
UDCODE=cs_cltt
UDNAME=Czech-CLTT
HARMONIZE=Harmonize iset_driver=cs::pdt
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords HamleDT::CS::FixUD
include ../common.mak

SOURCEDIR=/net/data/treebanks/cs/cltt
SCHEMADIR=/net/data/treebanks/cs/cltt
# There is no official train / dev / test data split.
# document_01_001.a
source:
	mkdir -p data/source/train
	mkdir -p data/source/dev
	mkdir -p data/source/test
	cp $(SOURCEDIR)/document_01*.[amw] $(IN)/train
	cp $(SOURCEDIR)/document_02_00[1-38].[amw] $(IN)/train
	cp $(SOURCEDIR)/document_02_00[45].[amw] $(IN)/dev
	cp $(SOURCEDIR)/document_02_00[67].[amw] $(IN)/test

treex:
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/train/*.a' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/ compress=1
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/dev/*.a' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/ compress=1
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/test/*.a' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/  compress=1

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
