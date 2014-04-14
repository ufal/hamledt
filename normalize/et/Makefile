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
	$(TREEX) Read::Tiger from=$(IN)/corpus.xml Filter::NthSentence n=10 keep=0 P2A::TigerET Write::Treex path=$(DIR0)/train/ clobber=1 compress=1
	$(TREEX) Read::Tiger from=$(IN)/corpus.xml Filter::NthSentence n=10 keep=1 P2A::TigerET Write::Treex path=$(DIR0)/test/  clobber=1 compress=1
