SHELL=/bin/bash

TREEBANKS_UD11 = bg-ud11 cs-ud11 da-ud11 de-ud11 el-ud11 en-ud11 es-ud11 eu-ud11 fa-ud11 fi-ud11 fi-ud11ftb fr-ud11 ga-ud11 he-ud11 hr-ud11 hu-ud11 id-ud11 it-ud11 sv-ud11
TREEBANKS_UD12 = ar-ud12 bg-ud12 cs-ud12 cu-ud12 da-ud12 de-ud12 el-ud12 en-ud12 es-ud12 et-ud12 eu-ud12 fa-ud12 fi-ud12 fi-ud12ftb fr-ud12 ga-ud12 got-ud12 grc-ud12 grc-ud12proiel he-ud12 hi-ud12 hr-ud12 hu-ud12 id-ud12 it-ud12 ja-ud12ktc la-ud12 la-ud12itt la-ud12proiel nl-ud12 no-ud12 pl-ud12 pt-ud12 ro-ud12 sl-ud12 sv-ud12 ta-ud12
TREEBANKS_UD13 = ar-ud13 bg-ud13 ca-ud13 cs-ud13 cs-ud13cac cs-ud13cltt cu-ud13 da-ud13 de-ud13 el-ud13 en-ud13 en-ud13esl en-ud13lines es-ud13 es-ud13ancora et-ud13 eu-ud13 fa-ud13 fi-ud13 fi-ud13ftb fr-ud13 ga-ud13 gl-ud13 got-ud13 grc-ud13 grc-ud13proiel he-ud13 hi-ud13 hr-ud13 hu-ud13 id-ud13 it-ud13 ja-ud13ktc kk-ud13 la-ud13 la-ud13ittb la-ud13proiel lv-ud13 nl-ud13 nl-ud13lassysmall no-ud13 pl-ud13 pt-ud13 pt-ud13br ro-ud13 ru-ud13 ru-ud13syntagrus sl-ud13 sl-ud13sst sv-ud13 sv-ud13lines ta-ud13 tr-ud13 zh-ud13
TREEBANKS_UD14 = ar-ud14 bg-ud14 ca-ud14 cop-ud14 cs-ud14 cs-ud14cac cs-ud14cltt cu-ud14 da-ud14 de-ud14 el-ud14 en-ud14 en-ud14esl en-ud14lines es-ud14 es-ud14ancora et-ud14 eu-ud14 fa-ud14 fi-ud14 fi-ud14ftb fr-ud14 ga-ud14 gl-ud14 gl-ud14treegal got-ud14 grc-ud14 grc-ud14proiel he-ud14 hi-ud14 hr-ud14 hu-ud14 id-ud14 it-ud14 ja-ud14 ja-ud14ktc kk-ud14 la-ud14 la-ud14ittb la-ud14proiel lv-ud14 nl-ud14 nl-ud14lassysmall no-ud14 pl-ud14 pt-ud14 pt-ud14bosque pt-ud14br ro-ud14 ru-ud14 ru-ud14syntagrus sa-ud14 sk-ud14 sl-ud14 sl-ud14sst sv-ud14 sv-ud14lines swl-ud14 ta-ud14 tr-ud14 ug-ud14 uk-ud14 ur-ud14 vi-ud14 zh-ud14
TREEBANKS_UD20 = ar-ud20 ar-ud20nyuad be-ud20 bg-ud20 ca-ud20 cop-ud20 cs-ud20 cs-ud20cac cs-ud20cltt cu-ud20 da-ud20 de-ud20 el-ud20 en-ud20 en-ud20esl en-ud20lines en-ud20partut es-ud20 es-ud20ancora et-ud20 eu-ud20 fa-ud20 fi-ud20 fi-ud20ftb fr-ud20 fr-ud20partut fr-ud20sequoia ga-ud20 gl-ud20 gl-ud20treegal got-ud20 grc-ud20 grc-ud20proiel he-ud20 hi-ud20 hr-ud20 hu-ud20 id-ud20 it-ud20 it-ud20partut ja-ud20 ja-ud20ktc ko-ud20 la-ud20 la-ud20ittb la-ud20proiel lt-ud20 lv-ud20 nl-ud20 nl-ud20lassysmall no-ud20bokmaal no-ud20nynorsk pl-ud20 pt-ud20 pt-ud20br ro-ud20 ru-ud20 ru-ud20syntagrus sa-ud20 sk-ud20 sl-ud20 sl-ud20sst sv-ud20 sv-ud20lines swl-ud20 ta-ud20 tr-ud20 uk-ud20 ur-ud20 vi-ud20 zh-ud20
TREEBANKS = $(TREEBANKS_UD20)
QCMD = /home/bojar/tools/shell/qsubmit --priority=-1
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

qmwestats: $(foreach t,$(TREEBANKS),qmwestats-$(t))
qmwestats-%:
	$(QCMD) --jobname=$*-mwest "cd $* && make mwestats"

qconllu: $(foreach t,$(TREEBANKS),qconllu-$(t))
qconllu-%:
	$(QCMD) --jobname=$*-conllu "cd $* && make export_conllu"

clean:
	rm -f *-normalize.o* *-prague.o* *-ud.o* .qsubmit*
	rm -rf */???-cluster-run-*
