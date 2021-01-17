LANGCODE=cs
TREEBANK=cs-t
UDCODE=cs_pdt
# Czech-PDTT is the same repo as Czech-PDT, but temporarily switched to the branch 'tecto'.
UDNAME=Czech-PDTT
PRE_UD_BLOCKS=T2A::GenerateA2TRefs
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords HamleDT::CS::FixUD
include ../common.mak

SOURCEDIR=/net/projects/pdt/pdt35/PDT3.5/data
# subdirs: amw, tamw / train-[1-8] dtest etest / *.a.gz
source:
	mkdir -p data/source/train
	mkdir -p data/source/dev
	mkdir -p data/source/test
	# Odkomentovat jedno nebo druhé. Zpracování celých dat zde:
	ln -s $(SOURCEDIR)/tamw/train-[1-8]/*.[tamw].gz $(IN)/train
	ln -s $(SOURCEDIR)/tamw/dtest/*.[tamw].gz $(IN)/dev
	ln -s $(SOURCEDIR)/tamw/etest/*.[tamw].gz $(IN)/test
	# Na testy zatím nechat jen pár souborů, aby to bylo rychlejší.
	#ln -s $(SOURCEDIR)/tamw/train-1/ln94200_105.[tamw].gz $(IN)/train
	#ln -s $(SOURCEDIR)/tamw/dtest/ln94200_103.[tamw].gz $(IN)/dev
	#ln -s $(SOURCEDIR)/tamw/etest/ln94200_104.[tamw].gz $(IN)/test
	#ln -s $(SOURCEDIR)/tamw/train-1/cmpr9410_001.[tamw].gz $(IN)/train
	#ln -s $(SOURCEDIR)/tamw/train-1/mf920922_004.[tamw].gz $(IN)/train
	# Vesmír vůbec nemá tektogramatické anotace, takže do train-v nemáme jak přispět.

SCHEMADIR=/net/work/people/zeman/treex/lib/Treex/Block/Read/PDT_schema
treex:
	rm -rf $(DIR0)/{train,dev,test}/*.treex*
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=t from='!$(IN)/train/*.t.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=t from='!$(IN)/dev/*.t.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=t from='!$(IN)/test/*.t.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/  compress=0

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud_enhanced
	# Copy the new data to the Coref-UD project folder.
	cp /net/work/people/zeman/unidep/UD_$(UDNAME)/*.conllu /net/work/projects/corefud/data/cs-pdt
