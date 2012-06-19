SHELL=/bin/bash

# remainig langs: is zh
LANGS= ar bg bn ca cs da de el en es et eu fa fi grc hi hu it ja la nl pt ro ru sl sv ta te tr

help:
	@echo 'make qall                              # normalize everything using SGE'
	@echo 'make source treex to_pdt LANGS="ar bg" # non-parallel, only for Arabic and Bengali'
	@echo '# Inspect the Makefile for details'

# Non-parallel
all: source treex pdt

source: $(foreach l,$(LANGS),source-$(l))
source-%:
	cd $* && make source

treex: $(foreach l,$(LANGS),treex-$(l))
treex-%:
	cd $* && make dirs treex

pdt: $(foreach l,$(LANGS),pdt-$(l))
pdt-%:
	cd $* && make pdt

# Parallel
qall: $(foreach l,$(LANGS),qall-$(l))
qall-%:
	/home/bojar/tools/shell/qsubmit --jobname=$*-normalize "cd $* && make check-source dirs treex pdt"

clean:
	rm -f *-normalize.o* .qsubmit*