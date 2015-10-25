SHELL=bash
JOBS=100
VALLOG=validation.log
TESTLOG=test.log

# Tests for Universal Dependencies.
UTESTS = \
	HamleDT::Test::UD::Root \
	HamleDT::Test::UD::SingleRoot \
	HamleDT::Test::UD::Determiners \
	HamleDT::Test::UD::Adpositions \
	HamleDT::Test::UD::Subjunctions \
	HamleDT::Test::UD::CompoundPrepositions \
	HamleDT::Test::UD::Reflexives \
	HamleDT::Test::UD::FutureIsNotXcomp \
	HamleDT::Test::UD::XcompHasNoSubject \
	HamleDT::Test::UD::LeftToRightRelations \
	HamleDT::Test::UD::Punctuation \
	HamleDT::Test::UD::UnconvertedDependencies \
	HamleDT::Test::UD::ZZZSearch

# Tests for the Prague style.
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

# You can also specify the languages and datasets you are interested in (you should also set e.g. JOBS=10)
#ALL_TREEBANKS={ar,bg-ud11,bn,ca,cs,da-ud11,de,de-ud11,el-ud11,en,en-ud11,es,es-ud11,et,eu-ud11,fa,fa-ud11,fi-ud11,fi-ud11ftb,fr-ud11,ga-ud11,grc,he-ud11,hi,hr-ud11,hu-ud11,id-ud11,it-ud11,ja,la,la-it,nl,pl,pt,ro,ru,sk,sl,sv-ud11,ta,te,tr}
#TREEBANKS={cs,ar,et,grc,la,la-it,nl,pl,pt,ta,es-ud12,hi-ud12}
#TREEBANKS=$(ALL_TREEBANKS)
#TREEBANKS={cs,sk,pl,sl,hr,bg,ru}
SETS={train,dev,test}
# HAMLEDT_DATA must be set in your environment.
# P-treebanks are those that have the Prague conversion in 01, i.e. those whose UD version is created via Prague.
PTREBANKS=ar,bn,ca,cs,de,en,es,et,fa,grc,hi,ja,la,la-it,nl,pl,pt,ro,ru,sk,sl,ta,te,tr
PFILES='!$(HAMLEDT_DATA)/{$(PTREEBANKS)}/treex/01/$(SETS)/*.treex.gz'
# C-treebanks are under correction. They come from the last release of UD and are being improved for the next release.
# They do not have Prague style in 01 but they have two UD folders: 02 is the input and 03 is the corrected output.
# The way it is written we cannot test both 02 and 03 at the same time: we would see errors from both aggregated under one treebank code.
CTREEBANKS=es-ud12,hi-ud12
CFILES='!$(HAMLEDT_DATA)/{$(CTREEBANKS)}/treex/03/$(SETS)/*.treex.gz'
# U-treebanks come from the last official release of Universal Dependencies. They do not have a Prague conversion.
# UD tests can be run on P-treebanks, U-treebanks and C-treebanks because all three have the UD version in 02.
UTREEBANKS=bg-ud11,da-ud11,de-ud11,el-ud11,en-ud11,es-ud11,eu-ud11,fa-ud11,fi-ud11,fi-ud11ftb,fr-ud11,ga-ud11,he-ud11,hr-ud11,hu-ud11,id-ud11,it-ud11,sv-ud11
UFILES='!$(HAMLEDT_DATA)/{$(PTREEBANKS),$(UTREEBANKS),$(CTREEBANKS)}/treex/02/$(SETS)/*.treex.gz'

# Ordinary users can set --priority from -1023 to 0 (0 being the highest priority). Treex default is -100.
# I am temporarily setting it rather high in order to sneak before Shadi's jobs.
CLUSTER=-p --jobs=$(JOBS) --priority=-1 --memory=4G --qsub="-q *@a*,*@b*,*@c*,*@f*,*@hyp*,*@l*,*@o*,*@p*,*@t*"

utests:
	@date
	treex $(CLUSTER) \
	Util::SetGlobal Read::Treex from=$(UFILES) $(UTESTS) 2> test.err > $(TESTLOG)
	@date

ctests:
	@date
	treex $(CLUSTER) \
	Util::SetGlobal Read::Treex from=$(CFILES) $(UTESTS) 2> test.err > $(TESTLOG)
	@date

# Každou chvíli to padá a v té změti souborů je skoro nemožné najít nějakou zprávu, co se stalo a na kterém stroji :-(
# Snad aby to člověk pouštěl takhle, většinou to nakonec jednou nespadne:
# while ! make utests ; do echo Nový pokus... ; done ; make table
ptests:
	@date
	treex $(CLUSTER) \
	Util::SetGlobal Read::Treex from=$(PFILES) $(PTESTS) 2> test.err > $(TESTLOG)
	@date

table:
	cat $(TESTLOG) | ./summarize_tests.pl

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
	cat $(FILELIST) | refine_filelist.pl > examples/index.fl
	fl2treex $(FILELIST) -o examples -n 50

validate:
	treex -p --survive --jobs=$(JOBS) --survive -- $(FILES)  2>&1 | tee $(VALLOG)
	@echo
	@echo Output of the validation test stored in $(VALLOG)

summarize_validation:
	grep -v TREEX $(VALLOG) || exit 0

clean:
	rm -rf *.log *.filelist ???-cluster-run-* test.err
