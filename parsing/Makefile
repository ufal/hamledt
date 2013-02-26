#ALL_LANGUAGES=ar bg bn cs da de el en es fi hi hu it nl pt ro ru sl sv ta te tr
ALL_LANGUAGES=ar    bg    bn    ca    cs    da    de    el    en    es    et    eu    fi    grc   hi hu    it    ja    la    nl    pt    ro    ru    sl    sv    ta    te    tr
LANGUAGES=$(ALL_LANGUAGES)

train:
	#./train.pl --mcdproj --malt ar
	./train.pl --feat conll --maltsmf ar 

train_smf:
	#./train.pl --new --mcd --mcdproj --malt $(LANGUAGES)
	./train.pl --new --feat conll --maltsmf $(LANGUAGES)

mytrain:
	./train.pl --new --feat conll --maltsmf --trans 000_orig cs

train_new:
	./train.pl --new --malt --trans trans_fSpPcBhNsN,trans_fMpPcBhNsN,trans_fMpPcPhLsN,trans_fMpPcPhRsN $(ALL_LANGUAGES)

parse:
	./parse.pl --new --malt ar
	#./parse.pl --new --maltsmf $(LANGUAGES)

myparse:
	./parse.pl --maltsmf --trans 000_orig cs

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
	./print_table.pl --parser mcd --transform there-only $(LANGUAGES) > RESULTS-there-only.txt
	./print_table.pl --parser mcdproj --transform there-only $(LANGUAGES) >> RESULTS-there-only.txt
	./print_table.pl --parser malt --transform there-only $(LANGUAGES) >> RESULTS-there-only.txt
	./print_table.pl --parser maltsmf --transform there-only $(LANGUAGES) >> RESULTS-there-only.txt
	./print_table.pl --parser mcd $(LANGUAGES) > RESULTS.txt
	./print_table.pl --parser mcdproj $(LANGUAGES) >> RESULTS.txt
	./print_table.pl --parser malt $(LANGUAGES) >> RESULTS.txt
	./print_table.pl --parser maltsmf $(LANGUAGES) >> RESULTS.txt

mytable:
	./print_table.pl --parser malt --transform there-only ar

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
	rm -f /net/cluster/TMP/marecek/hamledt_parsing/*/*/parsed/mlt*.sh.*
	rm -f /net/cluster/TMP/marecek/hamledt_parsing/*/*/parsed/smf*.sh.*
	rm -f /net/cluster/TMP/marecek/hamledt_parsing/*/*/parsed/mcd*.sh.*
	rm -f /net/cluster/TMP/marecek/hamledt_parsing/*/*/parsed/mcp*.sh.*
	rm -rf /net/cluster/TMP/marecek/hamledt_parsing/*/*/parsed/malt_nivreeager
	rm -rf /net/cluster/TMP/marecek/hamledt_parsing/*/*/parsed/malt_stacklazy
