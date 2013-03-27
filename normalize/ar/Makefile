LANGCODE=ar
include ../common.mak

POSTPROCESS2_SCEN_OPT:=A2A::Transform::CoordStyle from_style=fPhLsHcHpB style=fPhRsHcHpB

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s /net/data/conll/2007/ar/train.conll $(TRAIN)
	ln -s /net/data/conll/2007/ar/test.conll $(TEST)

treex: conll_to_treex


