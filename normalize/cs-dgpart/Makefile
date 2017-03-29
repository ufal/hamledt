LANGCODE=cs
TREEBANK=cs-dgpart
UDCODE=cs_dgpart
UDNAME=Czech-DGParT
HARMONIZE=Harmonize change_bundle_id=0
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords
include ../common.mak

# DFKI-Google Parallel Treebank
# Intermediate processing of the Czech part: take XPOSTAG+lemma annotation from Milan, process it as if it was Prague Dependency Treebank.

SOURCE=/home/straka/small_projects/conll17_cs_data/tagged-2-conllu-xpos/Data_Czech_morpho_1000.conllu
source:
	mkdir -p data/source
	cat $(SOURCE) | perl -pe 'if(m/^\d+\t/) { @f=split(/\t/); $$f[6]=0; $$f[7]="NR"; $$_=join("\t",@f); }' > data/source/test.conllu

treex:
	$(TREEX) \
		$(IMPORTU) from='!$(IN)/test.conllu' \
		Util::Eval anode='$$.set_tag($$.conll_pos)' \
		Write::Treex clobber=1 path=$(DIR0)/test/ compress=1

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud

