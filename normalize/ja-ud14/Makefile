LANGCODE=ja
TREEBANK=ja-ud14
UDCODE=ja
UDNAME=Japanese
include ../common.mak

SOURCEDIR=/net/work/people/zeman/unidep/UD_Japanese-2017-02-15
# Remove the existing sentence ids, we have to generate new ones.
source:
	cat $(SOURCEDIR)/$(UDCODE)-ud-train.conllu | grep -v -P '\#\s*sent_id' > data/source/train.conllu
	cat $(SOURCEDIR)/$(UDCODE)-ud-dev.conllu   | grep -v -P '\#\s*sent_id' > data/source/dev.conllu
	cat $(SOURCEDIR)/$(UDCODE)-ud-test.conllu  | grep -v -P '\#\s*sent_id' > data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
