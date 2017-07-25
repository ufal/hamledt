LANGCODE=cs
TREEBANK=cs-fictree
UDCODE=cs_fictree
UDNAME=Czech-FicTree
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords
include ../common.mak

SOURCEDIR=FicTree
# The .vert format used in ÚTKL is like CoNLL but it has only 6 columns: ID FORM LEMMA TAG HEAD DEPREL.
# Convert it to CoNLL-X so that we can use the standard Treex reader.
source:
	cat $(SOURCEDIR)/*.vert | \
		perl -CDS -pe 's/^([0-9]+?)\t(.*?)\t(.*?)\t(.*?)\t([0-9]+?)\t(.*?)$$/$$1\t$$2\t$$3\t$$4\t$$4\t_\t$$5\t$$6\t_\t_/' \
		> data/source/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
