LANGCODE=hr
TREEBANK=hr-ud14
UDCODE=hr
UDNAME=Croatian
include ../common.mak

SOURCEDIR=/net/work/people/zeman/unidep/UD_$(UDNAME)
# We have to re-split the data in order to achieve 10K dev and test for the CoNLL 2017 shared task.
source:
	cat $(SOURCEDIR)/$(UDCODE)-ud-train.conllu | split_conll.pl -head 5300 data/source/train.conllu data/source/dev.conllu
	cat $(SOURCEDIR)/$(UDCODE)-ud-dev.conllu $(SOURCEDIR)/$(UDCODE)-ud-test.conllu > data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
