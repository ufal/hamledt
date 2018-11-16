LANGCODE=am
TREEBANK=am-ud23att
UDCODE=am_att
UDNAME=Amharic-ATT
include ../common.mak

SOURCEDIR=/net/data/universal-dependencies-2.3/UD_$(UDNAME)
ALTSRCDIR1=/net/data/universal-dependencies-2.3/UD_$(UDNAME)
ALTSRCDIR2=/net/work/people/zeman/udep/UD_$(UDNAME)

source:
	cp $(SOURCEDIR)/$(UDCODE)-ud-test.conllu data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
