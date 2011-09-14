LANGUAGES=ar bg bn cs da de el grc hi la ro sl ta te
ALL_LANGUAGES=ar bg bn ca cs da de el en es et eu fi grc hi hu is it ja la nl pt ro ru sl sv ta te tr zh

train_mcd:
	./train.pl --mcd --malt ${LANGUAGES}

###!!! WARNING! Currently all three training flavors rewrite the same train.conll file!
train_smfconll:
	./train.pl --feat conll --new --maltsmf --trans 001_pdtstyle ${LANGUAGES}

train_smfiset:
	./train.pl --feat iset --new --maltsmf --trans 001_pdtstyle ${LANGUAGES}

parse_mcd:
	./parse.pl --mcd --malt ${LANGUAGES}

parse_smfconll:
	./parse.pl --feat conll --maltsmf --trans 001_pdtstyle ${LANGUAGES}

parse_smfiset:
	./parse.pl --feat iset --maltsmf --trans 001_pdtstyle ${LANGUAGES}

eval:
	./eval.pl lt ${ALL_LANGUAGES}

table:
	@./print_table.pl --malt $(ALL_LANGUAGES)
	@./print_table.pl --maltsmf $(ALL_LANGUAGES)
	@./print_table.pl --mcd $(ALL_LANGUAGES)
	@./print_table.pl --mcdproj $(ALL_LANGUAGES)

rights:
	chmod -R g+w ${TMT_ROOT}/share/data/resources/normalized_treebanks/ 2>/dev/null || echo Done

clean:
	rm -r mcd-* mcdproj-* malt-* parse-* eval-* *-cluster-run-*

clean_malt_dirs:
	rm -r ${TMT_ROOT}/share/data/resources/normalized_treebanks/*/treex/*/parsed/malt_nivreeager
	rm -r ${TMT_ROOT}/share/data/resources/normalized_treebanks/*/treex/*/parsed/malt_stacklazy
