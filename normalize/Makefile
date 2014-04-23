SHELL=/bin/bash

# remainig langs: is zh
LANGS= ar bg bn ca cs da de el en es et eu fa fi grc hi hu it ja la nl pt ro ru sk sl sv ta te tr
LANGS_PATTERN={$(shell echo $(LANGS) | tr ' ' ,)}
QCMD = ${TMT_ROOT}/tools/cluster_utils/qruncmd
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

pdt: $(foreach l,$(LANGS),pdt-$(l))
pdt-%:
	cd $* && make pdt

# Parallel
qall: $(foreach l,$(LANGS),qall-$(l))
qall-%:
	/home/bojar/tools/shell/qsubmit --jobname=$*-normalize "cd $* && make check-source dirs treex pdt"

qpdt: $(foreach l,$(LANGS),qpdt-$(l))
qpdt-%:
	/home/bojar/tools/shell/qsubmit --jobname=$*-pdt "cd $* && make pdt"

clean:
	rm -f *-normalize.o* *-pdt.o* .qsubmit*
	rm -rf */???-cluster-run-*


TO_CONLL_SCEN=Write::CoNLLX language=mul deprel_attribute=afun pos_attribute=tag substitute={treex/001_pdtstyle}{conll} compress=1 to=.
# TODO: 
# treex -p -j $(JOBS) $(TO_CONLL_SCEN) -- '!$(LANGS_PATTERN)/data/treex/001_pdtstyle/{train,test}/*.treex.gz'
# Parallel processing with client-server leads to saving all files to the current dir
treex-to-conll:
	echo $(LANGS_PATTERN)/data/treex/001_pdtstyle/{train,test}/*.treex.gz | tr " " "\n" |\
	$(QCMD) --jobs=$(JOBS) --sync "while read file; do treex $(TO_CONLL_SCEN) -- \$$file; done"

treex_to_stanford: $(foreach l,$(LANGS),treex_to_stanford_$(l))
treex_to_stanford_%:
	cd $* && make treex_to_stanford

