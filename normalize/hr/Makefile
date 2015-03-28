LANGCODE=hr
TREEBANK=hr
include ../common.mak

TOOLS=/net/work/people/zeman/parsing/tools
source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat /net/data/treebanks/hr/setimes/setimes-2014-07-16-from-zeljko.conll | \
	  ../conll_only_nonempty_deprels.pl | \
	  ../conll_break_cycles.pl | \
	  $(TOOLS)/split_conll.pl -phead 80 $(IN)/train.conll $(IN)/devtest.conll
	cat $(IN)/devtest.conll | $(TOOLS)/split_conll.pl -phead 50 $(IN)/dev.conll $(IN)/test.conll
	rm $(IN)/devtest.conll

treex: conll_to_treex

