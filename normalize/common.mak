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
DATADIR   = $(TMT_ROOT)/share/data/resources/hamledt/$(TREEBANK)
SUBDIRIN  = source
SUBDIR0   = treex/00
SUBDIR1   = treex/01
SUBDIR2   = treex/02
SUBDIRCU  = conllu
IN        = $(DATADIR)/$(SUBDIRIN)
DIR0      = $(DATADIR)/$(SUBDIR0)
DIR1      = $(DATADIR)/$(SUBDIR1)
DIR2      = $(DATADIR)/$(SUBDIR2)
CONLLUDIR = $(DATADIR)/$(SUBDIRCU)
# DEPRECATED: The Stanford stuff will be removed once we have conversion to Universal Dependencies fully operational.
SUBDIRS   = stanford
STANDIR   = $(DATADIR)/$(SUBDIRS)

# Processing shortcuts.
# Ordinary users can set --priority from -1023 to 0 (0 being the highest priority). Treex default is -100.
# I am temporarily setting it rather high in order to sneak before Shadi's jobs.
TREEX      = treex -L$(LANGCODE)
QTREEX     = treex -p --jobs 100 --priority=-1 -L$(LANGCODE)
IMPORT     = Read::CoNLLX lines_per_doc=500
WRITE0     = Write::Treex file_stem='' clobber=1
WRITE      = Write::Treex clobber=1
# Treebank-specific Makefiles must override the value of HARMONIZE if their harmonization block is not called Harmonize.
# They must do so before they include common.mak.
HARMONIZE ?= Harmonize
TRAIN      = $(IN)/train.conll
DEV        = $(IN)/dev.conll
TEST       = $(IN)/test.conll

# If a treebank requires postprocessing after conversion to UD, the treebank-specific Makefile must override the value of POST_UD_BLOCKS.
# Example: POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords
POST_UD_BLOCKS ?=

check-source:
	[ -d $(IN) ] || (echo new $(LANGCODE) && make source)

dirs:
	@echo The root data directory for $(TREEBANK): $(DATADIR)
	mkdir -p $(DATADIR)
	if [ ! -e data ]; then ln -s $(DATADIR) data; fi
	mkdir -p data/$(SUBDIRIN)
	mkdir -p data/{$(SUBDIR0),$(SUBDIR1),$(SUBDIR2)}/{train,dev,test}
	chmod -R g+w data/. data/*

# Run a conversion of the original data into the treex format
# and store the results in 00. This default assumes CoNLL-X,
# our most-widely used source format. If a different conversion
# is needed, override in the language-specific Makefile.
# Otherwise, define the language-specific "treex" goal as dependent
# on "conll_to_treex".
conll_to_treex:
	$(TREEX) $(IMPORT) from=$(IN)/train.conll $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORT) from=$(IN)/dev.conll   $(WRITE0) path=$(DIR0)/dev/
	$(TREEX) $(IMPORT) from=$(IN)/test.conll  $(WRITE0) path=$(DIR0)/test/

# Convert the trees to the HamleDT/Prague style and store the result in 01.
UCLANG = $(shell perl -e 'print uc("$(LANGCODE)");')
SCEN1 = A2A::CopyAtree source_selector='' selector='orig' HamleDT::$(UCLANG)::$(HARMONIZE)
prague:
	$(QTREEX) $(SCEN1) Write::Treex substitute={00}{01} -- '!$(DIR0)/{train,dev,test}/*.treex.gz'

###!!! The ud goal is currently defined only for Czech but we want it language-independent!
# Convert the trees to Universal Dependencies and store the result in 02.
SCEN2 = A2A::CopyAtree source_selector='' selector='prague' HamleDT::Udep $(POST_UD_BLOCKS)
ud:
	$(QTREEX) $(SCEN2) Write::Treex substitute={01}{02} -- '!$(DIR1)/{train,dev,test}/*.treex.gz'

# This goal exports the harmonized trees in the CoNLL-U format, which is more useful for ordinary users.
export_conllu:
	$(QTREEX) Read::Treex from='!$(DIR2)/{train,dev,test}/*.treex.gz' Write::CoNLLU substitute={$(DIR2)}{$(CONLLUDIR)} clobber=1 compress=1



# DEPRECATED: The Stanford stuff will be removed once we have conversion to Universal Dependencies fully operational.
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
	$(QTREEX) $(STANFORD) -- $(DIR1)/{train,test}/*.treex.gz

treex_to_stanford_test:
	$(TREEX) $(STANFORD) -- $(DIR1)/test/*.treex.gz

# Basic statistics: number of sentences and tokens in train and test data.
stats:
	$(TREEX) -p --jobs=100 Read::Treex from='!$(DIR0)/train/*.treex.gz' Util::Eval atree='print("XXX ROOT XXX\n");' anode='print("XXX NODE XXX\n");' > train-wcl.txt
	$(TREEX) -p --jobs=100 Read::Treex from='!$(DIR0)/test/*.treex.gz'  Util::Eval atree='print("XXX ROOT XXX\n");' anode='print("XXX NODE XXX\n");' > test-wcl.txt
	grep 'XXX ROOT XXX' train-wcl.txt | wc -l
	grep 'XXX NODE XXX' train-wcl.txt | wc -l
	grep 'XXX ROOT XXX' test-wcl.txt | wc -l
	grep 'XXX NODE XXX' test-wcl.txt | wc -l

deprelstats:
	$(TREEX) Read::Treex from='!$(DIR0)/{train,dev,test}/*.treex.gz' Print::DeprelStats > deprelstats.txt


clean_cluster:
	rm -rf *-cluster-run-*

clean: clean_cluster
	rm -rf $(DATADIR)/treex $(DATADIR)/conllu
