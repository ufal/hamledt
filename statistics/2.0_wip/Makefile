include ../common.mak

DATADIR   = $(TMT_ROOT)/share/data/resources/hamledt
#DATADIR   = /ha/work/people/masek/hamledtdata

A_LANGUAGES = ta
# for (non-parallel) afuns statistics on just one language

# LANGS =
# for tests ('*' by default)

it: it_orig it_pdt
it_orig:
	treex Util::SetGlobal if_missing_bundles=ignore  HamleDT::Test::Statistical::ExtractTrees -- /net/work/people/masek/.treex/share/data/resources/hamledt/cs/treex/000_orig/train/00?.treex.gz 2> ./inconsistencies/trees.err > ./inconsistencies/orig_trees.txt
	cat $(I_DIR)/orig_$(T_FILE) | grep -e '^cs' > $(I_DIR)/cs-orig_$(T_FILE)
	cat $(I_DIR)/cs-orig_$(T_FILE) | $(SCRIPTS)/find_inconsistencies.pl > $(I_DIR)/cs-orig_$(I_FILE)

it_pdt:
	treex Util::SetGlobal if_missing_bundles=ignore  HamleDT::Test::Statistical::ExtractTrees -- /net/work/people/masek/.treex/share/data/resources/hamledt/cs/treex/001_pdtstyle/train/00?.treex.gz 2> ./inconsistencies/trees.err > ./inconsistencies/pdt_trees.txt
	cat $(I_DIR)/pdt_$(T_FILE) | grep -e '^cs' > $(I_DIR)/cs-pdt_$(T_FILE)
	cat $(I_DIR)/cs-pdt_$(T_FILE) | $(SCRIPTS)/find_inconsistencies.pl > $(I_DIR)/cs-pdt_$(I_FILE)


DECCA_DIR = ./2.0_wip/decca
