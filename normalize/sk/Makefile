LANGCODE=sk
include ../common.mak

SOURCEDIR=/net/work/people/zeman/slovallex
# Currently we select only a subset of the available documents.
SOURCEDOCS=Orwell1984 MojaPrvaLaska Mucska MilosFerko MilosFerko2 Patmos PsiaKoza Wikipedia
AFILES=$(foreach doc,$(SOURCEDOCS),$(wildcard $(SOURCEDIR)/$(doc)/anotator1/*.a))
MFILES=$(addsuffix .m,$(basename $(AFILES)))
WFILES=$(addsuffix .w,$(basename $(AFILES)))
source:
	./get_source_data.pl

SCHEMADIR=$(TMT_ROOT)/treex/lib/Treex/Block/Read/PDT_schema
treex:
	$(TREEX) Read::PDT schema_dir=$(SCHEMADIR) t_layer=0 from='!$(IN)/train/*.a' Write::Treex clobber=1 path=$(DIR0)/train/ compress=1
	$(TREEX) Read::PDT schema_dir=$(SCHEMADIR) t_layer=0 from='!$(IN)/test/*.a'  Write::Treex clobber=1 path=$(DIR0)/test/  compress=1

