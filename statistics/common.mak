#-*- mode: makefile -*-
SHELL=bash

SUBDIR    = treex/001_pdtstyle
SUBDIRC   = conll
ORIG_SUBDIR = treex/000_orig
TREEX     = treex
SCRIPTS = ../scripts
JOBS=100

LANGUAGES = bg bn ca cs da de el en es et eu fa fi grc hi hu it ja la nl pt ro ru sl sv ta te tr # ar he is pl zh # for cycles
LANGS=*
# for shell expansion

TREEX_FILES = $(DATADIR)/$(LANGS)/$(SUBDIR)/t*/*.treex.gz
TREEX_FILES_ORIG = $(DATADIR)/$(LANGS)/$(ORIG_SUBDIR)/t*/*.treex.gz
CONLL_FILES = $(DATADIR)/$(LANGS)/$(SUBDIRC)/t*/*.treex.gz

help:
	# 'Check Makefile'

langs:
	echo $(LANGUAGES)

qall: a_all b_all i_all t_all clean

#########
# afuns #
#########

A_OPS = Util::SetGlobal if_missing_bundles=ignore 
A_BLOCKS = HamleDT::Util::ExtractAfuns
A_DIR = ./afuns
A_FILE = afuns.txt
A_FILE_SORTED = afuns_sorted.txt
A_TABLE_COUNTS = latest_table.txt
A_TABLE_RAW = afuns_table_raw.txt
A_TABLE_NORM = afuns_table_normalized.txt
QA_OPS = -p -j $(JOBS) Util::SetGlobal if_missing_bundles=ignore 

a_all: qafuns asort atable

check_adir:
	[ -d $(A_DIR) ] || mkdir -p $(A_DIR)

afuns: check_adir
	$(TREEX) $(A_OPS) $(A_BLOCKS) -- $(TREEX_FILES) > $(A_DIR)/$(A_LANGUAGE)-$(A_FILE)

qafuns: check_adir
	$(TREEX) $(QA_OPS) $(A_BLOCKS) -- $(TREEX_FILES) 2> $(A_DIR)/afuns.err > $(A_DIR)/$(A_FILE)

asort:
	cat $(A_DIR)/$(A_FILE) | sort | uniq -c | sort -n | sort -k2,3 | perl -ne 'chomp;s/^\s+//; my($$count,$$language,$$afun)=split /\s+/,$$_; print(join "\t",($$language,$$count,$$afun),"\n")' > $(A_DIR)/$(A_FILE_SORTED)

asplit: $(foreach l,$(LANGUAGES), asplit-$(l))
asplit-%:
	cat $(A_DIR)/$(A_FILE_SORTED) | grep -e '^$*' > $(A_DIR)/$*-$(A_FILE)

atable: atable_counts atable_proportions atable_normalized

atable_counts:
	cat $(A_DIR)/$(A_FILE) | $(SCRIPTS)/summarize_afuns.pl > $(A_DIR)/$(A_TABLE_COUNTS)

atable_proportions:
	cat $(A_DIR)/$(A_FILE_SORTED) | $(SCRIPTS)/process_afuns.pl > $(A_DIR)/$(A_TABLE_RAW)

atable_normalized:
	cat $(A_DIR)/$(A_FILE_SORTED) | $(SCRIPTS)/process_afuns.pl -n > $(A_DIR)/$(A_TABLE_NORM)

#################################
# bigrams & conditional entropy #
#################################

B_OPS = Util::SetGlobal if_missing_bundles=ignore
B_BLOCKS = HamleDT::Util::ExtractDependencyBigrams
B_DIR = ./bigrams
B_FILE = bigrams.txt
QB_OPS = -p -j $(JOBS) Util::SetGlobal if_missing_bundles=ignore
B_TABLE = latest_table.txt
E_TABLE = entropy.txt

b_all: qbigrams btable entropy

check_bdir:
	[ -d $(B_DIR) ] || mkdir -p $(B_DIR)

qbigrams: check_bdir
	$(TREEX) $(QB_OPS) $(B_BLOCKS) -- $(TREEX_FILES) 2> $(B_DIR)/bigrams.err > $(B_DIR)/$(B_FILE)

btable:
	cat $(B_DIR)/$(B_FILE) | $(SCRIPTS)/summarize_bigrams.pl > $(B_DIR)/$(B_TABLE)

entropy:
	cat $(B_DIR)/$(B_FILE) | $(SCRIPTS)/bigram_conditional_entropy.pl > $(B_DIR)/$(E_TABLE)

###################
# inconsistencies #
###################
I_DIR = ./inconsistencies
QI_OPS = -p -j $(JOBS) Util::SetGlobal if_missing_bundles=ignore

#######
# POS #
#######
OLD_IP_BLOCKS = HamleDT::Util::ExtractSurfaceNGrams
IP_DIR = $(I_DIR)/POS
IP_ERR = pdt_surface_ngrams.err
OLD_IP_FILE = pdt_surface_ngrams.txt
IP_FILE = pdt_POS_surface_incons.txt
IP_BLOCKS = HamleDT::Util::FindPOSInconsistencies
IP_STATS_BASE = pdt_POS_surface_incons_stats

check_ipdir:
	[ -d $(IP_DIR) ] || mkdir -p $(IP_DIR) 

ip_surface: check_ipdir
	$(TREEX) $(QI_OPS) $(OLD_IP_BLOCKS) -- $(TREEX_FILES) 2> $(IP_DIR)/$(IP_ERR) > $(IP_DIR)/$(OLD_IP_FILE)

ip_split: $(foreach l,$(LANGUAGES), ip_split-$(l))
ip_split-%:
	cat $(IP_DIR)/$(OLD_IP_FILE) | grep -e '^$*' | cut -f2- > $(IP_DIR)/$*-$(OLD_IP_FILE)

CONTEXT_SIZE = 1
MIN_NGRAM = 3
MAX_NGRAM = 10
IP_OPTS = $(CONTEXT_SIZE)-$(MIN_NGRAM)-$(MAX_NGRAM)
IP_STATS = $(IP_STATS_BASE)-$(IP_OPTS).txt

ip_incons: $(foreach l,$(LANGUAGES),ip_incons-$(l))
ip_incons-%:
	$(SCRIPTS)/inconsistencies_POS_surface.pl -i $(IP_DIR)/$*-$(OLD_IP_FILE) -c $(CONTEXT_SIZE) -n $(MIN_NGRAM) -x $(MAX_NGRAM) -- > $(IP_DIR)/$*-pdt_POS_surface_incons.txt 

ip_stats: clean_ip_stats $(foreach l,$(LANGUAGES),ip_stats-$(l))
ip_stats-%:
	echo -n "$*	" >> $(I_DIR)/$(IP_STATS)
	head -n1 $(IP_DIR)/$*-$(IP_FILE) >> $(I_DIR)/$(IP_STATS)

clean_ip_stats:
	rm -f $(I_DIR)/$(IP_STATS)

I_BLOCKS = HamleDT::Util::ExtractTrees

T_FILE_ORIG = orig_trees.txt
T_FILE_PDT = pdt_trees.txt
I_FILE_ORIG = orig_inconsistencies.txt
I_FILE_PDT = pdt_inconsistencies.txt
C_FILE_ORIG = orig_corrections.txt
C_FILE_PDT = pdt_corrections.txt



i_all: trees tsplit incons c_stats

check_idir:
	[ -d $(I_DIR) ] || mkdir -p $(I_DIR)

trees: check_idir trees_orig trees_pdt
trees_orig:
	$(TREEX) $(QI_OPS) $(I_BLOCKS) type=orig -- $(TREEX_FILES_ORIG) 2> $(I_DIR)/orig_trees.err > $(I_DIR)/$(T_FILE_ORIG)
trees_pdt: 
	$(TREEX) $(QI_OPS) $(I_BLOCKS) type=pdt -- $(TREEX_FILES) 2> $(I_DIR)/pdt_trees.err > $(I_DIR)/$(T_FILE_PDT)

tsplit: tsplit_orig tsplit_pdt
tsplit_orig: $(foreach l,$(LANGUAGES), tsplit_orig-$(l))
tsplit_orig-%:
	cat $(I_DIR)/$(T_FILE_ORIG) | grep -e '^$*' > $(I_DIR)/$*-$(T_FILE_ORIG)
tsplit_pdt: $(foreach l,$(LANGUAGES), tsplit_pdt-$(l))
tsplit_pdt-%:
	cat $(I_DIR)/$(T_FILE_PDT) | grep -e '^$*' > $(I_DIR)/$*-$(T_FILE_PDT)

incons: incons_orig incons_pdt
incons_orig: $(foreach l,$(LANGUAGES), incons_orig-$(l))
incons_orig-%:
	cat $(I_DIR)/$*-$(T_FILE_ORIG) | $(SCRIPTS)/find_inconsistencies.pl -i $(I_DIR)/$*-$(I_FILE_ORIG) -c $(I_DIR)/$*-$(C_FILE_ORIG)
incons_pdt: $(foreach l,$(LANGUAGES), incons_pdt-$(l))
incons_pdt-%:
	cat $(I_DIR)/$*-$(T_FILE_PDT) | $(SCRIPTS)/find_inconsistencies.pl -i $(I_DIR)/$*-$(I_FILE_PDT) -c $(I_DIR)/$*-$(C_FILE_PDT)


c_stats: c_stats_clean c_stats_orig c_stats_pdt
c_stats_clean:
	rm -f $(I_DIR)/corrections_statistics*.txt
c_stats_orig: $(foreach l, $(LANGUAGES), c_stats_orig-$(l))
c_stats_orig-%:
	echo -n '$*	' >> $(I_DIR)/corrections_statistics_orig.txt
	cat $(I_DIR)/$*-$(C_FILE_ORIG) | wc -l >> $(I_DIR)/corrections_statistics_orig.txt
c_stats_pdt: $(foreach l, $(LANGUAGES), c_stats_pdt-$(l))
c_stats_pdt-%:
	echo -n '$*	' >> $(I_DIR)/corrections_statistics_pdt.txt
	cat $(I_DIR)/$*-$(C_FILE_PDT) | wc -l >> $(I_DIR)/corrections_statistics_pdt.txt



total_incons:
	cat $(I_DIR)/*-$(T_FILE) | $(SCRIPTS)/find_inconsistencies.pl > $(I_DIR)/total_$(I_FILE)

#########
# tests #
#########

VALLOG=validation.log
TESTLOG=test.log
T_DIR = ./tests
T_TABLE = latest_table.txt
TESTS = 'HamleDT::Test::AfunDefined \
	HamleDT::Test::AfunKnown \
	HamleDT::Test::AfunNotNR \
	HamleDT::Test::AfunsUnderRoot \
	HamleDT::Test::AdvNotUnderNoun \
	HamleDT::Test::AtrNotUnderVerb \
	HamleDT::Test::AtvVBelowVerb \
	HamleDT::Test::AuxAUnderNoun \
	HamleDT::Test::AuxZChilds \
	HamleDT::Test::CoApAboveEveryMember \
	HamleDT::Test::FinalPunctuation \
	HamleDT::Test::LeafAux \
	HamleDT::Test::MaxOneSubject \
	HamleDT::Test::MemberInEveryCoAp \
	HamleDT::Test::MemberInEveryCoord \
	HamleDT::Test::NonemptyAttr \
	HamleDT::Test::NoNewNonProj \
	HamleDT::Test::NonleafAuxC \
	HamleDT::Test::NonleafAuxP \
	HamleDT::Test::NonParentAuxS \
	HamleDT::Test::NounGovernsDet \
	HamleDT::Test::NumberHavePosC \
	HamleDT::Test::PredUnderRoot \
	HamleDT::Test::PrepIsAuxP \
	HamleDT::Test::SubjectBelowVerb \
	\
	HamleDT::Test::AuxGIsPunctuation \
	HamleDT::Test::AuxPNotMember \
	HamleDT::Test::AuxVNotOnTop \
	HamleDT::Test::AuxXIsComma \
	HamleDT::Test::SingleEffectiveRootChild '

check_tdir:
	[ -d $(T_DIR) ] || mkdir -p $(T_DIR)

t_all: ttests ttable

validate:
	treex -p --jobs=$(JOBS) --survive -- $(TREEX_FILES)  2>&1 | tee $(T_DIR)/$(VALLOG)
	@echo
	@echo Output of the validation test stored in $(T_DIR)/$(VALLOG)

summarize_validation:
	grep -v TREEX $(T_DIR)/$(VALLOG) || exit 0

# DZ: Removing --survive from the treex command below.
# Sometimes a job fails to produce .stderr, treex does not know what to do (it is supposed to pass the stderrs in the original order)
# but it does not kill the jobs because of the --survive flag.
ttests: check_tdir
	treex  -p --jobs=$(JOBS) \
	Util::SetGlobal if_missing_bundles=ignore \
	$(TESTS) \
	-- $(TREEX_FILES) 2> $(T_DIR)/test.err > $(T_DIR)/$(TESTLOG)

ttable:
	cat $(T_DIR)/$(TESTLOG) | $(SCRIPTS)/summarize_tests.pl > $(T_DIR)/$(T_TABLE)
	cat $(T_DIR)/$(TESTLOG) | $(SCRIPTS)/summarize_ok_tests.pl > $(T_DIR)/ok_$(T_TABLE)


#############

clean:
	rm -rf ???-cluster-run-*

#########
# score #
#########

S_TABLE = score.txt

score:
	$(SCRIPTS)/score.pl -a $(A_DIR)/$(A_TABLE_COUNTS) -p $(B_DIR)/$(E_TABLE) -t $(T_DIR)/$(T_TABLE) -o $(T_DIR)/ok_$(T_TABLE) > $(S_TABLE)
