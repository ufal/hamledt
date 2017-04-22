LANGCODE=hsb
TREEBANK=hsb
UDCODE=hsb
UDNAME=Upper_Sorbian
include ../common.mak

SOURCEDIR=/net/work/people/zeman/upper-sorbian-redmine/data
source:
	cp $(SOURCEDIR)/hsb-19-merged.conllu data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
