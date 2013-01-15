ALL_LANGUAGES=ar bg bn cs da de el en es fi hi hu it nl pt ro ru sl sv ta te tr
#LANGUAGES=ar en eu grc la
LANGUAGES=$(ALL_LANGUAGES)

train:
	#./train.pl --new --mcd --mcdproj --malt $(LANGUAGES)
	./train.pl --new --feat conll --maltsmf $(LANGUAGES)

train_smf:
	#./train.pl --new --mcd --mcdproj --malt $(LANGUAGES)
	./train.pl --new --feat conll --maltsmf $(LANGUAGES)

train_new:
	./train.pl --new --malt --trans trans_fSpPcBhNsN,trans_fMpPcBhNsN,trans_fMpPcPhLsN,trans_fMpPcPhRsN $(ALL_LANGUAGES)

parse:
	./parse.pl --new --mcd --mcdproj --malt --maltsmf $(LANGUAGES)
	#./parse.pl --new --maltsmf $(LANGUAGES)

eval:
	./eval.pl $(ALL_LANGUAGES)

eval_samples:
	./eval_samples.pl $(ALL_LANGUAGES)
	# Wait until all the jobs are finished, then run
	# make significance

significance:
	./print_signif.pl > significance.tsv
	# grep positive significance.tsv


table:
	@./print_table.pl --parser mcd --transform there-only $(LANGUAGES)
	@./print_table.pl --parser mcdproj --transform there-only $(LANGUAGES)
	@./print_table.pl --parser malt --transform there-only $(LANGUAGES)
	@./print_table.pl --parser maltsmf --transform there-only $(LANGUAGES)
	@./print_table.pl --parser mcd $(LANGUAGES)
	@./print_table.pl --parser mcdproj $(LANGUAGES)
	@./print_table.pl --parser malt $(LANGUAGES)
	@./print_table.pl --parser maltsmf $(LANGUAGES)


view:
	@treex -Lcs Print::ListMostDifferentTrees selector=maltnivreeagerBASE selector2=maltnivreeagerPDT threshold=0.9 -- /home/marecek/tectomt/share/data/resources/hamledt/cs/treex/trans_fMhLsNcBpP/parsed/001.treex.gz > diff.txt
	@ttred -l diff.txt

tex:
	./print_tex.pl > parsing_accuracy_table.tex
	@echo parsing_accuracy_table.tex should be commited as publications/papers/2011_cl_tree_conventions

rights:
	chmod -R g+w ${TMT_ROOT}/share/data/resources/hamledt/ 2>/dev/null || echo Done

clean_temp_files:
	rm -r /net/projects/tectomt_shared/data/resources/hamledt/*/treex/*/parsed/*-cluster-run-*
	rm /net/projects/tectomt_shared/data/resources/hamledt/*/treex/*/parsed/parse-*.sh.o*
	rm /net/projects/tectomt_shared/data/resources/hamledt/*/treex/*/parsed/mlt*.sh.o*
	rm /net/projects/tectomt_shared/data/resources/hamledt/*/treex/*/parsed/mcd*.sh.o*
	rm /net/projects/tectomt_shared/data/resources/hamledt/*/treex/*/parsed/mcp*.sh.o*

clean_malt_dirs:
	rm -rf /net/projects/tectomt_shared/data/resources/hamledt/*/treex/*/parsed/malt_nivreeager
	rm -rf /net/projects/tectomt_shared/data/resources/hamledt/*/treex/*/parsed/malt_stacklazy
