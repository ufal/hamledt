SHELL=/bin/bash

TREEBANKS_UD11 = bg-ud11 cs-ud11 da-ud11 de-ud11 el-ud11 en-ud11 es-ud11 eu-ud11 fa-ud11 fi-ud11 fi-ud11ftb fr-ud11 ga-ud11 he-ud11 hr-ud11 hu-ud11 id-ud11 it-ud11 sv-ud11
TREEBANKS_UD12 = ar-ud12 bg-ud12 cs-ud12 cu-ud12 da-ud12 de-ud12 el-ud12 en-ud12 es-ud12 et-ud12 eu-ud12 fa-ud12 fi-ud12 fi-ud12ftb fr-ud12 ga-ud12 got-ud12 grc-ud12 grc-ud12proiel he-ud12 hi-ud12 hr-ud12 hu-ud12 id-ud12 it-ud12 ja-ud12ktc la-ud12 la-ud12itt la-ud12proiel nl-ud12 no-ud12 pl-ud12 pt-ud12 ro-ud12 sl-ud12 sv-ud12 ta-ud12
TREEBANKS = $(TREEBANKS_UD12)
QCMD = /home/bojar/tools/shell/qsubmit
JOBS = 37

help:
	@echo 'make qall                                        # normalize everything using SGE'
	@echo 'make source treex prague ud TREEBANKS="ar bg"    # non-parallel, only for Arabic and Bulgarian'
	@echo '# Inspect the Makefile for details'

# Non-parallel
all: source treex prague ud

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

qsource: $(foreach t,$(TREEBANKS),qsource-$(t))
qsource-%:
	$(QCMD) --jobname=$*-source "cd $* && make source"

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
