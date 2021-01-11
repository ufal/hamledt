LANGCODE=cs
TREEBANK=cs-t
UDCODE=cs_pdt
# Czech-PDTT is the same repo as Czech-PDT, but temporarily switched to the branch 'tecto'.
UDNAME=Czech-PDTT
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords HamleDT::CS::FixUD
include ../common.mak

SOURCEDIR=/net/projects/pdt/pdt35/PDT3.5/data
# subdirs: amw, tamw / train-[1-8] dtest etest / *.a.gz
source:
	mkdir -p data/source/train
	mkdir -p data/source/dev
	mkdir -p data/source/test
	# Na testy zatím nechat jen pár souborů, aby to bylo rychlejší.
	#ln -s $(SOURCEDIR)/tamw/train-[1-8]/*.[tamw].gz $(IN)/train
	#ln -s $(SOURCEDIR)/tamw/dtest/*.[tamw].gz $(IN)/dev
	#ln -s $(SOURCEDIR)/tamw/etest/*.[tamw].gz $(IN)/test
	ln -s $(SOURCEDIR)/tamw/train-1/ln94200_105.[tamw].gz $(IN)/train
	ln -s $(SOURCEDIR)/tamw/dtest/ln94200_103.[tamw].gz $(IN)/dev
	ln -s $(SOURCEDIR)/tamw/etest/ln94200_104.[tamw].gz $(IN)/test

SCHEMADIR=/net/work/people/zeman/treex/lib/Treex/Block/Read/PDT_schema
treex:
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=t from='!$(IN)/train/*.t.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/ compress=1
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=t from='!$(IN)/dev/*.t.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/ compress=1
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=t from='!$(IN)/test/*.t.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/  compress=1

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud_enhanced
