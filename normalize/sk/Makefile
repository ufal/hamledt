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
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/train/*.a' \
		A2A::RemoveDuplicateNodes \
		Util::Eval atree='$$._normalize_node_ordering()' \
		Util::Eval anode='if($$.afun() eq "???") {$$.set_afun("NR")}' \
		A2A::RemoveUnannotatedSentences \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/ compress=1
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/dev/*.a' \
		A2A::RemoveDuplicateNodes \
		Util::Eval atree='$$._normalize_node_ordering()' \
		Util::Eval anode='if($$.afun() eq "???") {$$.set_afun("NR")}' \
		A2A::RemoveUnannotatedSentences \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/  compress=1
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/test/*.a' \
		A2A::RemoveDuplicateNodes \
		Util::Eval atree='$$._normalize_node_ordering()' \
		Util::Eval anode='if($$.afun() eq "???") {$$.set_afun("NR")}' \
		A2A::RemoveUnannotatedSentences \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/  compress=1
