LANGCODE=ar
TREEBANK=ar
include ../common.mak

PADTDIR=/net/projects/padt/data/Prague
PADTSUBDIRS={AEP,ASB,EAT,HYT,NHR,XIN}
POSTPROCESS2_SCEN_OPT:=HamleDT::Transform::CoordStyle from_style=fPhLsHcHpB style=fPhRsHcHpB

source_old:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2007/ar/train.conll $(TRAIN)
	ln -s /net/data/conll/2007/ar/test.conll $(TEST)

treex_old: conll_to_treex

source:
	mkdir -p $(DATADIR)
	mkdir -p data/source/{train,test}
	for i in `cat $(PADTDIR)/testfilelist.txt` ; do ln -s $(PADTDIR)/$$i.*.pml data/source/test ; done
	for i in $(PADTDIR)/$(PADTSUBDIRS)/*.pml ; do if [[ ! -e data/source/test/`basename $$i` ]] ; then ln -s $$i data/source/train ; fi ; done

# Temporarily reverting to PADT r349, which has some unannotated sentences but it also has morphology in state that we can process.
# Note that different revisions of PADT use different XML schemas, so relying on the schemas copied to Treex may not succeed.
treex:
	treex Read::PADT schema_dir=$(PADTDIR) 'from=!$(IN)/train/*.syntax.pml' A2A::RemoveUnannotatedSentences Write::Treex path=$(DIR0)/train clobber=1
	treex Read::PADT schema_dir=$(PADTDIR) 'from=!$(IN)/test/*.syntax.pml'  A2A::RemoveUnannotatedSentences Write::Treex path=$(DIR0)/test  clobber=1
