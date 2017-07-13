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

# Update July 2017: It is now normal that very small treebanks have test data only. We will not officially split it until it grows significantly larger.
# The "finaldata.conllu" file in the Sanskrit project is now a UD v2 conversion of the original data, and it uses the Devanagari script.
# Hence we no longer call $(SLP2UTF) (but we keep the path to the script here because we will need it when we want to add more data).
source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat $(SOURCEDIR)/finaldata.conllu > $(IN)/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
