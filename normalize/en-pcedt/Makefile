LANGCODE=en
TREEBANK=en-pcedt
UDCODE=en_pcedt
UDNAME=English-PCEDT
HARMONIZE=HarmonizePCEDT
PRE_UD_BLOCKS=T2A::GenerateA2TRefs
include ../common.mak

# Michal Novák: Co sa tyka anglicke, najnovsia nepracovna verzia je v PCEDT 2.0 Coref.
# V medzicase ale pracujeme na release PCEDT 3.0, takze ak raz budeme moct vydat aj anglicku stranu, moze sa pouzit uz ta z PCEDT 3.0.
#SOURCEDIR=/net/data/pcedt2.0/data
SOURCEDIR=/net/data/pcedt2.0-coref/data
# subdirs: 00-24
source:
	mkdir -p data/source/train
	mkdir -p data/source/dev
	mkdir -p data/source/test
	ln -s $(SOURCEDIR)/{0[2-9],1[0-9],2[01]}/*.treex.gz $(IN)/train
	ln -s $(SOURCEDIR)/{00,01,22,24}/*.treex.gz $(IN)/dev
	ln -s $(SOURCEDIR)/23/*.treex.gz $(IN)/test

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
	cp /net/work/people/zeman/unidep/UD_$(UDNAME)/*.conllu /net/work/projects/corefud/data/en-pcedt

# We need our own export (instead of default_ud_export) because PDT is large,
# its train portion must be split into several files, and we need specific
# post-processing, too.
###!!! We should get rid of corefud.FixInterleaved because it is possible to have legitimate interleaved same-entity mentions.
###!!! https://github.com/ufal/corefUD/issues/25#issuecomment-1386793600
UDAPISCEN = read.OldCorefUD corefud.FixInterleaved util.Eval node='for m in node.coref_mentions: m.head = m.words[0]' corefud.MoveHead
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
