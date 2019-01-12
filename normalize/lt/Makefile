LANGCODE=lt
TREEBANK=lt
UDCODE=lt_alksnis
UDNAME=Lithuanian-ALKSNIS
include ../common.mak

SOURCEDIR=/net/data/treebanks/lt/ALKSNIS_v2
SCHEMADIR=$(SOURCEDIR)/antisDplus_schema.pml
# Problem: The data files contain references to the schema. Either the schema
# must lie next to the data files (but then Treex will think it is another data
# file) or it cannot be read by our reader.
source:
	for i in $(SOURCEDIR)/{administrative_docs,fiction,general_periodicals,specialised_periodicals}/*.pml ; do echo cp $$i $(IN) ; cp $$i $(IN) ; done
	gzip $(IN)/*.pml
	gunzip $(IN)/antisDplus_schema.pml.gz

treex:
	$(TREEX) \
		Read::AlksnisPML schema_dir=$(SCHEMADIR) from='!$(IN)/*.pml.gz' \
		W2W::EstimateNoSpaceAfter \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/ compress=1

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
