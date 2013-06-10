# Rerunning one language (e.g. because its normalization changed):
# make LANGS=grc all
LANGS=ar bg bn ca cs da de el en es eu fa fi grc hi hu it ja la nl pt ro ru sl sv ta te tr
SHELL=/bin/bash
L=en

DATADIR=${TMT_ROOT}/share/data/resources/hamledt/

all: prague stanford moscow

prague:
	./transform.pl --family Prague   --head right,left,mixed --shared head    --conjunction head    --punctuation between  --from 001_pdtstyle --prefix trans $(LANGS)

stanford:
	./transform.pl --family Stanford --head right,left,mixed --shared nearest --conjunction between --punctuation previous --from 001_pdtstyle --prefix trans $(LANGS)

moscow:
	./transform.pl --family Moscow   --head right,left,mixed --shared nearest --conjunction between --punctuation previous --from 001_pdtstyle --prefix trans $(LANGS)

condolisate:
	./transform_to_base.pl $(LANGS)
	
transform condolisated:
	./transform.pl --family Prague   --head right,left,mixed --shared head    --conjunction head    --punctuation between  --recompute --from 002_base --prefix tr $(LANGS)
	./transform.pl --family Stanford --head right,left,mixed --shared nearest --conjunction between --punctuation previous --recompute --from 002_base --prefix tr $(LANGS)
	./transform.pl --family Moscow   --head right,left,mixed --shared nearest --conjunction between --punctuation previous --recompute --from 002_base --prefix tr $(LANGS)

roundtrip:
	./roundtrip_stats.pl round_trip_*.txt | tee table_roundtrip.tsv

worst_roundtrip:
	cat round_trip*.txt | perl -nle 's/^file=([^ ]+ ).*UAS=(.*)/\2\t\1/ && print' | sort | head

changes:
	treex -p --jobs 100 Print::AtreeTransformationStats -- '!$(DATADIR)/*/treex/trans*/*/*treex.gz' > changes.raw
	cat changes.raw | ./resume_stats.pl | tee table_changes.tsv

clean:
	rm -rf *cluster-run* tr-* changes.raw

real_clean_including_the_parsed_files_I_know_what_I_am_doing:
	rm -f changes.raw tr-*
	rm -rf *cluster-run*
	rm -rf $(DATADIR)/*/*/trans_*

diff:
	@treex -L$(L) Print::ListMostDifferentTrees selector='before' selector2='inverse' selector3='before' threshold=1 -- /home/marecek/tectomt/share/data/resources/hamledt/$(L)/treex/trans_fMhL*/test/001.treex.gz > diff.txt
	@ttred -l diff.txt


