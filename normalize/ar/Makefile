LANGCODE=ar
TREEBANK=ar
UDCODE=ar_padt
UDNAME=Arabic-PADT
include ../common.mak

PADTDIR=/net/projects/padt/data/Prague
PADTSUBDIRS={AEP,ASB,EAT,HYT,NHR,XIN}
# The training-test data split has been prepared using the Print::TestFileNames Treex block.
# export PADTDIR=/net/projects/padt/data/Prague
### OLD:
# treex -Lar Read::PADT schema_dir=$TREEX/lib/Treex/Block/Read/PADT_schema 'from=!'$PADTDIR'/{AEP,ASB,EAT,HYT,NHR,XIN}/*.syntax.pml' Print::TestFileNames dev=1 > testfilereport.txt
### NEW:
# treex -Lar Read::PADT schema_dir=$TREEX/lib/Treex/Block/Read/PADT_schema 'from=!'$PADTDIR'/{AEP,ASB,EAT,HYT,NHR,XIN}/*.syntax.pml' HamleDT::AR::TestFileNames dev=1 dima=Overlap_between_XArabicUD_and_PAUDT.txt > testfilereport.txt
# cat testfilereport.txt | grep -P '^DEVFILE' | cut -f2 > devfilelist.txt
# cat testfilereport.txt | grep -P '^TESTFILE' | cut -f2 > testfilelist.txt

source:
	mkdir -p $(DATADIR)
	mkdir -p data/source/{train,dev,test}
	for i in `cat $(PADTDIR)/devfilelist.txt` ; do ln -s $$i.*.pml data/source/dev ; done
	for i in `cat $(PADTDIR)/testfilelist.txt` ; do ln -s $$i.*.pml data/source/test ; done
	for i in $(PADTDIR)/$(PADTSUBDIRS)/*.syntax.pml ; do \
	  idir=`dirname $$i` ; \
	  ibase=`basename $$i .syntax.pml` ; \
	  if [[ ! -e data/source/dev/$$ibase.syntax.pml && ! -e data/source/test/$$ibase.syntax.pml ]] ; then \
	    ln -s $$idir/$$ibase.syntax.pml data/source/train ; \
	    ln -s $$idir/$$ibase.morpho.pml data/source/train ; \
	    ln -s $$idir/$$ibase.words.pml  data/source/train ; \
	  fi ; \
	done

# Temporarily reverting to PADT r349, which has some unannotated sentences but it also has morphology in state that we can process.
# Note that different revisions of PADT use different XML schemas, so relying on the schemas copied to Treex may not succeed.
###!!! 28.11.2017: Temporarily working with uncompressed files. Cluster + gzip often ends with an error (content past document end, Treex::PML::Backend::PML).
treex:
	$(QTREEX) Read::PADT schema_dir=$(PADTDIR) 'from=!$(IN)/train/*.syntax.pml' A2A::RemoveUnannotatedSentences Write::Treex path=$(DIR0)/train
	$(QTREEX) Read::PADT schema_dir=$(PADTDIR) 'from=!$(IN)/dev/*.syntax.pml'   A2A::RemoveUnannotatedSentences Write::Treex path=$(DIR0)/dev
	$(QTREEX) Read::PADT schema_dir=$(PADTDIR) 'from=!$(IN)/test/*.syntax.pml'  A2A::RemoveUnannotatedSentences Write::Treex path=$(DIR0)/test
	rm -f $(DIR0)/{train,dev,test}/*.treex
	gunzip $(DIR0)/{train,dev,test}/*.treex.gz

# ud should map either to prague_to_ud, or to prague_to_ud_enhanced, or to conllu_to_treex.
ud: prague_to_ud_enhanced
