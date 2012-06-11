LANGCODE=fi
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat /net/data/finnish-dt/tdt-conll-dec2010-rev1/tdt-conll-dec2010-rev1.conll | perl -pe '$$_ = "" if(m/^\#/)' | /net/data/finnish-dt/conll-restructure-finnish-tags.pl | /net/work/people/zeman/parsing/tools/split_conll.pl -phead 90 $(IN)/train.conll $(IN)/test.conll

treex: conll_to_treex

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
