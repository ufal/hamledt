LANGCODE=de
TREEBANK=de-ud26gsd
UDCODE=de_gsd
UDNAME=German-GSD
PRE_FIXUD_BLOCKS=HamleDT::SetMiscNEFromPropn nelist=de_gsd-ud-1.0-named-entities.txt
include ../common.mak

ALTSRCDIR1=/net/data/universal-dependencies-2.6/UD_$(UDNAME)
ALTSRCDIR2=/net/work/people/zeman/unidep/UD_$(UDNAME)
SOURCEDIR=$(ALTSRCDIR2)

source:
	cp $(SOURCEDIR)/$(UDCODE)-ud-train.conllu data/source/train.conllu
	cp $(SOURCEDIR)/$(UDCODE)-ud-dev.conllu data/source/dev.conllu
	cp $(SOURCEDIR)/$(UDCODE)-ud-test.conllu data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex
