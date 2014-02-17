#-*- mode: makefile -*-

SUBDIR    = treex/001_pdtstyle
TREEX     = treex
SCRIPTS = ../scripts

LANGUAGES = ar bg bn ca cs da de el en es et eu fa fi grc hi hu it ja la nl pt ro ru sl sv ta te tr # he is pl zh

help:
	# 'Check Makefile'

langs:
	echo $(LANGUAGES)

A_OPS = Util::SetGlobal if_missing_bundles=ignore 
A_BLOCKS = HamleDT::Test::Statistical::Afuns
A_DIR = ./afuns
A_FILE = afuns.txt
A_FILE_SORTED = afuns_sorted.txt
A_TABLE = afuns_table.txt

afuns_all: qafuns asort asplit aprocess

check_adir:
	[ -d $(A_DIR) ] || mkdir -p $(A_DIR)

afuns: check_adir
	$(TREEX) $(A_OPS) $(A_BLOCKS) -- $(DATADIR)/$(A_LANGUAGE)/$(SUBDIR)/t*/*.treex.gz > $(A_DIR)/$(A_LANGUAGE)-$(A_FILE)

QA_OPS = -p -j 37 qsub='-o $(A_DIR)/$(A_FILE)' Util::SetGlobal if_missing_bundles=ignore 

qafuns: check_adir
	$(TREEX) $(QA_OPS) $(A_BLOCKS) -- $(DATADIR)/*/$(SUBDIR)/t*/*.treex.gz > $(A_DIR)/$(A_FILE)

asort:
	cat $(A_DIR)/$(A_FILE) | sort | uniq -c | sort -n | sort -k2,3 | perl -ne 'chomp;s/^\s+//; my($$count,$$language,$$afun)=split /\s+/,$$_; print(join "\t",($$language,$$count,$$afun),"\n")' > $(A_DIR)/$(A_FILE_SORTED)

asplit: $(foreach l,$(LANGUAGES), asplit-$(l))
asplit-%:
	cat $(A_DIR)/$(A_FILE_SORTED) | grep -e '^$*' > $(A_DIR)/$*-$(A_FILE)

atable:
	cat $(A_DIR)/$(A_FILE_SORTED) | $(SCRIPTS)/process_afuns.pl > $(A_DIR)/$(A_TABLE)

#######

I_BLOCKS = HamleDT::Test::Statistical::ExtractTrees
I_DIR = ./inconsistencies
T_FILE = trees.txt
I_FILE = inconsistencies.txt


QI_OPS = -p -j 37 qsub='-o $(I_DIR)/$(TREES_FILE)' Util::SetGlobal if_missing_bundles=ignore 

incons_all: trees tsplit incons

check_tdir:
	[ -d $(I_DIR) ] || mkdir -p $(I_DIR)

trees: check_tdir
	$(TREEX) $(QI_OPS) $(I_BLOCKS) -- $(DATADIR)/*/$(SUBDIR)/t*/*.treex.gz > $(I_DIR)/$(T_FILE)

tsplit: $(foreach l,$(LANGUAGES), tsplit-$(l))
tsplit-%:
	cat $(I_DIR)/$(T_FILE) | grep -e '^$*' > $(I_DIR)/$*-$(T_FILE)

incons: $(foreach l,$(LANGUAGES), incons-$(l))
incons-%:
	cat $(I_DIR)/$*-$(T_FILE) | $(SCRIPTS)/find_inconsistencies.pl > $(I_DIR)/$*-$(I_FILE)



test:
	grep -e '^a' test.t
#######

clean:
	rm -rf *-cluster-run-*