ALL_LANGUAGES=ar bg bn cs da de el en es eu fi grc hi hu it ja la nl pt ro ru sl sv ta te tr
#LANGUAGES=ar bg bn cs da de el grc hi la ro sl ta te
LANGUAGES=$(ALL_LANGUAGES)

train:
	./train.pl --new --mcd --mcdproj --malt $(ALL_LANGUAGES)
#	./train.pl --new --feat conll --maltsmf $(LANGUAGES)

train_new:
	./train.pl --new --malt --trans trans_fSpPcBhNsN,trans_fMpPcBhNsN,trans_fMpPcPhLsN,trans_fMpPcPhRsN $(ALL_LANGUAGES)

parse:
	./parse.pl --malt --maltsmf --feat conll $(LANGUAGES)

eval:
	./eval.pl $(ALL_LANGUAGES)

table:
	@./print_table.pl --malt --filename uas.txt $(ALL_LANGUAGES)
	@./print_table.pl --maltsmf --filename uas.txt $(ALL_LANGUAGES)
	@./print_table.pl --mcd --filename uas.txt $(ALL_LANGUAGES)
	@./print_table.pl --mcdproj --filename uas.txt $(ALL_LANGUAGES)

tex:
	print_tex.pl > parsing_accuracy_table.tex
	@echo parsing_accuracy_table.tex should be commited as publications/papers/2011_cl_tree_conventions

rights:
	chmod -R g+w ${TMT_ROOT}/share/data/resources/normalized_treebanks/ 2>/dev/null || echo Done

clean:
	rm -r mcd-* mcp-* mlt-* smf-* parse-* eval-* *-cluster-run-*

clean_malt_dirs:
	rm -rf ${TMT_ROOT}/share/data/resources/normalized_treebanks/*/treex/*/parsed/malt_nivreeager
	rm -rf ${TMT_ROOT}/share/data/resources/normalized_treebanks/*/treex/*/parsed/malt_stacklazy
