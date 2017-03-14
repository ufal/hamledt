LANGCODE=kk
TREEBANK=kk-ud20
UDCODE=kk
UDNAME=Kazakh
include ../common.mak

SOURCEDIR=/net/work/people/zeman/unidep/UD_$(UDNAME)
source:
	cp $(SOURCEDIR)/$(UDCODE)-ud-dev.conllu data/source/dev.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
