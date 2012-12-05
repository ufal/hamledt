ALL_LANGUAGES=ar bg bn cs da de el en es eu fi grc hi hu it ja la nl pt ro ru sl sv ta te tr
#LANGUAGES=bg
LANGUAGES=$(ALL_LANGUAGES)

train:
	#./train.pl --new --mcd --mcdproj --malt $(LANGUAGES)
	./train.pl --new --feat conll --maltsmf $(ALL_LANGUAGES)

train_new:
	./train.pl --new --malt --trans trans_fSpPcBhNsN,trans_fMpPcBhNsN,trans_fMpPcPhLsN,trans_fMpPcPhRsN $(ALL_LANGUAGES)

parse:
	./parse.pl --new --mcd --mcdproj --malt $(LANGUAGES)

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
	@./print_table.pl --mcd $(LANGUAGES)
	@./print_table.pl --mcdproj $(LANGUAGES)
	@./print_table.pl --malt $(LANGUAGES)

view:
	@treex -Lcs Print::ListMostDifferentTrees selector=maltnivreeagerBASE selector2=maltnivreeagerPDT threshold=0.9 -- /home/marecek/tectomt/share/data/resources/hamledt/cs/treex/trans_fMhLsNcBpP/parsed/001.treex.gz > diff.txt
	@ttred -l diff.txt

tex:
	./print_tex.pl > parsing_accuracy_table.tex
	@echo parsing_accuracy_table.tex should be commited as publications/papers/2011_cl_tree_conventions

rights:
	chmod -R g+w ${TMT_ROOT}/share/data/resources/hamledt/ 2>/dev/null || echo Done

clean:
	rm -r mcd-* mcp-* mlt-* smf-* parse-* eval-* *-cluster-run-*

clean_malt_dirs:
	rm -rf ${TMT_ROOT}/share/data/resources/hamledt/*/treex/*/parsed/malt_nivreeager
	rm -rf ${TMT_ROOT}/share/data/resources/hamledt/*/treex/*/parsed/malt_stacklazy
