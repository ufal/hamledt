PDT_READY= ar bg bn cs da de el en es eu fi grc hi hu it ja la nl pt ro ru sl sv ta te tr
#PROBLEMS  sv  Invalid value 'CoordArg' in element <afun> of choice type 'afun.type'

SHELL=/bin/bash

DATADIR=$(TMT_ROOT)/share/data/resources/normalized_treebanks/

test:
	@echo Test: a simple transformation applied on a single language
	./transform.pl -p cs PunctBelowPrevNode

runall:
	./transform.pl --family Moscow,Stanford --head right,left $(PDT_READY)

pdt:
	./transform.pl --family Prague --head right --shared head,nearest --conjunction head --punctuation between $(PDT_READY)

head_nearest:
	./transform.pl --family Moscow,Stanford --head nearest $(PDT_READY)

conj_prev:
	./transform.pl --family Moscow --head right,left --conjunction previous --punctuation previous $(PDT_READY)


stats:
	treex Print::AtreeTransformationStats -p --jobs 50 -- \
	$(DATADIR)/*/treex/trans*/*/*treex.gz \
	> stats.raw

table:
	cat stats.raw | ./resume_stats.pl

clean:
	rm tr-*

real_clean_including_the_parsed_file_I_know_what_I_am_doing:
	rm stats.raw  -rf
	rm *cluster-run* -rf
	rm $(DATADIR)/*/*/trans* -rf
