# Treebanks from CoNLL 2017 shared task (subset of Universal Dependencies 2.0)
# Skip the 6 treebanks that does not take part in the shared task: ar_nyuad be cop lt sa ta
# Skip the 8 small treebanks for now (no development data): fr_partut ga gl_treegal kk la sl_sst ug uk
TREEBANKS=ar bg ca cs cs_cac cs_cltt cu da de el en en_lines en_partut es es_ancora et eu fa fi fi_ftb fr fr_sequoia gl got grc grc_proiel he hi hr hu id it it_partut ja ko la_ittb la_proiel lv nl nl_lassysmall no_bokmaal no_nynorsk pl pt pt_br ro ru ru_syntagrus sk sl sv sv_lines tr ur vi zh
UDNAMES=Arabic Bulgarian Catalan Czech Czech-CAC Czech-CLTT Old_Church_Slavonic Danish German Greek English English-LinES English-ParTUT Spanish Spanish-AnCora Estonian Basque Persian Finnish Finnish-FTB French French-Sequoia Galician Gothic Ancient_Greek Ancient_Greek-PROIEL Hebrew Hindi Croatian Hungarian Indonesian Italian Italian-ParTUT Japanese Korean Latin-ITTB Latin-PROIEL Latvian Dutch Dutch-LassySmall Norwegian-Bokmaal Norwegian-Nynorsk Polish Portuguese Portuguese-BR Romanian Russian Russian-SynTagRus Slovak Slovenian Swedish Swedish-LinES Turkish Urdu Vietnamese Chinese
SRCPATHS=$(addprefix /net/data/universal-dependencies-2.0/UD_,$(UDNAMES))
TRAINFILENAMES=$(addsuffix -ud-train.conllu,$(TREEBANKS))
TRAINSRCPATHS=$(join $(addsuffix /,$(SRCPATHS)),$(TRAINFILENAMES))
DEVFILENAMES=$(addsuffix -ud-dev.conllu,$(TREEBANKS))
DEVSRCPATHS=$(join $(addsuffix /,$(SRCPATHS)),$(DEVFILENAMES))
WDIR=/net/work/people/zeman/hamledt/parsing/ud2

import_data:
	mkdir -p $(WDIR)
	cp $(TRAINSRCPATHS) $(WDIR)
	cp $(DEVSRCPATHS) $(WDIR)

convert_all: $(subst conllu,conll,$(wildcard $(WDIR)/*.conllu))

%.conll: %.conllu
	conllu_to_conllx.pl < $< > $@

train_all: $(subst -ud-train.conll,.mco,$(wildcard $(WDIR)/*-ud-train.conll))

%.mco: %-ud-train.conll
	trainmalt.pl $<

ALL_LANGUAGES=ar bg bn ca cs da de el en es eu fa fi grc hi hu it ja la nl pt ro ru sl sv ta te tr
#LANGUAGES=$(ALL_LANGUAGES)
LANGUAGES=ar bg ca da de en es fa hi hu it ja nl pt ro ru sv ta te
L=en

train:
	./train.pl --feat conll --mcd --mcdproj --malt --maltsmf --wdir $(WDIR) $(LANGUAGES)

parse:
	./parse.pl --new --feat conll --mcd --mcdproj --malt --maltsmf --wdir $(WDIR) $(LANGUAGES)

eval_samples:
	./eval_samples.pl $(ALL_LANGUAGES)
	# Wait until all the jobs are finished, then run
	# make significance

significance:
	./print_signif.pl > significance.tsv
	# grep positive significance.tsv

table:
	./print_table.pl --eval p --parser malt --wdir $(WDIR) $(LANGUAGES) 
	./print_table.pl --eval p --parser maltsmf --wdir $(WDIR) $(LANGUAGES) 
	#./print_table.pl --eval p --parser mcd $(LANGUAGES)  
	#./print_table.pl --eval p --parser mcdproj $(LANGUAGES) 

all_tables:
	./print_table.pl --parser mcd --transform there-only $(LANGUAGES) > RESULTS-there-only.txt
	./print_table.pl --parser mcdproj --transform there-only $(LANGUAGES) >> RESULTS-there-only.txt
	./print_table.pl --parser malt --transform there-only $(LANGUAGES) >> RESULTS-there-only.txt
	./print_table.pl --parser maltsmf --transform there-only $(LANGUAGES) >> RESULTS-there-only.txt
	./print_table.pl --parser mcd $(LANGUAGES) > RESULTS.txt
	./print_table.pl --parser mcdproj $(LANGUAGES) >> RESULTS.txt
	./print_table.pl --parser malt $(LANGUAGES) >> RESULTS.txt
	./print_table.pl --parser maltsmf $(LANGUAGES) >> RESULTS.txt

diff:
	@treex -L$(L) Print::ListMostDifferentTrees selector=maltsmfBASE selector2=maltsmfPDT selector3=before threshold=0.9 -- /net/cluster/TMP/marecek/hamledt_parsing/$(L)/trans_fMhLsNcBpP/001.treex.gz > diff.txt
	@ttred -l diff.txt

tex:
	./print_tex.pl > parsing_accuracy_table.tex
	@echo parsing_accuracy_table.tex should be commited as publications/papers/2011_cl_tree_conventions

clean:
	rm -rf $(WDIR)/*/*/*-cluster-run-*
	rm -f  $(WDIR)/*/*/mlt*.sh*
	rm -f  $(WDIR)/*/*/smf*.sh*
	rm -f  $(WDIR)/*/*/mcd*.sh*
	rm -f  $(WDIR)/*/*/mcp*.sh*
	rm -f  $(WDIR)/*/*/p-*.sh*
	rm -rf $(WDIR)/*/*/malt_nivreeager
	rm -rf $(WDIR)/*/*/malt_stacklazy
