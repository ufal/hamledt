LANGCODE=de
TREEBANK=de-ud13
UDCODE=de
UDNAME=German
include ../common.mak

SOURCEDIR=/net/work/people/zeman/unidep/UD_$(UDNAME)
source:
	cp $(SOURCEDIR)/$(UDCODE)-ud-train.conllu data/source/train.conllu
	cp $(SOURCEDIR)/$(UDCODE)-ud-dev.conllu data/source/dev.conllu
	cp $(SOURCEDIR)/$(UDCODE)-ud-test.conllu data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex

# Add lemmas and morphological features for the next release. This goal is adapted from the common
# goal "fixud". It takes UD as input, improves it, saves it to a new folder and exports it to CoNLL-U.
# The tagger sets the "tag" attribute and rewrites our universal POS tag. The universal tag will
# be restored later automatically from Interset, but we must copy the tag from the tagger to conll/pos.
tag:
	$(QTREEX) Read::Treex from='!$(DIR2)/{train,dev,test}/*.treex.gz' \
	        Util::Eval anode='$$.wild->{upos} = $$.tag()' \
	        W2A::TagTreeTagger lemmatize=1 \
	        Util::Eval anode='$$.set_conll_pos($$.tag()); $$.set_tag($$.wild->{upos}); delete($$.wild->{upos})' \
	        HamleDT::DE::FixUD \
	        Write::CoNLLU substitute={$(SUBDIR2)}{$(SUBDIRCU)} compress=1 \
	        Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR3)} compress=1
	../export_ud.sh $(UDCODE) $(UDNAME)
