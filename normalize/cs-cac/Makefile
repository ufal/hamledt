LANGCODE=cs
TREEBANK=cs-cac
UDCODE=cs_cac
UDNAME=Czech-CAC
HARMONIZE=HarmonizePDT iset_driver=cs::pdt
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords HamleDT::CS::FixUD
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
ud: prague_to_ud_enhanced export

# We need our own export because we need specific post-processing.
UDAPISCEN=ud.cs.FixEdeprels
export: ud_export default_ud_postprocessing

ud_export:
	@echo `date` cat train started | tee -a time.log
	cat $(CONLLUDIR)/train/*.conllu | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train.conllu
	@echo `date` cat dev started | tee -a time.log
	cat $(CONLLUDIR)/dev/*.conllu | ../conllu_docpar_from_sentid.pl >  $(UDCODE)-ud-dev.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-dev.conllu
	@echo `date` cat test started | tee -a time.log
	cat $(CONLLUDIR)/test/*.conllu | ../conllu_docpar_from_sentid.pl >> $(UDCODE)-ud-test.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-test.conllu

# Complete make ud for the whole corpus is not practical if we need to debug conversion of a single sentence.
# Here we can run conversion for just one file.
# It should be possible to override the following variables and specify the file to debug directly on the commandline:
# DEBUGAPART=dev DEBUGAFILE=a10w make debug
DEBUGAPART ?= dev
DEBUGAFILE ?= a10w
debug:
	@echo `date` make prague to hamledt started for $(DEBUGAFILE) | tee -a time.log
	$(TREEX) \
	    Read::Treex from='!$(DIR0)/$(DEBUGAPART)/$(DEBUGAFILE).treex' \
	    A2A::CopyAtree source_selector='' selector='orig' \
	    HamleDT::$(UCLANG)::$(HARMONIZE) \
	    Write::Treex substitute={00}{01} $(OUTCOMPRESS)
	@echo `date` make prague to ud enhanced started for $(DEBUGAFILE) | tee -a time.log
	$(TREEX) \
	    Read::Treex from='!$(DIR1)/$(DEBUGAPART)/$(DEBUGAFILE).treex' \
	    $(SCEN2E) \
	    Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR1)}{$(SUBDIRCU)} compress=0 \
	    Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR2)} $(OUTCOMPRESS)
	@echo `date` treex ended | tee -a time.log
	@echo `date` cat started | tee -a time.log
	cat $(CONLLUDIR)/$(DEBUGAPART)/$(DEBUGAFILE).conllu | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-debug.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-debug.conllu
	# The following is adapted from the common target default_ud_postprocessing.
	@echo `date` udapy postprocessing started | tee -a time.log
	# Skip CoNLL-U files that have zero size (some treebanks lack train and dev).
	for i in $(UDCODE)-ud-debug.conllu ; do if [ -s $$i ] ; then cp $$i $$i.debug ; udapy -s $(UDAPISCEN) < $$i > fixed.conllu ; kod=$$? ; if [[ "$$kod" == "0" ]] ; then mv fixed.conllu $$i && mv $$i $(UDDIR)/UD_$(UDNAME) ; else break ; fi ; else rm $$i ; fi ; done ; if [[ "$$kod" != "0" ]] ; then false ; fi 2>&1 | tee udapi.log ; if [[ "$${PIPESTATUS[0]}" != "0" ]] ; then echo ERROR $$kod ; false ; fi
	@echo `date` udapy mark bugs started | tee -a time.log
	cat $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-debug.conllu | udapy -HMAC ud.MarkBugs skip=no- > bugs.html
	@echo `date` check sentence ids started | tee -a time.log
	cat $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-debug.conllu | $(UDTOOLS)/check_sentence_ids.pl
	@echo `date` validation started | tee -a time.log
	$(UDTOOLS)/validate.py --lang=$(LANGCODE) --coref $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-debug.conllu 2>&1 | tee validation.log
	@echo `date` export_ud.sh ended | tee -a time.log
	# Visualize coreference to facilitate debugging.
	udapy write.CorefHtml < $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-debug.conllu > ~/public_html/debug.html
