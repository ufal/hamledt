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

stats:
	treex Print::AtreeTransformationStats -p --jobs 100 -- '!$(DATADIR)/*/treex/trans*/*/*treex.gz' > stats.raw

table:
	cat stats.raw | ./resume_stats.pl | tee stats_table.tsv

clean:
	rm -rf *cluster-run* tr-*

real_clean_including_the_parsed_files_I_know_what_I_am_doing:
	rm -f stats.raw tr-*
	rm -rf *cluster-run*
	rm -rf $(DATADIR)/*/*/trans_*

