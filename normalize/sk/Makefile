LANGCODE=sk
TREEBANK=sk
include ../common.mak

SOURCEDIR=/net/work/people/zeman/slovallex
# Currently we select only a subset of the available documents.
source:
	./get_source_data.pl

SCHEMADIR=$(TMT_ROOT)/treex/lib/Treex/Block/Read/PDT_schema
treex:
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) t_layer=0 from='!$(IN)/train/*.a' \
		A2A::RemoveDuplicateNodes \
		Util::Eval atree='$$._normalize_node_ordering()' \
		Util::Eval anode='if($$.afun() eq "???") {$$.set_afun("NR")}' \
		Write::Treex clobber=1 path=$(DIR0)/train/ compress=1
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) t_layer=0 from='!$(IN)/test/*.a' \
		A2A::RemoveDuplicateNodes \
		Util::Eval atree='$$._normalize_node_ordering()' \
		Util::Eval anode='if($$.afun() eq "???") {$$.set_afun("NR")}' \
		Write::Treex clobber=1 path=$(DIR0)/test/  compress=1

# Parallelize normalization to make it faster.
###!!! Vypadá to, že za současného nastavení se pro train i test dohromady použije počet úloh z ...TRAIN_OPT a ...TEST_OPT se ignoruje.
TO_PDT_TRAIN_OPT := -p --jobs 52
