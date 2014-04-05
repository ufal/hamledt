SHELL=/bin/bash

# To be included from the language-specific makefiles like this:
# include ../common.mak
# The language-specific makefile should define two environment variables:
# LANGCODE=cs # Czech
# TREEBANK=cs-pdt30 # either same as language code, or with hyphen and lowercase treebank code; will be used in paths
# HARMONIZE=HarmonizeSpecial # only needed if not called Harmonize; will be sought for in the $(LANGCODE) folder.

# Set paths. The main path, TMT_ROOT, must be pre-set in your environment.
# You may want to put something like this in your .bash_profile, depending on where your copy of TectoMT is:
# export TMT_ROOT=/net/work/people/zeman/tectomt
DATADIR  = $(TMT_ROOT)/share/data/resources/hamledt/$(TREEBANK)
SUBDIRIN = source
SUBDIR0  = treex/000_orig
SUBDIR1  = treex/001_pdtstyle
SUBDIRC  = conll
SUBDIRJ  = jo
SUBDIRS  = stanford
IN       = $(DATADIR)/$(SUBDIRIN)
DIR0     = $(DATADIR)/$(SUBDIR0)
DIR1     = $(DATADIR)/$(SUBDIR1)
CONLLDIR = $(DATADIR)/$(SUBDIRC)
JODIR    = $(DATADIR)/$(SUBDIRJ)
STANDIR  = $(DATADIR)/$(SUBDIRS)

# Processing shortcuts.
TREEX      = treex -p --jobs 50 -L$(LANGCODE)
IMPORT     = Read::CoNLLX lines_per_doc=500
WRITE0     = Write::Treex file_stem='' clobber=1
WRITE      = Write::Treex clobber=1
# Treebank-specific Makefiles must override the value of HARMONIZE if their harmonization block is not called Harmonize.
# They must do so before they include common.mak.
HARMONIZE ?= Harmonize
TRAIN      = $(IN)/train.conll
TEST       = $(IN)/test.conll
POSTPROCESS1_SCEN_OPT :=
POSTPROCESS2_SCEN_OPT :=

check-source:
	[ -d $(IN) ] || (echo new $(LANGCODE) && make source)

