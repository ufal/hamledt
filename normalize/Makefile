SHELL=/bin/bash

# The list of LANGS is outdated but it is still used in the goals below.
LANGS= ar bg bn ca cs da de el en es et eu fa fi grc hi hu it ja la nl pt ro ru sk sl sv ta te tr
TREEBANKS = ar bg-ud11 bn ca cs da-ud11 de de-ud11 el-ud11 en en-ud11 es es-ud11 et eu-ud11 fa fa-ud11 fi-ud11 fi-ud11ftb fr-ud11 ga-ud11 grc he-ud11 hi hr-ud11 hu-ud11 id-ud11 it-ud11 ja la la-it nl pl pt ro ru sk sl sv-ud11 ta te tr
LANGS_PATTERN={$(shell echo $(LANGS) | tr ' ' ,)}
QCMD = /home/bojar/tools/shell/qsubmit
JOBS = 20

help:
	@echo 'make qall                              # normalize everything using SGE'
	@echo 'make source treex pdt LANGS="ar bg"    # non-parallel, only for Arabic and Bulgarian'
	@echo '# Inspect the Makefile for details'

# Non-parallel
all: source treex pdt

source: $(foreach l,$(LANGS),source-$(l))
source-%:
	cd $* && make source

treex: $(foreach l,$(LANGS),treex-$(l))
treex-%:
	cd $* && make dirs treex

prague: $(foreach l,$(LANGS),prague-$(l))
prague-%:
	cd $* && make prague

ud: $(foreach l,$(LANGS),ud-$(l))
ud-%:
	cd $* && make ud

# Parallel
qall: $(foreach l,$(LANGS),qall-$(l))
qall-%:
	$(QCMD) --jobname=$*-normalize "cd $* && make check-source dirs treex prague ud pmltq"

qprague: $(foreach l,$(LANGS),qprague-$(l))
qprague-%:
	$(QCMD) --jobname=$*-prague "cd $* && make prague"

qud: $(foreach l,$(LANGS),qud-$(l))
qud-%:
	$(QCMD) --jobname=$*-ud "cd $* && make ud"

qpmltq: $(foreach t,$(TREEBANKS),qpmltq-$(t))
qpmltq-%:
	$(QCMD) --jobname=$*-pmltq "cd $* && make pmltq"

qmorphostats: $(foreach t,$(TREEBANKS),qmorphostats-$(t))
qmorphostats-%:
	$(QCMD) --jobname=$*-most "cd $* && make morphostats"

clean:
	rm -f *-normalize.o* *-prague.o* *-ud.o* .qsubmit*
	rm -rf */???-cluster-run-*

TO_CONLL_SCEN=Write::CoNLLX language=mul deprel_attribute=afun pos_attribute=tag substitute={treex/001_pdtstyle}{conll} compress=1 to=.
# TODO:
# treex -p -j $(JOBS) $(TO_CONLL_SCEN) -- '!$(LANGS_PATTERN)/data/treex/001_pdtstyle/{train,test}/*.treex.gz'
# Parallel processing with client-server leads to saving all files to the current dir
treex-to-conll:
	echo $(LANGS_PATTERN)/data/treex/001_pdtstyle/{train,test}/*.treex.gz | tr " " "\n" |\
	$(QCMD) --jobs=$(JOBS) --sync "while read file; do treex $(TO_CONLL_SCEN) -- \$$file; done"
