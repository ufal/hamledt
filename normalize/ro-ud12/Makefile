LANGCODE=ro
TREEBANK=ro-ud12
include ../common.mak

SOURCEDIR=/net/work/people/zeman/unidep/romanian-input
source:
	cp $(SOURCEDIR)/$(LANGCODE)-ud-train.conllu data/source/train.conllu
	cp $(SOURCEDIR)/$(LANGCODE)-ud-dev.conllu data/source/dev.conllu
	cp $(SOURCEDIR)/$(LANGCODE)-ud-test.conllu data/source/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex

# A specific target used only with this treebank.
# It takes UD as input, improves it and saves it to a new folder.
# It also immediately exports the corrected data to the conllu folder because that is what we will want to do anyway
# and we cannot use the common export_conllu target which reads from DIR2, not DIR3.
###!!! Due to a bug in Treex::Core::Node::Interset we must write CoNLLU before Treex.
###!!! After Write::Treex the Interset feature structure is corrupt (although the treex file is written correctly).
correct:
	$(QTREEX) Read::Treex from='!$(DIR2)/{train,dev,test}/*.treex.gz' \
	        HamleDT::RO::FixUD \
	        Write::CoNLLU substitute={$(SUBDIR2)}{$(SUBDIRCU)} compress=1 \
	        Write::Treex substitute={$(SUBDIRCU)}{$(SUBDIR3)} compress=1
	../export_ud.sh ro Romanian
