SHELL=bash
JOBS=100
VALLOG=validation.log
TESTLOG=test.log
# You can also specify the languages and datasets you are interested in (you should also set e.g. JOBS=10)
ALL_TREEBANKS={ar,bg,bn,ca,cs,cs-conll2007,da,de,el,en,es,et,eu,fa,fi,grc,hi,hr,hu,it,ja,la,nl,pl,pt,ro,ru,sk,sl,sv,ta,te,tr}
#TREEBANKS=$(ALL_TREEBANKS)
TREEBANKS=cs
#TREEBANKS={en,cs}
SETS={train,dev,test}
DATADIR=$(TMT_ROOT)/share/data/resources/hamledt
PFILES='!$(DATADIR)/$(TREEBANKS)/treex/01/$(SETS)/*.treex.gz'
UFILES='!$(DATADIR)/$(TREEBANKS)/treex/02/$(SETS)/*.treex.gz'
TRANSFFILES='!$(DATADIR)/$(TREEBANKS)/treex/trans*/$(SETS)/*.treex.gz'

PTESTS = \
	HamleDT::Test::AfunDefined \
	HamleDT::Test::AfunKnown \
	HamleDT::Test::AfunNotNR \
	HamleDT::Test::CoApAboveEveryMember \
	HamleDT::Test::MemberInEveryCoAp \
	HamleDT::Test::MemberInEveryCoord \
	HamleDT::Test::NonleafAuxC \
	HamleDT::Test::NonleafAuxP \
	HamleDT::Test::PrepIsAuxP \
	HamleDT::Test::LeafAux \
	HamleDT::Test::FinalPunctuation \
	HamleDT::Test::NonemptyAttr \
	HamleDT::Test::NounGovernsDet \
	HamleDT::Test::NoNewNonProj \
	HamleDT::Test::PredUnderRoot \
	HamleDT::Test::SubjectBelowVerb \
	HamleDT::Test::MaxOneSubject

UTESTS = \
	HamleDT::Test::UD::Determiners \
	HamleDT::Test::UD::CompoundPrepositions \
	HamleDT::Test::UD::Punctuation

validate:
	treex -p --survive --jobs=$(JOBS) --survive -- $(FILES)  2>&1 | tee $(VALLOG)
	@echo
	@echo Output of the validation test stored in $(VALLOG)

summarize_validation:
	grep -v TREEX $(VALLOG) || exit 0

# DZ: Removing --survive from the treex command below.
# Sometimes a job fails to produce .stderr, treex does not know what to do (it is supposed to pass the stderrs in the original order)
# but it does not kill the jobs because of the --survive flag.
# Každou chvíli to padá a v té změti souborů je skoro nemožné najít nějakou zprávu, co se stalo a na kterém stroji :-(
# Snad aby to člověk pouštěl takhle, většinou to nakonec jednou nespadne:
# while ! make utests ; do echo Nový pokus... ; done ; make table
ptests:
	@date
	treex -p --jobs=$(JOBS) --memory=4G --qsub="-q *@a*,*@b*,*@c*,*@f*,*@hyp*,*@l*,*@o*,*@p*,*@t*" \
	Util::SetGlobal Read::Treex from=$(PFILES) $(PTESTS) 2> test.err > $(TESTLOG)
	@date

utests:
	@date
	treex -p --jobs=$(JOBS) --memory=4G --qsub="-q *@a*,*@b*,*@c*,*@f*,*@hyp*,*@l*,*@o*,*@p*,*@t*" \
	Util::SetGlobal Read::Treex from=$(UFILES) $(UTESTS) 2> test.err > $(TESTLOG)
	@date

table:
	cat $(TESTLOG) | ./summarize_tests.pl

clean:
	rm -rf *.log ???-cluster-run-* test.err

transftest:
	treex  -p --jobs=$(JOBS) --survive  \
	HamleDT::Test::CoordStyle stylefrompath=1 \
	-- $(TRANSFFILES) 2> transftest.err > transftest.log

# TTBK=hi TEST=SubjectBelowVerb make ttred
#TTBK=hi
#TEST=LeafAux
FILELIST=ttred.$(TTBK).$(TEST).filelist
# A bug in ttred causes it to ignore the first line in the file list.
# Therefore we output a dummy line first.
ttred:
	echo > $(FILELIST)
	grep hamledt/$(TTBK)/treex $(TESTLOG) | grep -P '^HamleDT::Test::$(TEST)' | cut -f2 >> $(FILELIST)
	ttred -l $(FILELIST)

# If we work remotely (and remote graphical interface is not available), we may want to save the examples in a treex file,
# then download it via sftp and inspect it in a local installation of Tred.
# The fl2treex tool resides in $TMT_ROOT/treex/bin so we probably have it in $PATH already.
treex:
	echo > $(FILELIST)
	grep hamledt/$(TTBK)/treex $(TESTLOG) | grep -P '^HamleDT::Test::$(TEST)' | cut -f2 >> $(FILELIST)
	mkdir -p examples
	fl2treex $(FILELIST) -o examples -n 50

