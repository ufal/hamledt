LANGCODE=cs
TREEBANK=cs-pcedt
UDCODE=cs_pcedt
UDNAME=Czech-PCEDT
HARMONIZE=Harmonize iset_driver=cs::pdtc
PRE_UD_BLOCKS=T2A::GenerateA2TRefs
# Due to errors in the original annotation, some instances of coordination could not be converted
# and the relation stayed labeled 'coord', which is invalid in Universal Dependencies. Get rid of them.
POST_UD_BLOCKS=Util::Eval anode='if($$.deprel() eq "coord") {$$.set_deprel("dep");}' HamleDT::CS::SplitFusedWords HamleDT::CS::FixUD
include ../common.mak

# An updated version of the Czech part of PCEDT 2.0 has been published as part of PDT-C 1.0.
#SOURCEDIR=/net/data/pcedt2.0/data
SOURCEDIR=/net/data/pdt-c-1.0/data/PCEDT/treex
# subdirs: 00-24
source:
	mkdir -p data/source/train
	mkdir -p data/source/dev
	mkdir -p data/source/test
	ln -s $(SOURCEDIR)/wsj{0[2-9],1[0-9],2[01]}[0-9][0-9].cz.treex.gz $(IN)/train
	ln -s $(SOURCEDIR)/wsj{00,01,22,24}[0-9][0-9].cz.treex.gz $(IN)/dev
	ln -s $(SOURCEDIR)/wsj23[0-9][0-9].cz.treex.gz $(IN)/test
	for i in $(IN)/train/*.cz.treex.gz ; do mv $$i $(IN)/train/`basename $$i .cz.treex.gz`.treex.gz ; done
	for i in $(IN)/dev/*.cz.treex.gz ; do mv $$i $(IN)/dev/`basename $$i .cz.treex.gz`.treex.gz ; done
	for i in $(IN)/test/*.cz.treex.gz ; do mv $$i $(IN)/test/`basename $$i .cz.treex.gz`.treex.gz ; done

SCHEMADIR=/net/work/people/zeman/treex/lib/Treex/Block/Read/PDT_schema
treex:
	rm -rf $(DIR0)/{train,dev,test}/*.treex*
	cp $(IN)/train/*.treex.gz $(DIR0)/train
	gunzip $(DIR0)/train/*.treex.gz
	cp $(IN)/dev/*.treex.gz $(DIR0)/dev
	gunzip $(DIR0)/dev/*.treex.gz
	cp $(IN)/test/*.treex.gz $(DIR0)/test
	gunzip $(DIR0)/test/*.treex.gz

# ud should map either to prague_(tecto_)to_ud(_enhanced), or to conllu_to_treex.
ud: prague_tecto_to_ud_enhanced export
	# Copy the new data to the Coref-UD project folder.
	cp /net/work/people/zeman/unidep/UD_$(UDNAME)/*.conllu /net/work/projects/corefud/data/cs-pcedt

# We need our own export (instead of default_ud_export) because PDT is large,
# its train portion must be split into several files, and we need specific
# post-processing, too.
###!!! We should get rid of corefud.FixInterleaved because it is possible to have legitimate interleaved same-entity mentions.
###!!! https://github.com/ufal/corefUD/issues/25#issuecomment-1386793600
UDAPISCEN = read.OldCorefUD corefud.FixInterleaved util.Eval node='for m in node.coref_mentions: m.head = m.words[0]' corefud.MoveHead ud.cs.FixEdeprels
export: ud_export default_ud_postprocessing

ud_export:
	@echo `date` cat train started | tee -a time.log
	cat data/conllu/train/*.conllu | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train.conllu
	@echo `date` cat dev started | tee -a time.log
	cat data/conllu/dev/*.conllu   | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-dev.conllu
	@echo `date` cat test started | tee -a time.log
	cat data/conllu/test/*.conllu  | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-test.conllu

# If we need to debug a specific error, we can process just one document
# instead of waiting hours for the whole corpus to compile.
DEBUGPART=train
DEBUGFILE=wsj1057
###!!! Za CS::FixUD zkouším vynechat HamleDT::Punctuation.
udebug:
	$(TREEX) \
	    Read::Treex from='$(DIR1)/$(DEBUGPART)/$(DEBUGFILE).treex' \
	    A2A::CopyAtree source_selector='' selector='prague' \
	    T2A::GenerateA2TRefs \
	    HamleDT::Udep \
	    Util::Eval anode='if($$.deprel() eq "coord") {$$.set_deprel("dep");}' \
	    HamleDT::CS::SplitFusedWords \
	    HamleDT::CS::FixUD \
	    A2A::CopyBasicToEnhancedUD \
	    T2A::GenerateEmptyNodes \
	    A2A::AddEnhancedUD \
	    A2A::CorefClusters \
	    A2A::RemoveUnusedEmptyNodes \
	    A2A::CorefMentions \
	    A2A::CorefMentionHeads \
	    Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR1)}{$(SUBDIRCU)} compress=0 \
	    Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR2)} compress=0
	validate.py --level 2 --lang $(LANGCODE) $(CONLLUDIR)/$(DEBUGPART)/$(DEBUGFILE).conllu
	#cp $(CONLLUDIR)/$(DEBUGPART)/$(DEBUGFILE).conllu /net/work/people/zeman/corefud/data/cs-pcedt/$(DEBUGFILE).conllu
