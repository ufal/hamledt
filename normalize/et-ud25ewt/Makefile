LANGCODE=et
TREEBANK=et-ud25ewt
UDCODE=et_ewt
UDNAME=Estonian-EWT
# I do not maintain this UD treebank so I should modify my own fork instead of the official repository.
UDDIR=/net/work/people/zeman/unidep/forks
ENHANCEMENTS=case=1 coord=1 xsubj=0 relcl=1 empty=0
include ../common.mak

ALTSRCDIR1=/net/data/universal-dependencies-2.5/UD_$(UDNAME)
ALTSRCDIR2=/net/work/people/zeman/unidep/UD_$(UDNAME)
SOURCEDIR=$(ALTSRCDIR1)

source:
	cp $(SOURCEDIR)/$(UDCODE)-ud-train.conllu data/source/train.conllu
	cp $(SOURCEDIR)/$(UDCODE)-ud-test.conllu data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
