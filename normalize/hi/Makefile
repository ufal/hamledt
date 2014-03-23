LANGCODE=hi
TREEBANK=hi
include ../common.mak
WX2UTF   = perl -I /home/zeman/lib $(TMT_ROOT)/tools/format_convertors/conll_to_conll/conll_wx2utf.pl -l $(LANGCODE)

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	perl -pe 's/\t-JOIN/\t-/g' < /net/data/hydt/2012-10-01-stazeno-hpst/HTB-ver0.5/conll/utf8/train/train-htb-ver0.5.gold.utf8.conll | ../conll_break_cycles.pl > $(IN)/train.conll
	perl -pe 's/\t-JOIN/\t-/g' < /net/data/hydt/2012-10-01-stazeno-hpst/HTB-ver0.5/conll/utf8/devel/devel-htb-ver0.5.gold.utf8.conll | ../conll_break_cycles.pl > $(IN)/test.conll

oldsource:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	perl -pe 's/\t-JOIN/\t-/g' < /net/data/icon2010/hi/training/hindi_training.conll | $(WX2UTF) | ../conll_break_cycles.pl > $(IN)/train.conll
	perl -pe 's/\t-JOIN/\t-/g' < /net/data/icon2010/hi/development/hindi_development.conll | $(WX2UTF) | ../conll_break_cycles.pl > $(IN)/test.conll

treex: conll_to_treex
