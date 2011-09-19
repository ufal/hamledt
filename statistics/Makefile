TMP=tmp.txt

help:

collect:
	treex -p --jobs=100 Print::CoordStats --survive -- /net/projects/tectomt_shared/data/resources/normalized_treebanks/*/treex/*_pdtstyle/t*/*.treex.gz > $(TMP)

table:
	cat $(TMP) | ./create_tsv_table.pl > table.tsv