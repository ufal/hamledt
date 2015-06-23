LANGCODE=bn
TREEBANK=bn
include ../common.mak
WX2UTF   = perl -I /home/zeman/lib $(TMT_ROOT)/tools/format_convertors/conll_to_conll/conll_wx2utf.pl -l $(LANGCODE)

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat /net/data/icon2010/bn/training/bangla_training.conll | $(WX2UTF) > $(IN)/train.conll
	cat /net/data/icon2010/bn/development/bangla_development.conll | $(WX2UTF) > $(IN)/dev.conll
	cat /net/data/icon2010/bn/testing-gold/bangla_testing.conll | $(WX2UTF) > $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
