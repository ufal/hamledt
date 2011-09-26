SHELL:=/bin/bash

LANGCODE=fi
DATADIR=$(TMT_ROOT)/share/data/resources/normalized_treebanks/$(LANGCODE)
IN       = $(DATADIR)/source
DIR0     = $(DATADIR)/treex/000_orig
DIR1     = $(DATADIR)/treex/001_pdtstyle
TREEX    = treex -L$(LANGCODE) -p
IMPORT   = Read::CoNLLX lines_per_doc=500
WRITE0   = Write::Treex file_stem=''
WRITE    = Write::Treex

prepare_source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat /net/data/finnish-dt/tdt-conll-dec2010-rev1/tdt-conll-dec2010-rev1.conll | perl -pe '$$_ = "" if(m/^\#/)' | /net/work/people/zeman/parsing/tools/split_conll.pl -phead 90 $(IN)/train.conll $(IN)/test.conll

prepare_dirs:
	@echo The root data directory for $(LANGCODE): $(DATADIR)
	mkdir -p $(DATADIR)
	if [ ! -e data ]; then ln -s $(DATADIR) data; fi
	mkdir -p $(DIR0)
	mkdir -p $(DIR0)/train
	mkdir -p $(DIR0)/test
	mkdir -p $(DIR1)
	mkdir -p $(DIR1)/train
	mkdir -p $(DIR1)/test
	chmod -R g+w data/. data/*

# run a conversion of the original data into the treex format
# and store the results in 000_orig/
to_treex:
	$(TREEX) $(IMPORT) from=$(IN)/train.conll $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORT) from=$(IN)/test.conll  $(WRITE0) path=$(DIR0)/test/

# make the trees as similar to the PDT-style as possible
# and store the result in 001_pdtstyle
SCEN1 = A2A::FI::CoNLL2PDTStyle A2A::SetSharedModifier
to_pdt:
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/train/ -- $(DIR0)/train/*.treex.gz
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/  -- $(DIR0)/test/*.treex.gz

# This goal serves development and debugging of the CoNLL2PDTStyle block.
test:
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/ -- $(DIR0)/test/*.treex.gz

checklog:
	checklog.sh -p ':\t*#.*|\tNode .*no afun\.' make.e.log

search:
	treex Util::Eval language=$(LANGCODE) \
	anode='print $$anode->parent->pos,"\n" if "infmod" eq $$anode->conll_deprel' -- \
	$(DATADIR)/treex/000_orig/*/*.treex | sort | uniq -c | sort -n

%.lst: %.inc
	treex Util::Eval language=$(LANGCODE) anode="'$$(< $<)'" -- \
	$(DATADIR)/treex/000_orig/*/*.treex | tee $@
	wc -l < $@

clean:
	rm -rf $(DATADIR)/treex


