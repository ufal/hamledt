LANGCODE=nhi
TREEBANK=nhi-ud215itml
UDCODE=nhi_itml
UDNAME=Western_Sierra_Puebla_Nahuatl-ITML
include ../common.mak

ALTSRCDIR1=/net/data/universal-dependencies-2.15/UD_$(UDNAME)
ALTSRCDIR2=/net/work/people/zeman/unidep/UD_$(UDNAME)
SOURCEDIR=$(ALTSRCDIR1)

source:
	cp $(SOURCEDIR)/$(UDCODE)-ud-test.conllu data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
