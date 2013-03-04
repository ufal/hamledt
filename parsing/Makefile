ALL_LANGUAGES=ar bg bn ca cs da de el en es eu fa fi grc hi hu it ja la nl pt ro ru sl sv ta te tr
LANGUAGES=$(ALL_LANGUAGES)
#LANGUAGES=es eu fa fi grc hi hu it ja la nl pt ro ru sl sv ta te tr

train:
	./train.pl --mcd --mcdproj --malt $(LANGUAGES)
	./train.pl --feat conll --maltsmf $(LANGUAGES) 

parse:
	./parse.pl --new --mcd --mcdproj --malt --maltsmf $(LANGUAGES)

mytrain:
	./train.pl --new --retrain --feat conll --maltsmf --trans 000_orig ru 
	./train.pl --new --retrain --mcd --malt --mcdproj --trans 000_orig ru 

myparse:
	./parse.pl --mcd --malt --mcdproj --feat conll --maltsmf --trans 000_orig ru 

eval_samples:
	./eval_samples.pl $(ALL_LANGUAGES)
	# Wait until all the jobs are finished, then run
	# make significance

significance:
	./print_signif.pl > significance.tsv
	# grep positive significance.tsv


table:
	./print_table.pl --parser mcd --transform there-only $(LANGUAGES) > RESULTS-there-only.txt
	./print_table.pl --parser mcdproj --transform there-only $(LANGUAGES) >> RESULTS-there-only.txt
	./print_table.pl --parser malt --transform there-only $(LANGUAGES) >> RESULTS-there-only.txt
	./print_table.pl --parser maltsmf --transform there-only $(LANGUAGES) >> RESULTS-there-only.txt
	./print_table.pl --parser mcd $(LANGUAGES) > RESULTS.txt
	./print_table.pl --parser mcdproj $(LANGUAGES) >> RESULTS.txt
	./print_table.pl --parser malt $(LANGUAGES) >> RESULTS.txt
	./print_table.pl --parser maltsmf $(LANGUAGES) >> RESULTS.txt

mytable:
	./print_table.pl --parser malt --transform there-only $(LANGUAGES) 
	./print_table.pl --parser maltsmf --transform there-only $(LANGUAGES) 
	./print_table.pl --parser mcd --transform there-only $(LANGUAGES)  
	./print_table.pl --parser mcdproj --transform there-only $(LANGUAGES) 
	./print_table.pl --parser malt $(LANGUAGES) 
	./print_table.pl --parser maltsmf $(LANGUAGES) 
	./print_table.pl --parser mcd $(LANGUAGES)  
	./print_table.pl --parser mcdproj $(LANGUAGES) 

view:
	@treex -Lcs Print::ListMostDifferentTrees selector=maltnivreeagerBASE selector2=maltnivreeagerPDT threshold=0.9 -- /home/marecek/tectomt/share/data/resources/hamledt/cs/treex/trans_fMhLsNcBpP/parsed/001.treex.gz > diff.txt
	@ttred -l diff.txt

tex:
	./print_tex.pl > parsing_accuracy_table.tex
	@echo parsing_accuracy_table.tex should be commited as publications/papers/2011_cl_tree_conventions

rights:
	chmod -R g+w ${TMT_ROOT}/share/data/resources/hamledt/ 2>/dev/null || echo Done

clean:
	rm -rf /net/cluster/TMP/marecek/hamledt_parsing/*/*/*-cluster-run-*
	rm -f /net/cluster/TMP/marecek/hamledt_parsing/*/*/mlt*.sh*
	rm -f /net/cluster/TMP/marecek/hamledt_parsing/*/*/smf*.sh*
	rm -f /net/cluster/TMP/marecek/hamledt_parsing/*/*/mcd*.sh*
	rm -f /net/cluster/TMP/marecek/hamledt_parsing/*/*/mcp*.sh*
	rm -f /net/cluster/TMP/marecek/hamledt_parsing/*/*/p-*.sh*
	rm -rf /net/cluster/TMP/marecek/hamledt_parsing/*/*/malt_nivreeager
	rm -rf /net/cluster/TMP/marecek/hamledt_parsing/*/*/malt_stacklazy
