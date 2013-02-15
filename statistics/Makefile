TMP=tmp.txt
LANGS=*
JOBS=10

help:
	# check the Makefile

collect:
	#TODO: after normalization is redone, SetSharedModifier block will not be needed here
	treex -p --jobs=$(JOBS) A2A::SetSharedModifier Print::CoordStats --survive -- /net/projects/tectomt_shared/data/resources/hamledt/$(LANGS)/treex/*_pdtstyle/t*/*.treex.gz > $(TMP)

table:
	cat $(TMP) | ./create_tsv_table.pl > table.tsv
	@echo Updated table.tsv is supposed to be committed as https://svn.ms.mff.cuni.cz/svn/publications/papers/2011_cl_tree_conventions/generated_stats
