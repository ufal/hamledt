ALL_LANGUAGES=ar bg bn ca cs da de el en es et eu fi grc hi hu is it ja la nl pt ro ru sl sv ta te tr zh
#LANGUAGES=ar bg bn cs da de el grc hi la ro sl ta te
LANGUAGES=$(ALL_LANGUAGES)

train:
	./train.pl --new --mcd --malt $(LANGUAGES)
	./train.pl --new --feat conll --maltsmf $(LANGUAGES)

parse:
	./parse.pl --mcd --malt --maltsmf --feat conll $(LANGUAGES)

eval:
	./eval.pl $(ALL_LANGUAGES)

table:
	@./print_table.pl --malt $(ALL_LANGUAGES)
	@./print_table.pl --maltsmf $(ALL_LANGUAGES)
	@./print_table.pl --mcd $(ALL_LANGUAGES)
	@./print_table.pl --mcdproj $(ALL_LANGUAGES)

rights:
	chmod -R g+w ${TMT_ROOT}/share/data/resources/normalized_treebanks/ 2>/dev/null || echo Done

clean:
	rm -r mcd-* mcdproj-* malt-* mlt-* parse-* eval-* *-cluster-run-*

clean_malt_dirs:
	rm -r ${TMT_ROOT}/share/data/resources/normalized_treebanks/*/treex/*/parsed/malt_nivreeager
	rm -r ${TMT_ROOT}/share/data/resources/normalized_treebanks/*/treex/*/parsed/malt_stacklazy
