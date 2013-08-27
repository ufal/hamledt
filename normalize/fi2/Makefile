# NEW (July 2013) Turku Treebank
# Work in progress
# We need new Interset driver
LANGCODE=fi
include ../common.mak
ORIG_TREEBANK=${TMT_ROOT}/share/data/resources/treebanks/fi/tdt-2013-07-18/tdt-2013-07-18.conllx

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat $(ORIG_TREEBANK) | grep -v '^#' |\
	  /net/work/people/zeman/parsing/tools/split_conll.pl -phead 90 $(IN)/train.conll $(IN)/test.conll

treex: conll_to_treex
