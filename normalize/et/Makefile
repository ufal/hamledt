LANGCODE=et
include ../common.mak
DIR0     = $(DATADIR)/treex/0000_constituents
DIR1     = $(DATADIR)/treex/000_orig
DIR2     = $(DATADIR)/treex/001_pdtstyle
IMPORT   = Read::Tiger
WRITE0   = Write::Treex file_stem='001'

EXTRACT_BODY:=sed -n '/<body>/ {n;b c}; d;:c {\%</body>% {d};p;n;b c}'
source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	( echo '<corpus><body>'; \
	for file in /net/data/estonian-treebank/{arborest,piialaused,ratsepalaused,sul}.xml ; do \
		$(EXTRACT_BODY) $$file ; \
	done ; echo '</body></corpus>' ) | ./repair_encoding.pl > $(IN)/corpus.xml

# run a conversion of the original data into the treex format
# and store the results in 0000_constituents/
treex:
	$(TREEX) $(IMPORT) from=$(IN)/corpus.xml Filter::NthSentence n=10 keep=0 $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORT) from=$(IN)/corpus.xml Filter::NthSentence n=10 keep=1 $(WRITE0) path=$(DIR0)/test/

# converts trees from phrase to dependency style
SCEN1 = P2A::TigerET
dep:
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/train/ -- $(DIR0)/train/*.treex.gz
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/  -- $(DIR0)/test/*.treex.gz

# converts dependencies to pdt style dependencies
SCEN2 = A2A::ET::Harmonize A2A::SetSharedModifier A2A::SetCoordConjunction
pdt:
	$(TREEX) $(SCEN2) $(WRITE) path=$(DIR2)/train/ -- $(DIR1)/train/*.treex.gz
	$(TREEX) $(SCEN2) $(WRITE) path=$(DIR2)/test/  -- $(DIR1)/test/*.treex.gz
