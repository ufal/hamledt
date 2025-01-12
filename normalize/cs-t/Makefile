LANGCODE=cs
TREEBANK=cs-t
UDCODE=cs_pdt
# Czech-PDTT is the same repo as Czech-PDT, but temporarily switched to the branch 'tecto'.
# We actually need to name the folder NonUD_Czech-PDTT rather than UD_Czech-PDTT because
# we want the UD release builder to ignore it. But common.mak is not prepared to do that,
# so we will have to rename the folder down here.
UDNAME=Czech-PDTT
HARMONIZE=HarmonizePDT iset_driver=cs::pdtc
PRE_UD_BLOCKS=T2A::GenerateA2TRefs
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords HamleDT::CS::FixUD
include ../common.mak

# Switching from PDT 3.5 to PDT-C.
#SOURCEDIR=/net/projects/pdt/pdt35/PDT3.5/data
SOURCEDIR=/net/data/pdt-c-1.0/data/PDT/pml
# subdirs: amw, tamw / train-[1-8] dtest etest / *.a.gz
source:
	mkdir -p data/source/train
	mkdir -p data/source/dev
	mkdir -p data/source/test
	ln -s $(SOURCEDIR)/tamw/train-[1-8]/*.[tamw].gz $(IN)/train
	ln -s $(SOURCEDIR)/tamw/dtest/*.[tamw].gz $(IN)/dev
	ln -s $(SOURCEDIR)/tamw/etest/*.[tamw].gz $(IN)/test

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
ud: prague_tecto_to_ud_enhanced
	# Use a NonUD* name for the target subfolder of unidep because the UD release builder must ignore it at the moment.
	mv /net/work/people/zeman/unidep/UD_$(UDNAME)/* /net/work/people/zeman/unidep/NonUD_$(UDNAME)
	rm -rf /net/work/people/zeman/unidep/UD_$(UDNAME)
	# Copy the new data to the Coref-UD project folder.
	cat /net/work/people/zeman/unidep/NonUD_$(UDNAME)/$(UDCODE)-ud-train-[clm].conllu > /net/work/projects/corefud/data/cs-pdt/$(UDCODE)-ud-train.conllu
	cp /net/work/people/zeman/unidep/NonUD_$(UDNAME)/$(UDCODE)-ud-dev.conllu /net/work/projects/corefud/data/cs-pdt
	cp /net/work/people/zeman/unidep/NonUD_$(UDNAME)/$(UDCODE)-ud-test.conllu /net/work/projects/corefud/data/cs-pdt

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

# Generate valency frames with effective children for Kira.
# First option: read directly PDT data. But then the printed ords and lemmas will not correspond to Universal Dependencies.
#     Read::PDT schema_dir=$(SCHEMADIR) top_layer=t from='!$(IN)/{train,dev,test}/*.t.gz'
# Second option: read the data converted to UD. Tectogrammatical trees and their correspondence to a-nodes should still hold but the a-trees are in UD style.
#     Read::Treex from='!$(DIR2)/{train,dev,test}/*.treex'
frames_for_kira:
	$(QTREEX) \
	    Read::Treex from='!$(DIR2)/{train,dev,test}/*.treex' \
	    Print::ValencyFramesForKira | tee frames.txt
