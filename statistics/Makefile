TMP=tmp.txt
LANGS=*
JOBS=10

HAMLEDT_TREEX_FILES=/net/projects/tectomt_shared/data/resources/hamledt/*/treex/001_pdtstyle/t*/*.treex.gz

help:
	# check the Makefile

collect:
	#TODO: after normalization is redone, SetSharedModifier block will not be needed here
	treex -p --jobs=$(JOBS) A2A::SetSharedModifier Print::CoordStats --survive -- /net/projects/tectomt_shared/data/resources/hamledt/$(LANGS)/treex/*_pdtstyle/t*/*.treex.gz > $(TMP)

table:
	cat $(TMP) | ./create_tsv_table.pl > table.tsv
	@echo Updated table.tsv is supposed to be committed as https://svn.ms.mff.cuni.cz/svn/publications/papers/2011_cl_tree_conventions/generated_stats

afunsprepare:
	zgrep -H '<afun>.*</afun>' /a/osh/zabokrtsky/tectomt/devel/share/data/resources/hamledt/*/treex/001_pdtstyle/*/*.treex.gz > prac

afunsfinish:
	cat prac | ./most_frequent_afuns_to_tex.pl > afuns_freq_table.tex

deprel2afun:
	treex -pj$(JOBS) Util::Eval anode='say join("\t",$$.language,$$.conll_deprel,$$.afun)'  -- '!$(HAMLEDT_TREEX_FILES)' > lang_deprel_afun.tsv
	cat lang_deprel_afun.tsv | ./mapping.pl > deprel_stat.txt
