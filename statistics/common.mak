#-*- mode: makefile -*-

SUBDIR    = treex/001_pdtstyle
TREEX     = treex
SCRIPTS = ../scripts
JOBS=100

LANGUAGES = ar bg bn ca cs da de el en es et eu fa fi grc hi hu it ja la nl pt ro ru sl sv ta te tr # he is pl zh # for cycles
LANGS=*
# for shell expansion

FILES = $(DATADIR)/$(LANGS)/$(SUBDIR)/t*/*.treex.gz

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
T_FILE = trees.txt
I_FILE = inconsistencies.txt


QI_OPS = -p -j $(JOBS) Util::SetGlobal if_missing_bundles=ignore 

i_all: trees tsplit incons

check_tdir:
	[ -d $(I_DIR) ] || mkdir -p $(I_DIR)

trees: check_tdir
	$(TREEX) $(QI_OPS) $(I_BLOCKS) -- $(FILES) > $(I_DIR)/$(T_FILE)

tsplit: $(foreach l,$(LANGUAGES), tsplit-$(l))
tsplit-%:
	cat $(I_DIR)/$(T_FILE) | grep -e '^$*' > $(I_DIR)/$*-$(T_FILE)

incons: $(foreach l,$(LANGUAGES), incons-$(l))
incons-%:
	cat $(I_DIR)/$*-$(T_FILE) | $(SCRIPTS)/find_inconsistencies.pl > $(I_DIR)/$*-$(I_FILE)

total_incons:
	cat $(I_DIR)/*-$(T_FILE) | $(SCRIPTS)/find_inconsistencies.pl > $(I_DIR)/total_$(I_FILE)

#########
# tests #
#########

VALLOG=validation.log
TESTLOG=test.log
T_DIR = ./tests
T_TABLE = latest_table.txt

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
ttests:
	treex  -p --jobs=$(JOBS) \
	Util::SetGlobal if_missing_bundles=ignore \
	HamleDT::Test::AfunDefined \
	HamleDT::Test::AfunKnown \
	HamleDT::Test::AfunNotNR \
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
	HamleDT::Test::NounGovernsDet \
	HamleDT::Test::PredUnderRoot \
	HamleDT::Test::PrepIsAuxP \
	HamleDT::Test::SubjectBelowVerb \
	-- $(FILES) 2> $(T_DIR)/test.err > $(T_DIR)/$(TESTLOG)

ttable:
	cat $(T_DIR)/$(TESTLOG) | $(SCRIPTS)/summarize_tests.pl > $(T_DIR)/$(T_TABLE)


#############

clean:
	rm -rf ???-cluster-run-*

#########
# score #
#########

S_TABLE = score.txt

score:
	$(SCRIPTS)/score.pl -a $(A_DIR)/$(A_TABLE_COUNTS) -p $(B_DIR)/$(E_TABLE) -t $(T_DIR)/$(T_TABLE) > $(S_TABLE)
