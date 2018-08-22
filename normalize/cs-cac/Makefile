LANGCODE=cs
TREEBANK=cs-cac
UDCODE=cs_cac
UDNAME=Czech-CAC
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords
include ../common.mak

SOURCEDIR=/net/projects/cac/cac20/data/pml
SCHEMADIR=/net/projects/cac/cac20/data/schemas
# There is no official train / dev / test data split. Temporary: s50w is dev, s60w is test, the rest is train.
source:
	mkdir -p data/source/train
	mkdir -p data/source/dev
	mkdir -p data/source/test
	cp $(SOURCEDIR)/{[ans][03-9]0w,[ans][0-9][1-9]w}.[amw].gz $(IN)/train
	cp $(SOURCEDIR)/[ans]10w.[amw].gz $(IN)/dev
	cp $(SOURCEDIR)/[ans]20w.[amw].gz $(IN)/test
	gunzip $(IN)/{train,dev,test}/*.gz

#SCHEMADIR=$(TMT_ROOT)/treex/lib/Treex/Block/Read/PDT_schema
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
ud: prague_to_ud_enhanced
