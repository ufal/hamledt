LANGUAGES=ar bg bn cs da de el grc hi la sl ta te 

train:
	./train.pl --mcd --malt it

parse:
	./parse.pl --mcd --malt ${LANGUAGES} 

table:
	./print_table.pl --mcd --malt ${LANGUAGES} 

clean:
	rm mcd-* malt-* parse-*
	rm -r ???-cluster-run-?????
