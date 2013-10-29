SHELL=/bin/bash

# To be included from the language-specific makefiles like this:
# include ../common.mak
DATADIR  = $(TMT_ROOT)/share/data/resources/hamledt/$(LANGCODE)
SUBDIRIN = source
SUBDIR0  = treex/000_orig
SUBDIR1  = treex/001_pdtstyle
SUBDIR_STAN = stanford
IN       = $(DATADIR)/$(SUBDIRIN)
DIR0     = $(DATADIR)/$(SUBDIR0)
DIR1     = $(DATADIR)/$(SUBDIR1)
DIR_STAN = $(DATADIR)/$(SUBDIR_STAN)
TREEX    = treex -L$(LANGCODE)
IMPORT   = Read::CoNLLX lines_per_doc=500
WRITE0   = Write::Treex file_stem='' clobber=1
WRITE    = Write::Treex clobber=1
TRAIN    = $(IN)/train.conll
TEST     = $(IN)/test.conll
TO_PDT_TRAIN_OPT :=
TO_PDT_TEST_OPT  :=
POSTPROCESS1_SCEN_OPT :=
POSTPROCESS2_SCEN_OPT :=

check-source:
	[ -d $(IN) ] || (echo new $(LANGCODE) && make source)

dirs:
	@echo The root data directory for $(LANGCODE): $(DATADIR)
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
#TODO: Skip the HamleDT::DeleteAfunCoordWithoutMembers and similar blocks, check the cases when they had to be applied (HamleDT::Test::MemberInEveryCoAp) and fix it properly.
#TODO: Do not even use the POSTPROCESS[12]_SCEN_OPT blocks. They also may contain transformations of coordination that would obscure the effect of Harmonize.
#SCEN1  = HamleDT::$(UCLANG)::Harmonize $(POSTPROCESS1_SCEN_OPT) HamleDT::SetSharedModifier HamleDT::SetCoordConjunction HamleDT::DeleteAfunCoordWithoutMembers $(POSTPROCESS2_SCEN_OPT)
SCEN1 = HamleDT::$(UCLANG)::Harmonize

pdt:
	$(TREEX) $(TO_PDT_TRAIN_OPT) $(SCEN1)  Write::Treex substitute={000_orig}{001_pdtstyle} -- '!$(DIR0)/{train,test}/*.treex.gz'

# This goal serves development and debugging of the Harmonize block.
# Smaller data are processed faster.
# $(TREEX) is not used because we do not want to parallelize the task on the cluster.
# (By default, copies of logs from parallel jobs lack the TREEX-INFO level.)
test:
	treex -L$(LANGCODE) $(SCEN1) $(WRITE) path=$(DIR1)/test -- '!$(DIR0)/test/*.treex.gz'

clean:
	rm -rf $(DATADIR)/treex

pokus:
	echo $(SCEN1)

# TODO: other structure changes (compound verbs)
# TODO: often fails because there remain some punct nodes with children
TO_STANFORD=\
			A2A::CopyAtree source_selector='' selector=pdt \
			Util::Eval anode='$$anode->set_conll_deprel('');' \
			HamleDT::Transform::SubordConjDownward \
			HamleDT::SetSharedModifier \
			HamleDT::SetCoordConjunction \
			HamleDT::Transform::CoordStyle from_style=fPhRsHcHpB style=fShLsHcBpB \
			HamleDT::Transform::MarkPunct \
			HamleDT::Transform::StanfordPunct \
			HamleDT::Transform::StanfordTypes \
			HamleDT::Transform::StanfordCopulas \
			HamleDT::SetConllTags features=subpos,prontype,numtype,advtype,punctype,tense,verbform \
			Util::Eval anode='$$anode->set_afun('');'
# This is for TrEd to display the newly set conll/deprels instead of afuns.

WRITE_STANFORD=Util::SetGlobal substitute={$(SUBDIR1)}{$(SUBDIR_STAN)} clobber=1 \
	Write::Treex \
	Write::Stanford type_attribute=conll/deprel to=. \
	Write::CoNLLX deprel_attribute=conll/deprel pos_attribute=conll/pos cpos_attribute=conll/cpos feat_attribute=iset to=.

STANFORD=$(TO_STANFORD) $(WRITE_STANFORD)

treex_to_stanford:
	treex -L$(LANGCODE) $(STANFORD) -- $(DIR1)/train/*.treex.gz
	treex -L$(LANGCODE) $(STANFORD) -- $(DIR1)/test/*.treex.gz

treex_to_stanford_test:
	treex -L$(LANGCODE) $(STANFORD) -- $(DIR1)/test/*.treex.gz

