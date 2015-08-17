SHELL=/bin/bash

TREEBANKS = ar bg-ud11 bn ca cs da-ud11 de de-ud11 el-ud11 en en-ud11 es es-ud11 et eu-ud11 fa fa-ud11 fi-ud11 fi-ud11ftb fr-ud11 ga-ud11 grc he-ud11 hi hr-ud11 hu-ud11 id-ud11 it-ud11 ja la la-it nl pl pt ro ru sk sl sv-ud11 ta te tr
QCMD = /home/bojar/tools/shell/qsubmit
JOBS = 20

help:
	@echo 'make qall                                    # normalize everything using SGE'
	@echo 'make source treex prague ud LANGS="ar bg"    # non-parallel, only for Arabic and Bulgarian'
	@echo '# Inspect the Makefile for details'

# Non-parallel
all: source treex pdt

source: $(foreach t,$(TREEBANKS),source-$(t))
source-%:
	cd $* && make source

treex: $(foreach t,$(TREEBANKS),treex-$(t))
treex-%:
	cd $* && make dirs treex

prague: $(foreach t,$(TREEBANKS),prague-$(t))
prague-%:
	cd $* && make prague

ud: $(foreach t,$(TREEBANKS),ud-$(t))
ud-%:
	cd $* && make ud

conllu: $(foreach t,$(TREEBANKS),conllu-$(t))
conllu-%:
	cd $* && make export_conllu

# Parallel
qall: $(foreach t,$(TREEBANKS),qall-$(t))
qall-%:
	$(QCMD) --jobname=$*-normalize "cd $* && make check-source dirs treex prague ud pmltq"

qprague: $(foreach t,$(TREEBANKS),qprague-$(t))
qprague-%:
	$(QCMD) --jobname=$*-prague "cd $* && make prague"

qud: $(foreach t,$(TREEBANKS),qud-$(t))
qud-%:
	$(QCMD) --jobname=$*-ud "cd $* && make ud"

qpmltq: $(foreach t,$(TREEBANKS),qpmltq-$(t))
qpmltq-%:
	$(QCMD) --jobname=$*-pmltq "cd $* && make pmltq"

qmorphostats: $(foreach t,$(TREEBANKS),qmorphostats-$(t))
qmorphostats-%:
	$(QCMD) --jobname=$*-most "cd $* && make morphostats"

qfeaturestats: $(foreach t,$(TREEBANKS),qfeaturestats-$(t))
qfeaturestats-%:
	$(QCMD) --jobname=$*-fest "cd $* && make featurestats"

qconllu: $(foreach t,$(TREEBANKS),qconllu-$(t))
qconllu-%:
	$(QCMD) --jobname=$*-conllu "cd $* && make export_conllu"

clean:
	rm -f *-normalize.o* *-prague.o* *-ud.o* .qsubmit*
	rm -rf */???-cluster-run-*
