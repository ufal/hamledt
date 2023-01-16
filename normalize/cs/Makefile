LANGCODE=cs
TREEBANK=cs
UDCODE=cs_pdt
UDNAME=Czech-PDT
HARMONIZE=Harmonize iset_driver=cs::pdtc
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords HamleDT::CS::FixUD
include ../common.mak

# Switching from PDT 3.0 to PDT-C.
#SOURCEDIR=/net/projects/pdt/pdt30/data
#SOURCEDIR=/net/projects/pdt/pdt35/PDT3.5/data
SOURCEDIR=/net/data/pdt-c-1.0/data/PDT/pml
# subdirs: amw, tamw / train-[1-8] dtest etest / *.a.gz
source_a:
	mkdir -p data/source/train
	mkdir -p data/source/dev
	mkdir -p data/source/test
	ln -s $(SOURCEDIR)/{tamw,amw}/train-[1-8]/*.[amw].gz $(IN)/train
	ln -s $(SOURCEDIR)/{tamw,amw}/dtest/*.[amw].gz $(IN)/dev
	ln -s $(SOURCEDIR)/{tamw,amw}/etest/*.[amw].gz $(IN)/test

source_mix:
	mkdir -p data/source/train/tamw
	mkdir -p data/source/dev/tamw
	mkdir -p data/source/test/tamw
	ln -s $(SOURCEDIR)/tamw/train-[1-8]/*.[tamw].gz $(IN)/train/tamw
	ln -s $(SOURCEDIR)/tamw/dtest/*.[tamw].gz $(IN)/dev/tamw
	ln -s $(SOURCEDIR)/tamw/etest/*.[tamw].gz $(IN)/test/tamw
	mkdir -p data/source/train/amw
	mkdir -p data/source/dev/amw
	mkdir -p data/source/test/amw
	ln -s $(SOURCEDIR)/amw/train-[1-8]/*.[amw].gz $(IN)/train/amw
	ln -s $(SOURCEDIR)/amw/dtest/*.[amw].gz $(IN)/dev/amw
	ln -s $(SOURCEDIR)/amw/etest/*.[amw].gz $(IN)/test/amw

#SCHEMADIR=$(TMT_ROOT)/treex/lib/Treex/Block/Read/PDT_schema
SCHEMADIR=/net/work/people/zeman/treex/lib/Treex/Block/Read/PDT_schema
treex_a:
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/train/*.a.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/dev/*.a.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/test/*.a.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/  compress=0

treex_mix:
	rm -rf $(DIR0)/{train,dev,test}/*
	mkdir -p $(DIR0)/train/tamw
	mkdir -p $(DIR0)/dev/tamw
	mkdir -p $(DIR0)/test/tamw
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=t from='!$(IN)/train/tamw/*.t.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/tamw/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=t from='!$(IN)/dev/tamw/*.t.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/tamw/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=t from='!$(IN)/test/tamw/*.t.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/tamw/  compress=0
	mkdir -p $(DIR0)/train/amw
	mkdir -p $(DIR0)/dev/amw
	mkdir -p $(DIR0)/test/amw
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/train/amw/*.a.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/amw/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/dev/amw/*.a.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/amw/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/test/amw/*.a.gz' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/amw/  compress=0

# We cannot run 'make prague' from common.mak because the input path is different.
prague_mix:
	$(QTREEX) $(SCEN1) Write::Treex substitute={00}{01} compress=0 -- '!$(DIR0)/{train,dev,test}/{tamw,amw}/*.treex'

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud_a: prague_to_ud_enhanced

ud_t: prague_tecto_to_ud_enhanced
	# Use a NonUD* name for the target subfolder of unidep because the UD release builder must ignore it at the moment.
	mv /net/work/people/zeman/unidep/UD_$(UDNAME)/* /net/work/people/zeman/unidep/NonUD_$(UDNAME)
	rm -rf /net/work/people/zeman/unidep/UD_$(UDNAME)
	# Copy the new data to the Coref-UD project folder.
	cat /net/work/people/zeman/unidep/NonUD_$(UDNAME)/$(UDCODE)-ud-train-[clm].conllu > /net/work/projects/corefud/data/cs-pdt/$(UDCODE)-ud-train.conllu
	cp /net/work/people/zeman/unidep/NonUD_$(UDNAME)/$(UDCODE)-ud-dev.conllu /net/work/projects/corefud/data/cs-pdt
	cp /net/work/people/zeman/unidep/NonUD_$(UDNAME)/$(UDCODE)-ud-test.conllu /net/work/projects/corefud/data/cs-pdt

# We cannot run 'make prague_to_ud_enhanced' or 'make prague_tecto_to_ud_enhanced'
# from common.mak because the input path is different.
ud_mix:
	@echo `date` make prague to ud enhanced started | tee -a time.log
	$(QTREEX) \
	    Read::Treex from='!$(DIR1)/{train,dev,test}/*.treex' \
	    $(SCEN2) \
	    A2A::CopyBasicToEnhancedUD \
	    A2A::AddEnhancedUD \
	    Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR1)}{$(SUBDIRCU)} compress=0 \
	    Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR2)} compress=0
	../export_ud.sh $(LANGCODE) $(UDCODE) $(UDNAME)
	@echo `date` make prague to ud enhanced started | tee -a time.log
	$(QTREEX) \
	    Read::Treex from='!$(DIR1)/{train,dev,test}/*.treex' \
	    $(SCEN2) \
	    A2A::CopyBasicToEnhancedUD \
	    T2A::GenerateEmptyNodes \
	    A2A::AddEnhancedUD \
	    A2A::CorefClusters \
	    A2A::RemoveUnusedEmptyNodes \
	    A2A::CorefMentions \
	    Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR1)}{$(SUBDIRCU)} compress=0 \
	    Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR2)} compress=0
	../export_ud.sh $(LANGCODE) $(UDCODE) $(UDNAME)
