LANGCODE=cs
TREEBANK=cs-pcedt
UDCODE=cs_pcedt
UDNAME=Czech-PCEDT
PRE_UD_BLOCKS=T2A::GenerateA2TRefs
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords HamleDT::CS::FixUD
include ../common.mak

SOURCEDIR=/net/data/pcedt2.0/data
# subdirs: 00-24
source:
	mkdir -p data/source/train
	mkdir -p data/source/dev
	mkdir -p data/source/test
	# Odkomentovat jedno nebo druhé. Zpracování celých dat zde:
	ln -s $(SOURCEDIR)/{0[0-9],1[0-8]}/*.treex.gz $(IN)/train
	ln -s $(SOURCEDIR)/{19,20,21}/*.treex.gz $(IN)/dev
	ln -s $(SOURCEDIR)/{22,23,24}/*.treex.gz $(IN)/test
	# Na testy zatím nechat jen pár souborů, aby to bylo rychlejší.
	#ln -s $(SOURCEDIR)/tamw/train-1/ln94200_105.[tamw].gz $(IN)/train
	#ln -s $(SOURCEDIR)/tamw/dtest/ln94200_103.[tamw].gz $(IN)/dev
	#ln -s $(SOURCEDIR)/tamw/etest/ln94200_104.[tamw].gz $(IN)/test

SCHEMADIR=/net/work/people/zeman/treex/lib/Treex/Block/Read/PDT_schema
treex:
	rm -rf $(DIR0)/{train,dev,test}/*.treex*
	cp $(IN)/train/*.treex.gz $(DIR0)/train
	gunzip $(DIR0)/train/*.treex.gz
	cp $(IN)/dev/*.treex.gz $(DIR0)/dev
	gunzip $(DIR0)/dev/*.treex.gz
	cp $(IN)/test/*.treex.gz $(DIR0)/test
	gunzip $(DIR0)/test/*.treex.gz

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud_enhanced
	# Copy the new data to the Coref-UD project folder.
	cp /net/work/people/zeman/unidep/UD_$(UDNAME)/*.conllu /net/work/projects/corefud/data/cs-pcedt

# If we need to debug a specific error, we can process just one document
# instead of waiting hours for the whole corpus to compile.
DEBUGPART=test
DEBUGFILE=ln94205_91
udebug:
	$(TREEX) \
	    Read::Treex from='$(DIR1)/$(DEBUGPART)/$(DEBUGFILE).treex' \
	    A2A::CopyAtree source_selector='' selector='prague' \
	    T2A::GenerateA2TRefs \
	    HamleDT::Udep \
	    HamleDT::CS::SplitFusedWords \
	    HamleDT::CS::FixUD \
	    HamleDT::Punctuation \
	    A2A::CopyBasicToEnhancedUD \
	    T2A::GenerateEmptyNodes \
	    A2A::AddEnhancedUD \
	    A2A::CorefClusters \
	    A2A::RemoveUnusedEmptyNodes \
	    A2A::CorefMentions \
	    A2A::CorefMentionHeads \
	    Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR1)}{$(SUBDIRCU)} compress=1 \
	    Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR2)} compress=0
	zcat $(CONLLUDIR)/$(DEBUGPART)/$(DEBUGFILE).conllu.gz > /net/work/people/zeman/corefud/data/cs-pdt/$(DEBUGFILE).conllu
