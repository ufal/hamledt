LANGCODE=ur
TREEBANK=ur-ud14
UDCODE=ur
UDNAME=Urdu
include ../common.mak

SOURCEDIR=/net/work/people/zeman/unidep/UD_$(UDNAME)
source:
	cat $(SOURCEDIR)/$(UDCODE)-ud-train.conllu | ../conll_break_cycles.pl > data/source/train.conllu
	cat $(SOURCEDIR)/$(UDCODE)-ud-dev.conllu   | ../conll_break_cycles.pl > data/source/dev.conllu
	cat $(SOURCEDIR)/$(UDCODE)-ud-test.conllu  | ../conll_break_cycles.pl > data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
