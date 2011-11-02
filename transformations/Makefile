# Rerunning one language (e.g. because its normalization changed):
# make LANGS=grc all
LANGS= ar bg bn cs da de el en es eu fi grc hi hu it ja la nl pt ro ru sl sv ta te tr

SHELL=/bin/bash

DATADIR=$(TMT_ROOT)/share/data/resources/normalized_treebanks/

test:
	@echo Test: a simple transformation applied on a single language
	./transform.pl -p cs PunctBelowPrevNode

all: prague stanford moscow


prague:
	./transform.pl --family Prague   --head right            --shared head    --conjunction head    --punctuation between  $(LANGS)

stanford:
	./transform.pl --family Stanford --head right,left,mixed --shared nearest --conjunction between --punctuation previous $(LANGS)

moscow:
	./transform.pl --family Moscow   --head right,left,mixed --shared nearest --conjunction between --punctuation previous $(LANGS)

stats:
	treex Print::AtreeTransformationStats -p --jobs 50 -- \
	$(DATADIR)/*/treex/trans*/*/*treex.gz \
	> stats.raw

table:
	cat stats.raw | ./resume_stats.pl

clean:
	rm tr-*

real_clean_including_the_parsed_files_I_know_what_I_am_doing:
	rm stats.raw  -rf
	rm *cluster-run* -rf
	rm $(DATADIR)/*/*/trans* -rf
