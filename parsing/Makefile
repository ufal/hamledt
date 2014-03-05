ALL_LANGUAGES=ar bg bn ca cs da de el en es eu fa fi grc hi hu it ja la nl pt ro ru sk sl sv ta te tr
#LANGUAGES=$(ALL_LANGUAGES)
LANGUAGES=ar bg ca da de en es fa hi hu it ja nl pt ro ru sv ta te
WDIR=/net/cluster/TMP/marecek/hamledt_parsing
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
