LANGCODE=cs
TREEBANK=cs
UDCODE=cs_pdt
UDNAME=Czech-PDT
INPATTERN={train,dev,test}/{tamw,amw}/*.treex
HARMONIZE=Harmonize iset_driver=cs::pdtc
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords HamleDT::CS::FixUD
include ../common.mak
COREFUDDIR = /net/work/projects/corefud/data/cs-pdt

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

# ud should normally map either to prague_to_ud_enhanced, or to conllu_to_treex.
# We cannot run 'make prague_to_ud_enhanced' or 'make prague_tecto_to_ud_enhanced'
# from common.mak because the input path is different: extra /amw or /tamw.
ud: treex_a_to_ud treex_t_to_ud export
	# Copy the new data to the Coref-UD project folder. Exclude Vesmír from dev and test, it does not have t-layer and coreference.
	cat $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-train-[clm]t.conllu > $(COREFUDDIR)/$(UDCODE)-ud-train.conllu
	cat $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-dev.conllu  | udapy -s util.Filter keep_tree='not re.match(r"^vesm", tree.sent_id)' > $(COREFUDDIR)/$(UDCODE)-ud-dev.conllu
	cat $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-test.conllu | udapy -s util.Filter keep_tree='not re.match(r"^vesm", tree.sent_id)' > $(COREFUDDIR)/$(UDCODE)-ud-test.conllu

# Running ud_a would mean that we collect all data but use only the a-layer
# even where t-layer is avaliable, as we were doing it until UD v2.11.
ud_a: prague_to_ud_enhanced export

# CorefUD: Only update the tectogrammatical part in the main UD folder and
# copy the result to the folder where CorefUD data are collected.
corefud: treex_t_to_ud export
	# Copy the new data to the Coref-UD project folder. Exclude Vesmír from dev and test, it does not have t-layer and coreference.
	cat $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-train-[clm]t.conllu > $(COREFUDDIR)/$(UDCODE)-ud-train.conllu
	cat $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-dev.conllu  | udapy -s util.Filter keep_tree='not re.match(r"^vesm", tree.sent_id)' > $(COREFUDDIR)/$(UDCODE)-ud-dev.conllu
	cat $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-test.conllu | udapy -s util.Filter keep_tree='not re.match(r"^vesm", tree.sent_id)' > $(COREFUDDIR)/$(UDCODE)-ud-test.conllu

treex_a_to_ud:
	rm -rf $(DIR2)/{train,dev,test}/amw/*
	rm -rf $(CONLLUDIR)/{train,dev,test}/amw/*
	@echo `date` make prague anal to ud enhanced started | tee -a time.log
	$(QTREEX) \
	    Read::Treex from='!$(DIR1)/{train,dev,test}/amw/*.treex' \
	    $(SCEN2E) \
	    Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR1)}{$(SUBDIRCU)} compress=0 \
	    Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR2)} $(OUTCOMPRESS)
	@echo `date` treex ended | tee -a time.log

treex_t_to_ud:
	rm -rf $(DIR2)/{train,dev,test}/tamw/*
	rm -rf $(CONLLUDIR)/{train,dev,test}/tamw/*
	@echo `date` make prague tecto to ud enhanced started | tee -a time.log
	$(QTREEX) \
	    Read::Treex from='!$(DIR1)/{train,dev,test}/tamw/*.treex' \
	    $(SCEN2TE) \
	    Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR1)}{$(SUBDIRCU)} compress=0 \
	    Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR2)} $(OUTCOMPRESS)
	@echo `date` treex ended | tee -a time.log

# We need our own export (instead of default_ud_export) because PDT is large,
# its train portion must be split into several files, and we need specific
# post-processing, too.
###!!! We should get rid of corefud.FixInterleaved because it is possible to have legitimate interleaved same-entity mentions.
###!!! https://github.com/ufal/corefUD/issues/25#issuecomment-1386793600
UDAPISCEN = read.OldCorefUD corefud.FixInterleaved util.Eval node='for m in node.coref_mentions: m.head = m.words[0]' corefud.MoveHead ud.cs.FixEdeprels
export: ud_export default_ud_postprocessing

ud_export:
	@echo `date` cat train-c started | tee -a time.log
	cat $(CONLLUDIR)/train/tamw/cmpr*.conllu | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-ct.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-ct.conllu
	cat $(CONLLUDIR)/train/amw/cmpr*.conllu  | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-ca.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-ca.conllu
	@echo `date` cat train-l started | tee -a time.log
	cat $(CONLLUDIR)/train/tamw/ln*.conllu   | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-lt.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-lt.conllu
	cat $(CONLLUDIR)/train/amw/ln*.conllu    | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-la.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-la.conllu
	@echo `date` cat train-m started | tee -a time.log
	cat $(CONLLUDIR)/train/tamw/mf*.conllu   | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-mt.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-mt.conllu
	cat $(CONLLUDIR)/train/amw/mf*.conllu    | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-ma.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-ma.conllu
	@echo `date` cat train-v started | tee -a time.log
	# There is no -train-vt.conllu.
	cat $(CONLLUDIR)/train/amw/vesm*.conllu  | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-va.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-va.conllu
	@echo `date` cat dev started | tee -a time.log
	cat $(CONLLUDIR)/dev/tamw/*.conllu       | ../conllu_docpar_from_sentid.pl >  $(UDCODE)-ud-dev.conllu
	cat $(CONLLUDIR)/dev/amw/*.conllu        | ../conllu_docpar_from_sentid.pl >> $(UDCODE)-ud-dev.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-dev.conllu
	@echo `date` cat test started | tee -a time.log
	cat $(CONLLUDIR)/test/tamw/*.conllu      | ../conllu_docpar_from_sentid.pl >  $(UDCODE)-ud-test.conllu
	cat $(CONLLUDIR)/test/amw/*.conllu       | ../conllu_docpar_from_sentid.pl >> $(UDCODE)-ud-test.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-test.conllu
