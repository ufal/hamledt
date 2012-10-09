# Rerunning one language (e.g. because its normalization changed):
# make LANGS=grc all
LANGS= ar bg bn ca cs da de el en es fa fi grc hi hu it ja la nl pt ro ru sl sv ta te tr
# not ready: et eu
SHELL=/bin/bash

DATADIR=${TMT_ROOT}/share/data/resources/hamledt/

all: prague stanford moscow


prague:
	./transform.pl --family Prague   --head right,left,mixed --shared head    --conjunction head    --punctuation between  $(LANGS)

stanford:
	./transform.pl --family Stanford --head right,left,mixed --shared nearest --conjunction between --punctuation previous $(LANGS)

moscow:
	./transform.pl --family Moscow   --head right,left,mixed --shared nearest --conjunction between --punctuation previous $(LANGS)

roundtrip:
	./roundtrip_stats.pl round_trip_*.txt | tee table_roundtrip.tsv

changes:
	treex -p --jobs 100 Print::AtreeTransformationStats -- '!$(DATADIR)/*/treex/trans*/*/*treex.gz' > changes.raw
	cat changes.raw | ./resume_stats.pl | tee table_changes.tsv

clean:
	rm -rf *cluster-run* tr-* changes.raw

real_clean_including_the_parsed_files_I_know_what_I_am_doing:
	rm -f changes.raw tr-*
	rm -rf *cluster-run*
	rm -rf $(DATADIR)/*/*/trans_*

