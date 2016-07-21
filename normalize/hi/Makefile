LANGCODE=hi
TREEBANK=hi
include ../common.mak
#WX2UTF   = perl -I /home/zeman/lib $(TMT_ROOT)/tools/format_convertors/conll_to_conll/conll_wx2utf.pl -l $(LANGCODE)
WX2UTF   = perl -I /home/zeman/lib ../../conll_wx2utf.pl -l $(LANGCODE)

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	perl -pe 's/\t-JOIN/\t-/g' < /net/data/hydt/2012-10-01-stazeno-hpst/HTB-ver0.5/conll/utf8/train/train-htb-ver0.5.gold.utf8.conll | ../conll_break_cycles.pl | \
	  split_conll.pl -head 11000 $(IN)/train.conll $(IN)/dev.conll
	perl -pe 's/\t-JOIN/\t-/g' < /net/data/hydt/2012-10-01-stazeno-hpst/HTB-ver0.5/conll/utf8/devel/devel-htb-ver0.5.gold.utf8.conll | ../conll_break_cycles.pl > $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
