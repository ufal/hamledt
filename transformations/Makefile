#PDT_READY= ar bg bn cs ca da de el en es
#PDT_READY= et fi grc hi hu it ja la nl pt
PDT_READY= ro ru sl sv ta te tr

SHELL=/bin/bash

DATADIR=$(TMT_ROOT)/share/data/resources/normalized_treebanks/

test:
	@echo Test: a simple transformation applied on a single language
	./transform.pl -p cs PunctBelowPrevNode

runall:
	./transform.pl -p --allt $(PDT_READY) 2>&1 | tee runall.log


stats:
	treex Print::AtreeTransformationStats -p --jobs 50 -- \
	$(DATADIR)/*/treex/trans*/*/*treex.gz \
	> stats.raw

table:
	cat stats.raw | ./resume_stats.pl

real_clean_including_the_parsed_file_I_know_what_I_am_doing:
	rm stats.raw  -rf
	rm *cluster-run* -rf
	rm $(DATADIR)/*/*/trans* -rf
