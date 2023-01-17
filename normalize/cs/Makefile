LANGCODE=cs
TREEBANK=cs
UDCODE=cs_pdt
UDNAME=Czech-PDT
INPATTERN={train,dev,test}/{tamw,amw}/*.treex
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
# from common.mak because the input path is different: extra /amw or /tamw.
# When writing CoNLL-U files (not Treex files), we remove the /t?amw folder.
ud: treex_to_ud export

treex_to_ud:
	rm -rf $(DIR2)/{train,dev,test}/{tamw,amw}/*
	rm -rf $(CONLLUDIR)/{train,dev,test}/*
	@echo `date` make prague anal to ud enhanced started | tee -a time.log
	$(QTREEX) \
	    Read::Treex from='!$(DIR1)/{train,dev,test}/amw/*.treex' \
	    $(SCEN2E) \
	    Write::Treex substitute={$(SUBDIR1)}{$(SUBDIR2)} $(OUTCOMPRESS)
	@echo `date` make prague tecto to ud enhanced started | tee -a time.log
	$(QTREEX) \
	    Read::Treex from='!$(DIR1)/{train,dev,test}/tamw/*.treex' \
	    $(SCEN2TE) \
	    Write::Treex substitute={$(SUBDIR1)}{$(SUBDIR2)} $(OUTCOMPRESS)
	@echo `date` make export conllu started | tee -a time.log
	$(QTREEX) \
	    Read::Treex from='!$(DIR2)/{train,dev,test}/{tamw,amw}/*.treex' \
	    Write::CoNLLU print_zone_id=0 substitute='{$(SUBDIR2)/(train|dev|test)/t?amw/}{$(SUBDIRCU)/\1/}' compress=0
	@echo `date` treex ended | tee -a time.log

# We need our own export (instead of default_ud_export) because PDT is large,
# its train portion must be split into several files, and we need specific
# post-processing, too.
UDAPISCEN = read.OldCorefUD corefud.FixInterleaved util.Eval node='for m in node.coref_mentions: m.head = m.words[0]' corefud.MoveHead ud.cs.FixEdeprels
export:
	@echo `date` cat train-c started | tee -a time.log
	cat $(CONLLUDIR)/train/cmpr94*.conllu | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-c.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-c.conllu
	@echo `date` cat train-l started | tee -a time.log
	cat $(CONLLUDIR)/train/ln*.conllu     | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-l.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-l.conllu
	@echo `date` cat train-m started | tee -a time.log
	cat $(CONLLUDIR)/train/mf9*.conllu    | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-m.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-m.conllu
	@echo `date` cat train-v started | tee -a time.log
	cat $(CONLLUDIR)/train/vesm9*.conllu  | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-v.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-v.conllu
	@echo `date` cat dev started | tee -a time.log
	cat $(CONLLUDIR)/dev/*.conllu         | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-dev.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-dev.conllu
	@echo `date` cat test started | tee -a time.log
	cat $(CONLLUDIR)/test/*.conllu        | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-test.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-test.conllu
	@echo `date` check sentence ids started | tee -a time.log
	cat *.conllu | $(UDTOOLS)/check_sentence_ids.pl
	@echo `date` conllu stats started | tee -a time.log
	$(UDTOOLS)/conllu-stats.pl *.conllu > $(UDDIR)/UD_$(UDNAME)/stats.xml
	@echo `date` udapy mark bugs started | tee -a time.log
	cat *.conllu | udapy -HMAC ud.MarkBugs skip=no- > bugs.html
	@echo `date` udapy postprocessing started | tee -a time.log
	# Skip CoNLL-U files that have zero size (some treebanks lack train and dev).
	for i in *.conllu ; do if [ -s $$i ] ; then cp $$i $$i.debug ; udapy -s $(UDAPISCEN) < $$i > fixed.conllu ; mv fixed.conllu $$i ; mv $$i $(UDDIR)/UD_$(UDNAME) ; else rm $$i ; fi ; done
	@echo `date` validation started | tee -a time.log
	$(UDTOOLS)/validate.py --lang=$(LANGCODE) --coref $(UDDIR)/UD_$(UDNAME)/*.conllu
	@echo `date` export_ud.sh ended | tee -a time.log
