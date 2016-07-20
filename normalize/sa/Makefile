LANGCODE=sa
TREEBANK=sa
UDCODE=sa
UDNAME=Sanskrit
#POST_UD_BLOCKS=W2W::Translit
include ../common.mak
# Temporary source dir for one sample file.
#SOURCEDIR=/net/work/projects/sanskrit
SOURCEDIR=/net/work/people/zeman/unidep/UD_Sanskrit
WX2UTF   = perl -I /home/zeman/lib $(TMT_ROOT)/tools/format_convertors/conll_to_conll/conll_wx2utf.pl -l hi

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat $(SOURCEDIR)/sa-ud-sample.conllu | $(WX2UTF) > $(IN)/train.conllu
	cp $(IN)/train.conllu $(IN)/dev.conllu
	cp $(IN)/train.conllu $(IN)/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
