TMP=tmp.txt
LANGS=*
JOBS=10

HAMLEDT_TREEX_FILES=/a/osh/zabokrtsky/tectomt/devel/share/data/resources/hamledt/*/treex/001_pdtstyle/t*/*.treex.gz

help:
	# check the Makefile

collect:
	#TODO: after normalization is redone, SetSharedModifier block will not be needed here
	treex -p --jobs=$(JOBS) HamleDT::SetSharedModifier Print::CoordStats --survive -- /net/projects/tectomt_shared/data/resources/hamledt/$(LANGS)/treex/*_pdtstyle/t*/*.treex.gz > $(TMP)

table:
	cat $(TMP) | ./create_tsv_table.pl > table.tsv
	@echo Updated table.tsv is supposed to be committed as https://svn.ms.mff.cuni.cz/svn/publications/papers/2011_cl_tree_conventions/generated_stats

afunsprepare:
	zgrep -H afun /a/osh/zabokrtsky/tectomt/devel/share/data/resources/hamledt/*/treex/001_pdtstyle/*/*.treex.gz > prac

afunsfinish:
	cat prac | ./most_frequent_afuns_to_tex.pl > afuns_freq_table.tex


#########################################################################


DATADIR   = $(TMT_ROOT)/share/data/resources/hamledt
LANGUAGES = $(shell ls $(DATADIR))
#LANGUAGES = fi ta te tr
SUBDIR    = treex/001_pdtstyle
TREEX     = treex

langs:
	echo $(LANGUAGES)

AFUNS_OPS = Util::SetGlobal if_missing_bundles=ignore
AFUNS_BLOCKS = HamleDT::Test::Statistical::Afuns
AFUNS_DIR = ./afuns
AFUNS_STATS_FILE = afuns.txt

afuns: clean_afuns $(foreach l,$(LANGUAGES),afuns-$(l)) aggregate_afuns
afuns-%:
	echo $* >> $(AFUNS_DIR)/$*-$(AFUNS_STATS_FILE)
	$(TREEX) -L$* $(AFUNS_OPS) $(BLOCKS) -- $(DATADIR)/$*/$(SUBDIR)/t*/*.treex.gz | sort | uniq -c >> $(AFUNS_DIR)/$*-$(AFUNS_STATS_FILE)

test_afuns: clean_afuns $(foreach l,$(LANGUAGES),test_afuns-$(l)) aggregate
test_afuns-%:
	echo $* >> $(AFUNS_DIR)/$*-$(AFUNS_STATS_FILE)
	$(TREEX) -L$* $(AFUNS_OPS) $(BLOCKS) -- $(DATADIR)/$*/$(SUBDIR)/test/*.treex.gz | sort | uniq -c >> $(AFUNS_DIR)/$*-$(AFUNS_STATS_FILE)

clean_afuns:
	rm -f $(AFUNS_DIR)/??-$(AFUNS_STATS_FILE)
	rm -f $(AFUNS_DIR)/???-$(AFUNS_STATS_FILE) # for grc

aggregate_afuns: 
	cat $(AFUNS_DIR)/*-$(AFUNS_STATS_FILE) > $(AFUNS_DIR)/$(AFUNS_STATS_FILE)

process_afuns:
	@ $(AFUNS_DIR)/process_afuns.pl $(AFUNS_DIR)/$(AFUNS_STATS_FILE)

INCONSISTENCIES_DIR = ./inconsistencies
INCONSISTENCIES_BLOCKS = HamleDT::Test::Statistical::ExtractTrees
TREES_FILE = trees.txt
INCONSISTENCIES_FILE = inconsistencies.txt
INCONSISTENCIES_OPS = 

check_dir:
	[ -d $(INCONSISTENCIES_DIR) ] || mkdir -p $(INCONSISTENCIES_DIR)
test_inconsistencies: check_dir
	$(TREEX) -Lcs $(INCONSISTENCIES_OPS) $(INCONSISTENCIES_BLOCKS) -- $(DATADIR)/cs/$(SUBDIR)/train/01?.treex.gz > $(INCONSISTENCIES_DIR)/cs-$(INCONSISTENCIES_FILE)

trees: check_dir $(foreach l,$(LANGUAGES),trees-$(l))
trees-%:
	$(TREEX) -L$* $(INCONSISTENCIES_OPS) $(INCONSISTENCIES_BLOCKS) -- $(DATADIR)/$*/$(SUBDIR)/t*/???.treex.gz > $(INCONSISTENCIES_DIR)/$*-$(TREES_FILE)

process_inconsistencies:
	./find_inconsistencies.pl *$(INCONSISTENCIES_FILE)