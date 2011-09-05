LANGUAGES=ar bg bn cs da de el grc hi la ro sl ta te 
ALL_LANGUAGES=ar bg bn cs da de el en es et fi grc hi hu it ja la nl pt ro ru sl sv ta te tr

train:
	./train.pl --mcd --malt ${LANGUAGES}

parse:
	./parse.pl --mcd --malt ${LANGUAGES} 

table:
	echo "MALT PARSER:"
	./print_table.pl --malt ar bg bn ca cs da de el en es et eu fi grc hi
	./print_table.pl --malt hu is it ja la nl pt ro ru sl sv ta te tr zh
	echo "MCD PARSER (NON-PROJECTIVE):"
	./print_table.pl --mcd ar bg bn ca cs da de el en es et eu fi grc hi
	./print_table.pl --mcd hu is it ja la nl pt ro ru sl sv ta te tr zh
	#echo "MCD PARSER (PROJECTIVE):"
	#./print_table.pl --mcdproj ${LANGUAGES}

rights:
	chmod -R g+w ${TMT_ROOT}/share/data/resources/normalized_treebanks/*/treex/*/parsed

clean:
	rm -r mcd-* mcdproj-* malt-* parse-* *-cluster-run-*
