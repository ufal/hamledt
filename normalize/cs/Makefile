LANGCODE=cs
TREEBANK=cs
UDCODE=cs_pdtc
UDNAME=Czech-PDTC
INPATTERN={train,dev,test}/{tamw,amw}/*.treex
###!!! PRE_PRAGUE_BLOCKS are needed temporarily until we run make treex next time because then the block will be applied there.
PRE_PRAGUE_BLOCKS=HamleDT::CS::SetBundleId
HARMONIZE=HarmonizePDTC iset_driver=cs::pdtc
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords HamleDT::CS::FixUD
include ../common.mak
COREFUDDIR = /net/work/projects/corefud/data/cs-pdt

SOURCEDIR=/net/work/people/zeman/PDT-C-2.0

source:
	mkdir -p data/source/train/tamw
	mkdir -p data/source/dev/tamw
	mkdir -p data/source/test/tamw
	ln -s $(SOURCEDIR)/PDT/pml/tamw/train-[1-8]/*.[tamw] $(IN)/train/tamw
	ln -s $(SOURCEDIR)/PDT/pml/tamw/dtest/*.[tamw] $(IN)/dev/tamw
	ln -s $(SOURCEDIR)/PDT/pml/tamw/etest/*.[tamw] $(IN)/test/tamw
	ln -s $(SOURCEDIR)/Faust/pml/train/*.[tamw] $(IN)/train/tamw
	ln -s $(SOURCEDIR)/Faust/pml/dtest/*.[tamw] $(IN)/dev/tamw
	ln -s $(SOURCEDIR)/Faust/pml/etest/*.[tamw] $(IN)/test/tamw
	ln -s $(SOURCEDIR)/PDTSC/pml/train/*.[tamw] $(IN)/train/tamw
	ln -s $(SOURCEDIR)/PDTSC/pml/dtest/*.[tamw] $(IN)/dev/tamw
	ln -s $(SOURCEDIR)/PDTSC/pml/etest/*.[tamw] $(IN)/test/tamw
	ln -s $(SOURCEDIR)/PCEDT-cz/pml/train/*.[tamw] $(IN)/train/tamw
	ln -s $(SOURCEDIR)/PCEDT-cz/pml/dtest/*.[tamw] $(IN)/dev/tamw
	ln -s $(SOURCEDIR)/PCEDT-cz/pml/etest/*.[tamw] $(IN)/test/tamw
	mkdir -p data/source/train/amw
	mkdir -p data/source/dev/amw
	mkdir -p data/source/test/amw
	ln -s $(SOURCEDIR)/PDT/pml/amw/train-[1-8]/*.[amw] $(IN)/train/amw
	ln -s $(SOURCEDIR)/PDT/pml/amw/dtest/*.[amw] $(IN)/dev/amw
	ln -s $(SOURCEDIR)/PDT/pml/amw/etest/*.[amw] $(IN)/test/amw

SCHEMADIR=/net/work/people/zeman/treex/lib/Treex/Block/Read/PDT_schema

treex:
	rm -rf $(DIR0)/{train,dev,test}/*
	mkdir -p $(DIR0)/train/tamw
	mkdir -p $(DIR0)/dev/tamw
	mkdir -p $(DIR0)/test/tamw
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=t from='!$(IN)/train/tamw/*.t' \
		HamleDT::CS::SetBundleId \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/tamw/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=t from='!$(IN)/dev/tamw/*.t' \
		HamleDT::CS::SetBundleId \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/tamw/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=t from='!$(IN)/test/tamw/*.t' \
		HamleDT::CS::SetBundleId \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/tamw/  compress=0
	mkdir -p $(DIR0)/train/amw
	mkdir -p $(DIR0)/dev/amw
	mkdir -p $(DIR0)/test/amw
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/train/amw/*.a' \
		HamleDT::CS::SetBundleId \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/amw/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/dev/amw/*.a' \
		HamleDT::CS::SetBundleId \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/amw/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/test/amw/*.a' \
		HamleDT::CS::SetBundleId \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/amw/  compress=0

# ud should normally map either to prague_to_ud_enhanced, or to conllu_to_treex.
# We cannot run 'make prague_to_ud_enhanced' or 'make prague_tecto_to_ud_enhanced'
# from common.mak because the input path is different: extra /amw or /tamw.
ud: treex_a_to_ud treex_t_to_ud export
	# Copy the new data to the Coref-UD project folder. Exclude sentences that do not have t-layer and coreference.
	cat $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-train-[clmfs]t.conllu | udapy -s util.Filter keep_tree='"Tectogrammatical annotation available." in [re.sub(r"^ +", r"", c) for c in tree.comment.split("\n")]' > $(COREFUDDIR)/$(UDCODE)-corefud-train.conllu
	cat $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-dev.conllu          | udapy -s util.Filter keep_tree='"Tectogrammatical annotation available." in [re.sub(r"^ +", r"", c) for c in tree.comment.split("\n")]' > $(COREFUDDIR)/$(UDCODE)-corefud-dev.conllu
	cat $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-test.conllu         | udapy -s util.Filter keep_tree='"Tectogrammatical annotation available." in [re.sub(r"^ +", r"", c) for c in tree.comment.split("\n")]' > $(COREFUDDIR)/$(UDCODE)-corefud-test.conllu

# Running ud_a would mean that we collect all data but use only the a-layer
# even where t-layer is avaliable, as we were doing it until UD v2.11.
ud_a: prague_to_ud_enhanced export

# CorefUD: Only update the tectogrammatical part in the main UD folder and
# copy the result to the folder where CorefUD data are collected.
corefud: treex_t_to_ud export
	# Copy the new data to the Coref-UD project folder. Exclude sentences that do not have t-layer and coreference.
	cat $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-train-[clmfs]t.conllu | udapy -s util.Filter keep_tree='"Tectogrammatical annotation available." in [re.sub(r"^ +", r"", c) for c in tree.comment.split("\n")]' > $(COREFUDDIR)/$(UDCODE)-corefud-train.conllu
	cat $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-dev.conllu          | udapy -s util.Filter keep_tree='"Tectogrammatical annotation available." in [re.sub(r"^ +", r"", c) for c in tree.comment.split("\n")]' > $(COREFUDDIR)/$(UDCODE)-corefud-dev.conllu
	cat $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-test.conllu         | udapy -s util.Filter keep_tree='"Tectogrammatical annotation available." in [re.sub(r"^ +", r"", c) for c in tree.comment.split("\n")]' > $(COREFUDDIR)/$(UDCODE)-corefud-test.conllu

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
UDAPISCEN = read.OldCorefUD util.Eval node='for m in node.coref_mentions: m.head = m.words[0]' corefud.MoveHead corefud.FixParentheses ud.cs.FixEdeprels
export: ud_export default_ud_postprocessing

ud_export:
	# If there is any debug file from previous runs in the target folder, it must be removed before we count any statistics.
	rm -f $(UDDIR)/UD_$(UDNAME)/$(UDCODE)-ud-debug.conllu
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
	@echo `date` cat train-f started | tee -a time.log
	cat $(CONLLUDIR)/train/tamw/faust*.conllu   | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-ft.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-ft.conllu
	@echo `date` cat train-s started | tee -a time.log
	cat $(CONLLUDIR)/train/tamw/pdtsc*.conllu   | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-st.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-st.conllu
	@echo `date` cat train-w started | tee -a time.log
	cat $(CONLLUDIR)/train/tamw/wsj0*.conllu | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-wt0.conllu
	cat $(CONLLUDIR)/train/tamw/wsj1*.conllu | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-wt1.conllu
	cat $(CONLLUDIR)/train/tamw/wsj2*.conllu | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train-wt2.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-wt0.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-wt1.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train-wt2.conllu
	@echo `date` cat dev started | tee -a time.log
	cat $(CONLLUDIR)/dev/tamw/*.conllu       | ../conllu_docpar_from_sentid.pl >  $(UDCODE)-ud-dev.conllu
	cat $(CONLLUDIR)/dev/amw/*.conllu        | ../conllu_docpar_from_sentid.pl >> $(UDCODE)-ud-dev.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-dev.conllu
	@echo `date` cat test started | tee -a time.log
	cat $(CONLLUDIR)/test/tamw/*.conllu      | ../conllu_docpar_from_sentid.pl >  $(UDCODE)-ud-test.conllu
	cat $(CONLLUDIR)/test/amw/*.conllu       | ../conllu_docpar_from_sentid.pl >> $(UDCODE)-ud-test.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-test.conllu

# Complete make ud for the whole PDT takes more than 30 minutes and is not practical if we need to debug conversion of a single sentence.
# Here we can run conversion for just one file (the analytical scenario; for the tectogrammatical one, see below).
# It should be possible to override the following variables and specify the file to debug directly on the commandline:
# DEBUGAPART=train DEBUGAFILE=vesm9301_013 make debug_a
DEBUGAPART ?= train
DEBUGAFILE ?= vesm9301_013
debug_a:
	@echo `date` make prague to hamledt started for $(DEBUGAFILE) | tee -a time.log
	$(TREEX) \
	    Read::Treex from='!$(DIR0)/$(DEBUGAPART)/amw/$(DEBUGAFILE).treex' \
	    $(SCEN1) \
	    Write::Treex substitute={00}{01} $(OUTCOMPRESS)
	@echo `date` make prague to ud enhanced started for $(DEBUGAFILE) | tee -a time.log
	$(TREEX) \
	    Read::Treex from='!$(DIR1)/$(DEBUGAPART)/amw/$(DEBUGAFILE).treex' \
	    $(SCEN2E) \
	    Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR1)}{$(SUBDIRCU)} compress=0 \
	    Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR2)} $(OUTCOMPRESS)
	@echo `date` treex ended | tee -a time.log
	@echo `date` cat started | tee -a time.log
	cat $(CONLLUDIR)/$(DEBUGAPART)/amw/$(DEBUGAFILE).conllu | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-debug.conllu
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

# Complete make ud for the whole PDT takes more than 30 minutes and is not practical if we need to debug conversion of a single sentence.
# Here we can run conversion for just one file (the tectogrammatical scenario; for the analytical one, see above).
# It should be possible to override the following variables and specify the file to debug directly on the commandline:
# DEBUGTPART=train DEBUGTFILE=mf920922_090 make debug_t
# DEBUGTPART=train DEBUGTFILE=cmpr9410_001 make debug_t 1>debug.log 2>&1
DEBUGTPART ?= train
DEBUGTFILE ?= mf920922_090
debug_t:
	@echo `date` make prague to hamledt started for $(DEBUGTFILE) | tee -a time.log
	$(TREEX) \
	    Read::Treex from='!$(DIR0)/$(DEBUGTPART)/tamw/$(DEBUGTFILE).treex' \
	    $(SCEN1) \
	    Write::Treex substitute={00}{01} $(OUTCOMPRESS)
	@echo `date` make prague tecto to ud enhanced started for $(DEBUGTFILE) | tee -a time.log
	$(TREEX) \
	    Read::Treex from='!$(DIR1)/$(DEBUGTPART)/tamw/$(DEBUGTFILE).treex' \
	    $(SCEN2TE) \
	    Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR1)}{$(SUBDIRCU)} compress=0 \
	    Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR2)} $(OUTCOMPRESS)
	@echo `date` treex ended | tee -a time.log
	@echo `date` cat started | tee -a time.log
	cat $(CONLLUDIR)/$(DEBUGTPART)/tamw/$(DEBUGTFILE).conllu | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-debug.conllu
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
	@echo https://ufallab.ms.mff.cuni.cz/~zeman/debug.html
