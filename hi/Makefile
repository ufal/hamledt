LANGCODE=hi
include ../common.mak
WX2UTF   = perl -I /home/zeman/lib $(TMT_ROOT)/tools/format_convertors/conll_to_conll/conll_wx2utf.pl -l $(LANGCODE)

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	perl -pe 's/\t-JOIN/\t-/g' < /net/data/icon2010/hi/training/hindi_training.conll | $(WX2UTF) | ../conll_break_cycles.pl > $(IN)/train.conll
	perl -pe 's/\t-JOIN/\t-/g' < /net/data/icon2010/hi/development/hindi_development.conll | $(WX2UTF) | ../conll_break_cycles.pl > $(IN)/test.conll

treex: conll_to_treex
