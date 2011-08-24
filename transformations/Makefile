PDT_READY= ar bg bn cs da de el grc hi la ro sl ta te

SHELL=/bin/bash

DATADIR=$(TMT_ROOT)/share/data/resources/normalized_treebanks/

test:
	@echo Test: a simple transformation applied on a single language
	./transform.pl -p cs AllPunctBelowTechRoot

runall:
	./transform.pl -p --allt $(PDT_READY) 2>&1 | tee runall.log


stats:
	treex Print::AtreeTransformationStats -p --jobs 50 -- \
	$(DATADIR)/*/treex/trans*/*/*treex \
	> stats.raw

resume_stats:
	cat stats.raw | resume_stats.pl

clean:
	rm stats.raw  -rf
	rm *cluster-run* -rf
	rm $(DATADIR)/*/*/trans* -rf
