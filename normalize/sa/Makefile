LANGCODE=sa
TREEBANK=sa
UDCODE=sa
UDNAME=Sanskrit
POST_UD_BLOCKS=W2W::Translit
include ../common.mak
# Temporary source dir for one sample file.
SOURCEDIR=/net/work/projects/sanskrit
#SOURCEDIR=/net/work/people/zeman/unidep/UD_Sanskrit
SLP2UTF  = perl -I /home/zeman/lib ../../conllu_slp2utf.pl -l sa

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat $(SOURCEDIR)/finaldata.conllu | $(SLP2UTF) > $(IN)/all.conllu
	$(TOOLS)/split_conll.pl < $(IN)/all.conllu -head 100 $(IN)/train.conllu $(IN)/dev+test.conllu
	$(TOOLS)/split_conll.pl < $(IN)/dev+test.conllu -head 50 $(IN)/dev.conllu $(IN)/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
