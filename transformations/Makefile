PDT_READY= bg bn cs da de el hi la sl ta te
# ar invalid, grc deep recursion (why?)
SHELL=/bin/bash

test:
	@echo Test: a simple transformation applied on a single language
	./transform.pl -p cs AllPunctBelowTechRoot

all:
	./transform.pl --all


all_pdtready:
	./transform.pl -p $(PDT_READY) AllPunctBelowTechRoot

stats:
	treex Print::AtreeTransformationStats -p --jobs 50 -- \
	/net/projects/tectomt_shared//data/resources/normalized_treebanks/{bg,bn,cs,da,de,el,hi,la,sl,ta,te}/treex/trans*/*/*treex \
	> stats.raw

resume:
	cat stats.raw | resume_stats.pl