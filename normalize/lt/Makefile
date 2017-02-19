LANGCODE=lt
TREEBANK=lt
UDCODE=lt
UDNAME=Lithuanian
include ../common.mak

SOURCEDIR=/net/data/treebanks/lt/ALKSNIS_v2
# Currently we select only a subset of the available documents.
source:
	for i in $(SOURCEDIR)/{administrative_docs,fiction,general_periodicals,specialised_periodicals}/*.pml ; do echo cp $i $(IN) ; cp $i $(IN) ; done

SCHEMADIR=$(SOURCEDIR)/antisDplus_schema.pml
treex:
	$(TREEX) \
		Read::AlksnisPML schema_dir=$(SCHEMADIR) from='!$(IN)/*.pml' \
		W2W::EstimateNoSpaceAfter \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/ compress=1

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
