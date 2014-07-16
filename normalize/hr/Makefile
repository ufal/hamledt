LANGCODE=hr
TREEBANK=hr
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat /net/data/treebanks/hr/setimes/setimes-2014-07-16-from-zeljko.conll | ../conll_only_nonempty_deprels.pl | ../conll_break_cycles.pl | /net/work/people/zeman/parsing/tools/split_conll.pl -phead 90 $(IN)/train.conll $(IN)/test.conll

treex: conll_to_treex

