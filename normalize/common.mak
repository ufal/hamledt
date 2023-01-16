SHELL=/bin/bash

# To be included from the language-specific makefiles like this:
# include ../common.mak
# The language-specific makefile should define two environment variables:
# LANGCODE=cs # Czech
# TREEBANK=cs-pdt30 # either same as language code, or with hyphen and lowercase treebank code; will be used in paths
# HARMONIZE=HarmonizeSpecial # only needed if not called Harmonize; will be sought for in the $(LANGCODE) folder.

# Set paths. The main path to the working copy of the data, HAMLEDT_DATA, must be pre-set in your environment.
# You may want to put something like this in your .bash_profile:
# export HAMLEDT_DATA=/net/projects/tectomt_shared/data/resources/hamledt
DATADIR   = $(HAMLEDT_DATA)/$(TREEBANK)
SUBDIRIN  = source
SUBDIR0   = treex/00
SUBDIR1   = treex/01
SUBDIR2   = treex/02
SUBDIR3   = treex/03
SUBDIRCU  = conllu
SUBDIRPTQ = pmltq
IN        = $(DATADIR)/$(SUBDIRIN)
DIR0      = $(DATADIR)/$(SUBDIR0)
DIR1      = $(DATADIR)/$(SUBDIR1)
DIR2      = $(DATADIR)/$(SUBDIR2)
DIR3      = $(DATADIR)/$(SUBDIR3)
CONLLUDIR = $(DATADIR)/$(SUBDIRCU)
PMLTQDIR  = $(DATADIR)/$(SUBDIRPTQ)

# Processing shortcuts.
TREEX      = treex -L$(LANGCODE)
UCLANG     = $(shell perl -e 'print uc("$(LANGCODE)");')
###!!! As of October 2022, the LRC cluster at ÚFAL migrates to new software and QTREEX no longer works.
###!!! Unless it is adapted to SLURM, we have to use our own parallelization wrapper.
# Ordinary users can set --priority from -1023 to 0 (0 being the highest priority). Treex default is -100.
# The --qsub="-m n" option should prevent the cluster from sending me 100 mails when 100 jobs crash on an error.
#QTREEX     = treex -p --jobs 100 --priority=-50 --qsub="-m n" -L$(LANGCODE)
QTREEX     = ../parallel_treex.pl -L$(LANGCODE)
IMPORTX    = Read::CoNLLX lines_per_doc=100 sid_within_feat=1
IMPORTU    = Read::CoNLLU lines_per_doc=100
WRITE0     = Write::Treex file_stem='' compress=0
WRITE      = Write::Treex compress=0
# Treebank-specific Makefiles must override the value of HARMONIZE if their harmonization block is not called Harmonize.
# They must do so before they include common.mak.
HARMONIZE ?= Harmonize
TRAIN      = $(IN)/train.conll
DEV        = $(IN)/dev.conll
TEST       = $(IN)/test.conll

# If a treebank requires postprocessing after import from CoNLL-X/CoNLL-2009, the treebank-specific Makefile must override the value of POST_IMPORTX_BLOCKS.
# (This does not currently apply to import from CoNLL-U.)
POST_IMPORTX_BLOCKS ?=
# If a treebank requires preprocessing before conversion to UD, the treebank-specific Makefile must override the value of PRE_UD_BLOCKS.
# If a treebank requires postprocessing after conversion to UD, the treebank-specific Makefile must override the value of POST_UD_BLOCKS.
# Example: PRE_UD_BLOCKS=HamleDT::CS::SplitFusedWords
PRE_UD_BLOCKS  ?=
POST_UD_BLOCKS ?=
# Analogously, if a treebank requires extra blocks around the language-specific FixUD block, override the following.
PRE_FIXUD_BLOCKS  ?=
POST_FIXUD_BLOCKS ?=

check-source:
	[ -d $(IN) ] || (echo new $(LANGCODE) && make source)