dirs:
	@echo The root data directory for $(TREEBANK): $(DATADIR)
	mkdir -p $(DATADIR)
	if [ ! -e data ]; then ln -s $(DATADIR) data; fi
	mkdir -p data/$(SUBDIRIN)
	mkdir -p data/{$(SUBDIR0),$(SUBDIR1)}/{train,test}
	chmod -R g+w data/. data/*

# Run a conversion of the original data into the treex format
# and store the results in 000_orig. This default assumes CoNLL-X,
# our most-widely used source format. If a different conversion
# is needed, override in the language-specific Makefile.
# Otherwise, define the language-specific "treex" goal as dependent
# on "conll_to_treex".
conll_to_treex:
	$(TREEX) $(IMPORT) from=$(IN)/train.conll $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORT) from=$(IN)/test.conll  $(WRITE0) path=$(DIR0)/test/

# Make the trees as similar to the PDT-style as possible
# and store the result in 001_pdtstyle.
UCLANG = $(shell perl -e 'print uc("$(LANGCODE)");')
SCEN1 = HamleDT::$(UCLANG)::$(HARMONIZE)

pdt:
	$(TREEX) $(SCEN1) Write::Treex substitute={000_orig}{001_pdtstyle} -- '!$(DIR0)/{train,test}/*.treex.gz'

# This goal serves development and debugging of the Harmonize block.
# Smaller data are processed faster.
# $(TREEX) is not used because we do not want to parallelize the task on the cluster.
# (By default, copies of logs from parallel jobs lack the TREEX-INFO level.)
test:
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test -- '!$(DIR0)/test/*.treex.gz'

# This goal exports the harmonized trees in CoNLL format, which is more useful for ordinary users.
CONLL_ATTRIBUTES = selector= deprel_attribute=afun is_member_within_afun=1 pos_attribute=tag feat_attribute=iset
export_conll:
	$(TREEX) Read::Treex from='!$(DIR1)/train/*.treex.gz' Write::CoNLLX $(CONLL_ATTRIBUTES) path=$(CONLLDIR)/train clobber=1 compress=1
	$(TREEX) Read::Treex from='!$(DIR1)/test/*.treex.gz' Write::CoNLLX $(CONLL_ATTRIBUTES) path=$(CONLLDIR)/test clobber=1 compress=1

# TODO: other structure changes (compound verbs)
# TODO: often fails because there remain some punct nodes with children
TO_STANFORD=\
			A2A::CopyAtree source_selector='' selector=pdt \
			Util::Eval anode='$$anode->set_conll_deprel('');' \
			HamleDT::Transform::SubordConjDownward \
			A2A::SetSharedModifier \
			A2A::SetCoordConjunction \
			HamleDT::Transform::PrepositionDownward \
			HamleDT::Transform::CoordStyle from_style=fPhRsHcHpB style=fShLsHcBpB \
			HamleDT::Transform::MarkPunct \
			HamleDT::Transform::StanfordPunct \
			HamleDT::Transform::StanfordTypes \
			HamleDT::Transform::StanfordCopulas \
			HamleDT::SetConllTags features=subpos,prontype,numtype,advtype,punctype,tense,verbform \
			Util::Eval anode='$$anode->set_afun('');'
# This is for TrEd to display the newly set conll/deprels instead of afuns.

WRITE_STANFORD=Util::SetGlobal substitute={$(SUBDIR1)}{$(SUBDIRS)} clobber=1 \
	Write::Treex \
	Write::Stanford type_attribute=conll/deprel to=. \
	Write::CoNLLX deprel_attribute=conll/deprel pos_attribute=conll/pos cpos_attribute=conll/cpos feat_attribute=iset to=.

STANFORD=$(TO_STANFORD) $(WRITE_STANFORD)

treex_to_stanford:
	$(TREEX) $(STANFORD) -- $(DIR1)/train/*.treex.gz
	$(TREEX) $(STANFORD) -- $(DIR1)/test/*.treex.gz

treex_to_stanford_test:
	$(TREEX) $(STANFORD) -- $(DIR1)/test/*.treex.gz

# Joachim Daiber needs prepositions as leaves attached to their noun.
# He does not want the Stanford style though. Everything else should be standard Prague.
TGZJO = hamledt_2.0jo_$(TREEBANK)_conll.tgz
jo:
	$(TREEX) \
		Read::Treex from='!$(DIR1)/train/*.treex.gz' \
		HamleDT::Transform::PrepositionDownward \
		Write::CoNLLX $(CONLL_ATTRIBUTES) path=$(JODIR)/train clobber=1 compress=0
	$(TREEX) \
		Read::Treex from='!$(DIR1)/test/*.treex.gz' \
		HamleDT::Transform::PrepositionDownward \
		Write::CoNLLX $(CONLL_ATTRIBUTES) path=$(JODIR)/test clobber=1 compress=0
	tar czf $(TGZJO) -P --xform s-$(TMT_ROOT)/share/data/resources/hamledt/-- $(JODIR)/*
	scp $(TGZJO) ufal.mff.cuni.cz:/home/zeman/www/soubory/$(TGZJO)
	# wget http://ufal.mff.cuni.cz/~zeman/soubory/$(TGZJO)
	# rm $(TGZJO)
	# for l in en de nl ; do wget http://ufal.mff.cuni.cz/~zeman/soubory/hamledt_2.0jo_${l}_conll.tgz ; done

# Basic statistics: number of sentences and tokens in train and test data.
stats:
	$(TREEX) -p --jobs=100 Read::Treex from='!$(DIR0)/train/*.treex.gz' Util::Eval atree='print("XXX ROOT XXX\n");' anode='print("XXX NODE XXX\n");' > train-wcl.txt
	$(TREEX) -p --jobs=100 Read::Treex from='!$(DIR0)/test/*.treex.gz'  Util::Eval atree='print("XXX ROOT XXX\n");' anode='print("XXX NODE XXX\n");' > test-wcl.txt
	grep 'XXX ROOT XXX' train-wcl.txt | wc -l
	grep 'XXX NODE XXX' train-wcl.txt | wc -l
	grep 'XXX ROOT XXX' test-wcl.txt | wc -l
	grep 'XXX NODE XXX' test-wcl.txt | wc -l

deprelstats:
	$(TREEX) Read::Treex from='!$(DIR0)/{train,test}/*.treex.gz' Print::DeprelStats > deprelstats.txt

clean:
	rm -rf $(DATADIR)/treex

pokus:
	echo $(SCEN1)
