LANGCODE=cs
TREEBANK=cs-pdtc
UDCODE=cs_pdtc
UDNAME=Czech-PDTC
HARMONIZE=Harmonize iset_driver=cs::pdtc
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords HamleDT::CS::FixUD
include ../common.mak

SOURCEDIR=/net/work/people/zeman/pdtc/WorkData
# subdirs: amw, tamw / train-[1-8] dtest etest / *.a.gz
source:
	mkdir -p data/source/train
	mkdir -p data/source/dev
	mkdir -p data/source/test
	ln -s $(SOURCEDIR)/PDT/data/{tamw,amw}/train-[1-8]/*.[amw] $(IN)/train
	ln -s $(SOURCEDIR)/PDT/data/{tamw,amw}/dtest/*.[amw] $(IN)/dev
	ln -s $(SOURCEDIR)/PDT/data/{tamw,amw}/etest/*.[amw] $(IN)/test
	ln -s $(SOURCEDIR)/Faust/data/*.[amw] $(IN)/train
	ln -s $(SOURCEDIR)/PDTSC/data/*.[amw] $(IN)/train
	ln -s $(SOURCEDIR)/PCEDT/data/*.[amw] $(IN)/train

#SCHEMADIR=$(TMT_ROOT)/treex/lib/Treex/Block/Read/PDT_schema
SCHEMADIR=/net/work/people/zeman/pdtc/tred-extension/pdt_c_m/resources
treex:
	$(QTREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/train/*.a' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/
	$(QTREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/dev/*.a' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/
	$(QTREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/test/*.a' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud_enhanced