dirs:
	@echo The root data directory for $(TREEBANK): $(DATADIR)
	mkdir -p $(DATADIR)
	if [ ! -e data ]; then ln -s $(DATADIR) data; fi
	mkdir -p data/$(SUBDIRIN)
	mkdir -p data/{$(SUBDIR0),$(SUBDIR1),$(SUBDIR2),$(SUBDIR3),$(SUBDIRCU)}/{train,dev,test}
	chmod -R g+w data/. data/*

# Run a conversion of the original data into the treex format
# and store the results in 00. This default assumes CoNLL-X,
# our most-widely used source format. If a different conversion
# is needed, override in the language-specific Makefile.
# Otherwise, define the treebank-specific "treex" goal as dependent
# on "conll_to_treex".
conll_to_treex:
	if [ -f $(IN)/train.conll ] ; then $(TREEX) $(IMPORTX) from=$(IN)/train.conll sid_prefix=train- Filter::RemoveEmptySentences $(POST_IMPORTX_BLOCKS) $(WRITE0) path=$(DIR0)/train/ ; fi
	if [ -f $(IN)/dev.conll   ] ; then $(TREEX) $(IMPORTX) from=$(IN)/dev.conll   sid_prefix=dev-   Filter::RemoveEmptySentences $(POST_IMPORTX_BLOCKS) $(WRITE0) path=$(DIR0)/dev/   ; fi
	if [ -f $(IN)/test.conll  ] ; then $(TREEX) $(IMPORTX) from=$(IN)/test.conll  sid_prefix=test-  Filter::RemoveEmptySentences $(POST_IMPORTX_BLOCKS) $(WRITE0) path=$(DIR0)/test/  ; fi

# If the source data is already in Universal Dependencies, do not convert it to the Prague style and then back to UD.
# Read UD directly instead. Note that there will be just one tree per sentence, not three.
# (There are three trees per sentence for treebanks that are converted via Prague.)
# Also note that we save the result directly in $(DIR2), not $(DIR0).
# For UD treebanks the treebank-specific Makefile should redefine the "ud" goal as dependent on "conllu_to_treex".
# (See also "prague_to_ud" below.)
conllu_to_treex:
	if [ -f $(IN)/train.conllu ] ; then $(TREEX) $(IMPORTU) from=$(IN)/train.conllu sid_prefix=train- $(POST_UD_BLOCKS) $(WRITE0) path=$(DIR2)/train/ ; fi
	if [ -f $(IN)/dev.conllu   ] ; then $(TREEX) $(IMPORTU) from=$(IN)/dev.conllu   sid_prefix=dev-   $(POST_UD_BLOCKS) $(WRITE0) path=$(DIR2)/dev/   ; fi
	if [ -f $(IN)/test.conllu  ] ; then $(TREEX) $(IMPORTU) from=$(IN)/test.conllu  sid_prefix=test-  $(POST_UD_BLOCKS) $(WRITE0) path=$(DIR2)/test/  ; fi

# Convert the original non-Prague trees directly to Universal Dependencies and store the result in 02.
# Export the result at the same time also to the CoNLL-U format (we need it for everything to be released).
# Remember to define the treebank-specific goal "ud" as dependent on "orig_to_ud" if this path is to be taken.
###!!! Due to a bug in Treex::Core::Node::Interset we must write CoNLLU before Treex.
###!!! After Write::Treex the Interset feature structure is corrupt (although the treex file is written correctly).
orig_to_ud:
	$(QTREEX) \
	    Read::Treex from='!$(DIR0)/{train,dev,test}/*.treex.gz' \
	    A2A::CopyAtree source_selector='' selector='orig' \
	    HamleDT::$(UCLANG)::GoogleToUdep \
	    $(POST_UD_BLOCKS) \
	    Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR0)}{$(SUBDIRCU)} compress=0 \
	    Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR2)} compress=0
	../export_ud.sh $(LANGCODE) $(UDCODE) $(UDNAME)

###############################################################################
# TO PRAGUE
# Convert the trees to the HamleDT/Prague style and store the result in 01.
###############################################################################

SCEN1 = \
    A2A::CopyAtree source_selector='' selector='orig' \
    HamleDT::$(UCLANG)::$(HARMONIZE)

prague:
	$(QTREEX) $(SCEN1) Write::Treex substitute={00}{01} compress=0 -- '!$(DIR0)/{train,dev,test}/*.treex'

###############################################################################
# PRAGUE TO UD
# Convert the trees to the Universal Dependencies and store the result in 02.
# Export the result at the same time also to the CoNLL-U format (we need it for
# everything to be released). If the UD version of the treebank is created
# using the HamleDT transformation via the Prague style, define the treebank-
# specific goal "ud" as dependent on "prague_to_ud_enhanced" (or just "prague_
# to_ud", if guessing enhanced dependencies is not desired). Otherwise, if
# reading directly data published in Universal Dependencies, make "ud"
# dependent on "conllu_to_treex".
###############################################################################

SCEN2B = \
    A2A::CopyAtree source_selector='' selector='prague' \
    $(PRE_UD_BLOCKS) \
    HamleDT::Udep \
    $(POST_UD_BLOCKS) \
    HamleDT::Punctuation

SCEN2E = \
    $(SCEN2B) \
    A2A::CopyBasicToEnhancedUD \
    A2A::AddEnhancedUD

###!!! Due to a bug in Treex::Core::Node::Interset we must write CoNLLU before Treex.
###!!! After Write::Treex the Interset feature structure is corrupt (although the treex file is written correctly).
prague_to_ud:
	$(QTREEX) \
	    Read::Treex from='!$(DIR1)/{train,dev,test}/*.treex' \
	    $(SCEN2B) \
	    Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR1)}{$(SUBDIRCU)} compress=0 \
	    Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR2)} compress=0
	../export_ud.sh $(LANGCODE) $(UDCODE) $(UDNAME)

###!!! Due to a bug in Treex::Core::Node::Interset we must write CoNLLU before Treex.
###!!! After Write::Treex the Interset feature structure is corrupt (although the treex file is written correctly).
prague_to_ud_enhanced:
	@echo `date` make prague to ud enhanced started | tee -a time.log
	$(QTREEX) \
	    Read::Treex from='!$(DIR1)/{train,dev,test}/*.treex' \
	    $(SCEN2E) \
	    Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR1)}{$(SUBDIRCU)} compress=0 \
	    Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR2)} compress=0
	../export_ud.sh $(LANGCODE) $(UDCODE) $(UDNAME)

###############################################################################
# PRAGUE TECTOGRAMMATICAL LAYER TO UD
###############################################################################

SCEN2TE = \
    A2A::CopyAtree source_selector='' selector='prague' \
    T2A::GenerateA2TRefs \
    $(PRE_UD_BLOCKS) \
    HamleDT::Udep \
    $(POST_UD_BLOCKS) \
    HamleDT::Punctuation \
    A2A::CopyBasicToEnhancedUD \
    T2A::GenerateEmptyNodes \
    A2A::AddEnhancedUD \
    A2A::CorefClusters \
    A2A::RemoveUnusedEmptyNodes \
    A2A::CorefMentions

# CorefUD needs the tectogrammatical layer of Prague annotation style.
# We cannot use this target for parts of PDT (Vesmír, what else?) and
# for non-PDT treebanks such as CAC, CLTT and FicTree.
prague_tecto_to_ud_enhanced:
	@echo `date` make prague to ud enhanced started | tee -a time.log
	$(QTREEX) \
	    Read::Treex from='!$(DIR1)/{train,dev,test}/*.treex' \
	    $(SCEN2TE) \
	    Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR1)}{$(SUBDIRCU)} compress=0 \
	    Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR2)} compress=0
	../export_ud.sh $(LANGCODE) $(UDCODE) $(UDNAME)

###############################################################################
# UD TO FIXED UD
# Improving UD data for the next release. It takes UD as input, improves it and
# saves it to a new folder. It also immediately exports the corrected data to
# the conllu folder because that is what we will want to do anyway and we
# cannot use the common export_conllu target which reads from DIR2, not DIR3.
###############################################################################

###!!! Due to a bug in Treex::Core::Node::Interset we must write CoNLLU before Treex.
###!!! After Write::Treex the Interset feature structure is corrupt (although the treex file is written correctly).
###!!! 2019-04-15: Removing W2W::EstimateNoSpaceAfter (it was immediately after A2A::CopyAtree).
###!!!   It damages some data, e.g., removes the space after Unicode closing double quote in German PUD.
fixud:
	$(QTREEX) Read::Treex from='!$(DIR2)/{train,dev,test}/*.treex' \
	        A2A::CopyAtree source_selector='' selector='orig' \
	        $(PRE_FIXUD_BLOCKS) \
	        HamleDT::$(UCLANG)::FixUD \
	        $(POST_FIXUD_BLOCKS) \
	        HamleDT::Punctuation \
	        Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR2)}{$(SUBDIRCU)} compress=0 \
	        Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR3)}
	../export_ud.sh $(LANGCODE) $(UDCODE) $(UDNAME)

fixud_enhanced:
	$(QTREEX) Read::Treex from='!$(DIR2)/{train,dev,test}/*.treex' \
	        A2A::CopyAtree source_selector='' selector='orig' \
	        $(PRE_FIXUD_BLOCKS) \
	        HamleDT::$(UCLANG)::FixUD \
	        $(POST_FIXUD_BLOCKS) \
	        HamleDT::Punctuation \
	        A2A::CopyBasicToEnhancedUD \
	        A2A::AddEnhancedUD \
	        Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR2)}{$(SUBDIRCU)} compress=0 \
	        Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR3)}
	../export_ud.sh $(LANGCODE) $(UDCODE) $(UDNAME)

# Some UD treebanks already have some enhanced dependencies and we only want to add
# the missing enhancements. We thus must not call A2A::CopyBasicToEnhanced, which
# would overwrite the existing enhancements! The calling Makefile should define the
# variable ENHANCEMENTS, e.g.: ENHANCEMENTS=case=1 coord=0 xsubj=0 relcl=0 empty=0
fixud_some_enhanced:
	$(QTREEX) Read::Treex from='!$(DIR2)/{train,dev,test}/*.treex' \
	        A2A::CopyAtree source_selector='' selector='orig' \
	        HamleDT::$(UCLANG)::FixUD \
	        A2A::AddEnhancedUD $(ENHANCEMENTS) \
	        Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR2)}{$(SUBDIRCU)} compress=0 \
	        Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR3)}
	UDDIR=$(UDDIR) ../export_ud.sh $(LANGCODE) $(UDCODE) $(UDNAME)

ud1to2:
	$(QTREEX) Read::Treex from='!$(DIR2)/{train,dev,test}/*.treex.gz' \
	        A2A::CopyAtree source_selector='' selector='orig' \
	        HamleDT::UD1To2 \
	        Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR2)}{$(SUBDIRCU)} compress=0 \
	        Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR3)}
	../export_ud.sh $(LANGCODE) $(UDCODE) $(UDNAME)

# This goal exports the harmonized trees in the CoNLL-U format, which is more useful for ordinary users.
export_conllu:
	$(QTREEX) \
	    Read::Treex from='!$(DIR2)/{train,dev,test}/*.treex' \
	    Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR2)}{$(SUBDIRCU)} compress=0

export:
	$(QTREEX) \
	    Read::Treex from='!$(DIR2)/{train,dev,test}/*.treex' \
	    Write::CoNLLU print_zone_id=0 substitute={$(SUBDIR2)}{$(SUBDIRCU)} compress=0
	../export_ud.sh $(LANGCODE) $(UDCODE) $(UDNAME)



# Export for PML-TQ: Treex files but smaller (50 trees per file) and all in one folder.
# Further processing occurs in /net/work/projects/pmltq/data/.
# We do not use parallel treex here because it cannot work with undefined total number of documents. And the reader does not know in advance how many documents it will read.
# Add the language_treebank code as a prefix of every node's id. This will enable indexing all UD treebanks as one huge corpus.
# We cannot change the id in the same run where we split the large documents into smaller ones because then Treex would try to
# reindex nodes in document but the document would not exist at that moment.
pmltq:
	$(TREEX) Read::Treex from='!$(DIR2)/{train,dev,test}/*.treex' bundles_per_doc=50 Write::Treex substitute='{$(SUBDIR2)/(train|dev|test)/(.+)(\d\d\d)}{$(SUBDIRPTQ)/$$1-$$2-$$3}' compress=1
	$(TREEX) -s Read::Treex from='!$(PMLTQDIR)/*.treex.gz' W2W::AddNodeIdPrefix prefix=$(UDCODE)/ scsubst=1

PMLTQCODE=$(shell perl -e '$$x = "$(TREEBANK)"; $$x =~ s/-ud20(.)/-ud20-$$1/; $$x =~ s/-ud20//; print $$x;')
pmltqexport:
	rm /net/work/projects/pmltq/data/ud20/treex/$(PMLTQCODE)/*.treex.gz
	cp $(PMLTQDIR)/*.treex.gz /net/work/projects/pmltq/data/ud20/treex/$(PMLTQCODE)
	cd /net/work/projects/pmltq/data/ud20 ; pmltq convert --config=pmltq-$(PMLTQCODE).yml



# Basic statistics: number of sentences and tokens in train and test data.
stats:
	$(QTREEX) Read::Treex from='!$(DIR0)/train/*.treex.gz' Util::Eval atree='print("XXX ROOT XXX\n");' anode='print("XXX NODE XXX\n");' > train-wcl.txt
	$(QTREEX) Read::Treex from='!$(DIR0)/dev/*.treex.gz'  Util::Eval atree='print("XXX ROOT XXX\n");' anode='print("XXX NODE XXX\n");' > dev-wcl.txt
	$(QTREEX) Read::Treex from='!$(DIR0)/test/*.treex.gz'  Util::Eval atree='print("XXX ROOT XXX\n");' anode='print("XXX NODE XXX\n");' > test-wcl.txt
	grep 'XXX ROOT XXX' train-wcl.txt | wc -l
	grep 'XXX NODE XXX' train-wcl.txt | wc -l
	grep 'XXX ROOT XXX' dev-wcl.txt | wc -l
	grep 'XXX NODE XXX' dev-wcl.txt | wc -l
	grep 'XXX ROOT XXX' test-wcl.txt | wc -l
	grep 'XXX NODE XXX' test-wcl.txt | wc -l

morphostats:
	$(QTREEX) Read::Treex from='!$(DIR2)/{train,dev,test}/*.treex.gz' Util::Eval anode='print($$.form, "\t", $$.lemma, "\n");' |\
		grep -v -P '\d' |\
		perl -e 'while(<>) { s/\r?\n$$//; if(m/^(.+\t(.+))$$/) { $$f{lc($$1)}++; $$l{lc($$2)}++; } } $$nf=scalar(keys(%f)); $$nl=scalar(keys(%l)); $$r=($$nl==0)?0:($$nf/$$nl); print("$$nf forms, $$nl lemmas, mr=$$r\n");' |\
		tee morphostats.txt

featurestats:
	$(QTREEX) Read::Treex from='!$(DIR2)/{train,dev,test}/*.treex.gz' Util::Eval anode='my $$f = join("|", $$.iset()->get_ufeatures()); print($$f, "\n") if(defined($$f));' |\
		perl -e 'while(<>) { s/\r?\n$$//; @f=split(/\|/, $$_); foreach $$fv (@f) { $$h{$$fv}++ }} @k=sort(keys(%h)); foreach my $$k (@k) { print("$$k\t$$h{$$k}\n"); }' |\
		tee featurestats.txt

deprelstats:
	$(TREEX) Read::Treex from='!$(DIR0)/{train,dev,test}/*.treex.gz' Print::DeprelStats > deprelstats.txt

mwestats:
	$(QTREEX) Read::Treex from='!$(DIR2)/{train,dev,test}/*.treex.gz' Print::MweStats | perl -e 'while(<>) { $$h{$$_}++ } @k = sort(keys(%h)); foreach my $$k (@k) { print("$$h{$$k}\t$$k"); }' > mwestats.txt


clean:
	rm -rf *-cluster-run-*
	rm -f *.o[0-9]*
	rm -f *.conllu.bak
	rm -f *.conllu.debug
	rm -f bugs.html
	rm -f time.log

remove_data:
	rm -rf $(DATADIR)/*
