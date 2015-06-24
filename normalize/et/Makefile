LANGCODE=et
TREEBANK=et
include ../common.mak

EXTRACT_BODY:=sed -n '/<body>/ {n;b c}; d;:c {\%</body>% {d};p;n;b c}'
source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	( echo '<corpus><body>'; \
	for file in /net/data/estonian-treebank/{arborest,piialaused,ratsepalaused,sul}.xml ; do \
		$(EXTRACT_BODY) $$file ; \
	done ; echo '</body></corpus>' ) | ./repair_encoding.pl > $(IN)/corpus.xml

treex:
	$(TREEX) Read::Tiger from=$(IN)/corpus.xml Filter::NthSentence n=10 keep=0 P2A::TigerET Write::Treex path=$(IN) file_stem='train+dev' compress=1
	$(TREEX) Read::Tiger from=$(IN)/corpus.xml Filter::NthSentence n=10 keep=1 P2A::TigerET Write::Treex path=$(DIR0)/test/  file_stem='001' compress=1
	$(TREEX) Read::Treex from=$(IN)/train+dev.treex.gz Filter::NthSentence n=10 keep=0 Write::Treex path=$(DIR0)/train/ file_stem='001' compress=1
	$(TREEX) Read::Treex from=$(IN)/train+dev.treex.gz Filter::NthSentence n=10 keep=1 Write::Treex path=$(DIR0)/dev/   file_stem='001' compress=1

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
