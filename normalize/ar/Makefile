LANGCODE=ar
include ../common.mak

PADTDIR=/net/projects/padt/data/Prague/{AEP,ASB,EAT,HYT,NHR,XIN}
POSTPROCESS2_SCEN_OPT:=A2A::Transform::CoordStyle from_style=fPhLsHcHpB style=fPhRsHcHpB

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2007/ar/train.conll $(TRAIN)
	ln -s /net/data/conll/2007/ar/test.conll $(TEST)

treex: conll_to_treex

source2:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	###!!! We have yet to decide what part will be held out for evaluation.
	for i in $(PADTDIR)/*.pml ; do ln -s $i $(IN) ; done

treex2:
	treex Read::PADT 'from=!$(IN)/*.syntax.pml' $(WRITE0) path=$(DIR0)/train/
	###!!!treex Read::PADT 'from=!$(IN)/*.syntax.pml' $(WRITE0) path=$(DIR0)/test/
