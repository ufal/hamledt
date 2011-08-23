LANGUAGES=ar bg bn cs da de el grc hi la sl ta te 

train:
	./train.pl --mcd --malt ${LANGUAGES}

parse:
	./parse.pl --mcd --malt ${LANGUAGES} 

table:
	echo "MALT PARSER:"
	./print_table.pl --malt ${LANGUAGES}
	echo "MCD PARSER:"
	./print_table.pl --mcd ${LANGUAGES} 

clean:
	rm -r mcd-* malt-* parse-* *-cluster-run-*
