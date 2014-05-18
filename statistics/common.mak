#-*- mode: makefile -*-

SUBDIR    = treex/001_pdtstyle
ORIG_SUBDIR = treex/000_orig
TREEX     = treex
SCRIPTS = ../scripts
JOBS=100

LANGUAGES = ar bg bn ca cs da de el en es et eu fa fi grc hi hu it ja la nl pt ro ru sl sv ta te tr # he is pl zh # for cycles
LANGS=*
# for shell expansion

FILES = $(DATADIR)/$(LANGS)/$(SUBDIR)/t*/*.treex.gz
FILES_ORIG = $(DATADIR)/$(LANGS)/$(ORIG_SUBDIR)/t*/*.treex.gz

help:
	# 'Check Makefile'

langs:
	echo $(LANGUAGES)

qall: a_all b_all i_all t_all clean

#########
# afuns #
#########

A_OPS = Util::SetGlobal if_missing_bundles=ignore 
A_BLOCKS = HamleDT::Test::Statistical::Afuns
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
	$(TREEX) $(A_OPS) $(A_BLOCKS) -- $(FILES) > $(A_DIR)/$(A_LANGUAGE)-$(A_FILE)

qafuns: check_adir
	$(TREEX) $(QA_OPS) $(A_BLOCKS) -- $(FILES) 2> $(A_DIR)/afuns.err > $(A_DIR)/$(A_FILE)

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
B_BLOCKS = HamleDT::Test::Statistical::OutputAfunBigrams
B_DIR = ./bigrams
B_FILE = bigrams.txt
QB_OPS = -p -j $(JOBS) Util::SetGlobal if_missing_bundles=ignore
B_TABLE = latest_table.txt
E_TABLE = entropy.txt

b_all: qbigrams btable entropy

check_bdir:
	[ -d $(B_DIR) ] || mkdir -p $(B_DIR)

qbigrams: check_bdir
	$(TREEX) $(QB_OPS) $(B_BLOCKS) -- $(FILES) 2> $(B_DIR)/bigrams.err > $(B_DIR)/$(B_FILE)

btable:
	cat $(B_DIR)/$(B_FILE) | $(SCRIPTS)/summarize_bigrams.pl > $(B_DIR)/$(B_TABLE)

entropy:
	cat $(B_DIR)/$(B_FILE) | $(SCRIPTS)/bigram_conditional_entropy.pl > $(B_DIR)/$(E_TABLE)

###################
# inconsistencies #
###################

I_BLOCKS = HamleDT::Test::Statistical::ExtractTrees
I_DIR = ./inconsistencies
T_FILE_ORIG = orig_trees.txt
T_FILE_PDT = pdt_trees.txt
I_FILE_ORIG = orig_inconsistencies.txt
I_FILE_PDT = pdt_inconsistencies.txt
C_FILE_ORIG = orig_corrections.txt
C_FILE_PDT = pdt_corrections.txt

QI_OPS = -p -j $(JOBS) Util::SetGlobal if_missing_bundles=ignore 

i_all: trees tsplit incons corrs c_stats

check_idir:
	[ -d $(I_DIR) ] || mkdir -p $(I_DIR)

trees: check_idir trees_orig trees_pdt
trees_orig:
	$(TREEX) $(QI_OPS) $(I_BLOCKS) type=orig -- $(FILES_ORIG) 2> $(I_DIR)/orig_trees.err > $(I_DIR)/$(T_FILE_ORIG)
trees_pdt: 
	$(TREEX) $(QI_OPS) $(I_BLOCKS) type=pdt -- $(FILES) 2> $(I_DIR)/pdt_trees.err > $(I_DIR)/$(T_FILE_PDT)

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
	cat $(I_DIR)/$*-$(T_FILE_ORIG) | $(SCRIPTS)/find_inconsistencies_02.pl -i $(I_DIR)/$*-$(I_FILE_ORIG) -c $(I_DIR)/$*-$(C_FILE_ORIG)
incons_pdt: $(foreach l,$(LANGUAGES), incons_pdt-$(l))
incons_pdt-%:
	cat $(I_DIR)/$*-$(T_FILE_PDT) | $(SCRIPTS)/find_inconsistencies_02.pl -i $(I_DIR)/$*-$(I_FILE_PDT) -c $(I_DIR)/$*-$(C_FILE_PDT)


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
	cat $(I_DIR)/$*-$(C_FILE_ORIG) | wc -l >> $(I_DIR)/corrections_statistics_pdt.txt



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
	treex -p --jobs=$(JOBS) --survive -- $(FILES)  2>&1 | tee $(T_DIR)/$(VALLOG)
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
	-- $(FILES) 2> $(T_DIR)/test.err > $(T_DIR)/$(TESTLOG)

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
