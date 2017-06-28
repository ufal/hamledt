SHELL=bash
JOBS=100
VALLOG=validation.log
TESTLOG=test.log
# Ordinary users can set --priority from -1023 to 0 (0 being the highest priority). Treex default is -100.
# I am temporarily setting it rather high in order to sneak before Shadi's jobs.
CLUSTER=-p --jobs=$(JOBS) --priority=-1 --memory=4G --qsub="-q *@a*,*@b*,*@c*,*@f*,*@hyp*,*@l*,*@o*,*@p*,*@t*"

# Tests for Universal Dependencies.
UTESTS = \
	HamleDT::Test::UD::Root \
	HamleDT::Test::UD::SingleRoot \
	HamleDT::Test::UD::UnderscoreInForm \
	HamleDT::Test::UD::Determiners \
	HamleDT::Test::UD::Adpositions \
	HamleDT::Test::UD::Subjunctions \
	HamleDT::Test::UD::CcIsConjunction \
	HamleDT::Test::UD::CcIsLeaf \
	HamleDT::Test::UD::PronounIsNotMark \
	HamleDT::Test::UD::AdverbIsNotNmod \
	HamleDT::Test::UD::CompoundPrepositions \
	HamleDT::Test::UD::MweDoesNotCombineWithName \
	HamleDT::Test::UD::Reflexives \
	HamleDT::Test::UD::FutureIsNotXcomp \
	HamleDT::Test::UD::XcompHasNoSubject \
	HamleDT::Test::UD::MaxOneSubject \
	HamleDT::Test::UD::MaxOneDirectObject \
	HamleDT::Test::UD::LeftToRightRelations \
	HamleDT::Test::UD::CopulaIsAux \
	HamleDT::Test::UD::AuxChain \
	HamleDT::Test::UD::AuxpassImpliesSubjpass \
	HamleDT::Test::UD::Orphan \
	HamleDT::Test::UD::Punctuation \
	HamleDT::Test::UD::UnconvertedDependencies \
	HamleDT::Test::UD::ZZZSearch

# Tests for the Prague style.
PTESTS = \
	HamleDT::Test::DeprelKnown \
	HamleDT::Test::AuxGIsPunctuation \
	HamleDT::Test::AuxKAtEnd \
	HamleDT::Test::AuxKUnderRoot \
	HamleDT::Test::AuxVNotOnTop \
	HamleDT::Test::AuxXIsComma \
	HamleDT::Test::CoApAboveEveryMember \
	HamleDT::Test::MemberInEveryCoAp \
	HamleDT::Test::PunctUnderCoord \
	HamleDT::Test::PrepIsAuxP \
	HamleDT::Test::LeafAux \
	HamleDT::Test::FinalPunctuation \
	HamleDT::Test::NonemptyAttr \
	HamleDT::Test::NonParentAuxS \
	HamleDT::Test::NounGovernsDet \
	HamleDT::Test::NoNewNonProj \
	HamleDT::Test::SubjectUnderVerb \
	HamleDT::Test::MaxOneSubject

# You can also specify the languages and datasets you are interested in (you should also set e.g. JOBS=10)
SETS={train,dev,test}
# HAMLEDT_DATA must be set in your environment.
# P-treebanks are those that have the Prague conversion in 01, i.e. those whose UD version is created via Prague.
#PTREEBANKS=ar,bn,ca,cs,de,en,es,et,fa,grc,hi,ja,la,la-it,nl,pl,pt,ro,ru,sk,sl,ta,te,tr
#PTREEBANKS=ar,cs,el,grc,la,la-it,sk,sl,ta
PTREEBANKS=ca,es,nl
PFILES='!$(HAMLEDT_DATA)/{$(PTREEBANKS)}/treex/01/$(SETS)/*.treex.gz'
# C-treebanks are under correction. They come from the last release of UD and are being improved for the next release.
# They do not have Prague style in 01 but they have two UD folders: 02 is the input and 03 is the corrected output.
# The way it is written we cannot test both 02 and 03 at the same time: we would see errors from both aggregated under one treebank code.
CTREEBANKS=ug
CFILES='!$(HAMLEDT_DATA)/{$(CTREEBANKS)}/treex/03/$(SETS)/*.treex.gz'
# U-treebanks come from the last official release of Universal Dependencies. They do not have a Prague conversion.
# UD tests can be run on P-treebanks, U-treebanks and C-treebanks because all three have the UD version in 02.
U11TREEBANKS=bg-ud11,da-ud11,de-ud11,el-ud11,en-ud11,es-ud11,eu-ud11,fa-ud11,fi-ud11,fi-ud11ftb,fr-ud11,ga-ud11,he-ud11,hr-ud11,hu-ud11,id-ud11,it-ud11,sv-ud11
U12TREEBANKS=ar-ud12,bg-ud12,cs-ud12,cu-ud12,da-ud12,de-ud12,el-ud12,en-ud12,es-ud12,et-ud12,eu-ud12,fa-ud12,fi-ud12,fi-ud12ftb,fr-ud12,ga-ud12,got-ud12,grc-ud12,grc-ud12proiel,he-ud12,hi-ud12,hr-ud12,hu-ud12,id-ud12,it-ud12,ja-ud12ktc,la-ud12,la-ud12itt,la-ud12proiel,nl-ud12,no-ud12,pl-ud12,pt-ud12,pt-udt2,ro-ud12,sl-ud12,sv-ud12,ta-ud12
U13TREEBANKS=ar-ud13,bg-ud13,ca-ud13,cs-ud13,cs-ud13cac,cs-ud13cltt,cu-ud13,da-ud13,de-ud13,el-ud13,en-ud13,en-ud13esl,en-ud13lines,es-ud13,es-ud13ancora,et-ud13,eu-ud13,fa-ud13,fi-ud13,fi-ud13ftb,fr-ud13,ga-ud13,gl-ud13,got-ud13,grc-ud13,grc-ud13proiel,he-ud13,hi-ud13,hr-ud13,hu-ud13,id-ud13,it-ud13,ja-ud13ktc,kk-ud13,la-ud13,la-ud13ittb,la-ud13proiel,lv-ud13,nl-ud13,nl-ud13lassysmall,no-ud13,pl-ud13,pt-ud13,pt-ud13br,ro-ud13,ru-ud13,ru-ud13syntagrus,sl-ud13,sl-ud13sst,sv-ud13,sv-ud13lines,ta-ud13,tr-ud13,zh-ud13
U14TREEBANKS=ar-ud14,bg-ud14,ca-ud14,cop-ud14,cs-ud14,cs-ud14cac,cs-ud14cltt,cu-ud14,da-ud14,de-ud14,el-ud14,en-ud14,en-ud14esl,en-ud14lines,es-ud14,es-ud14ancora,et-ud14,eu-ud14,fa-ud14,fi-ud14,fi-ud14ftb,fr-ud14,ga-ud14,gl-ud14,gl-ud14treegal,got-ud14,grc-ud14,grc-ud14proiel,he-ud14,hi-ud14,hr-ud14,hu-ud14,id-ud14,it-ud14,ja-ud14,ja-ud14ktc,kk-ud14,la-ud14,la-ud14ittb,la-ud14proiel,lv-ud14,nl-ud14,nl-ud14lassysmall,no-ud14,pl-ud14,pt-ud14,pt-ud14br,ro-ud14,ru-ud14,ru-ud14syntagrus,sa-ud14,sk-ud14,sl-ud14,sl-ud14sst,sv-ud14,sv-ud14lines,swl-ud14,ta-ud14,tr-ud14,uk-ud14,ug-ud14,vi-ud14,zh-ud14
UTREEBANKS=ar-ud20,ar-ud20nyuad,be-ud20,bg-ud20,ca-ud20,cop-ud20,cs-ud20,cs-ud20cac,cs-ud20cltt,cu-ud20,da-ud20,de-ud20,el-ud20,en-ud20,en-ud20lines,en-ud20partut,es-ud20,es-ud20ancora,et-ud20,eu-ud20,fa-ud20,fi-ud20,fi-ud20ftb,fr-ud20,fr-ud20partut,fr-ud20sequoia,ga-ud20,gl-ud20,gl-ud20treegal,got-ud20,grc-ud20,grc-ud20proiel,he-ud20,hi-ud20,hr-ud20,hu-ud20,id-ud20,it-ud20,it-ud20partut,ja-ud20,kk-ud20,ko-ud20,la-ud20,la-ud20ittb,la-ud20proiel,lv-ud20,lt-ud20,nl-ud20,nl-ud20lassysmall,no-ud20bokmaal,no-ud20nynorsk,pl-ud20,pt-ud20,pt-ud20br,ro-ud20,ru-ud20,ru-ud20syntagrus,sa-ud20,sk-ud20,sl-ud20,sl-ud20sst,sv-ud20,sv-ud20lines,ta-ud20,tr-ud20,uk-ud20,ug-ud20,ur-ud20,vi-ud20,zh-ud20
ALLTREEBANKS=$(PTREEBANKS),$(UTREEBANKS),$(CTREEBANKS)
# Either assign $(ALLTREEBANKS) to TREEBANKS, or narrow the selection down to what we currently need to see.
TREEBANKS=de-ud20
#TREEBANKS=$(UTREEBANKS)
UFILES='!$(HAMLEDT_DATA)/{$(TREEBANKS)}/treex/02/$(SETS)/*.treex.gz'
# Manually checked Uyghur files:
UGFILES='!/net/work/people/zeman/unidep/UD_Uyghur/manually-checked-treex/*.treex.gz'

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
WINFILELIST=wintred.fl
# A bug in ttred causes it to ignore the first line in the file list.
# Therefore we output a dummy line first.
ttred:
	echo > $(FILELIST)
	grep hamledt-data/$(TTBK)/treex $(TESTLOG) | grep -P '^HamleDT::Test::$(TEST)' | cut -f2 >> $(FILELIST)
	ttred -l $(FILELIST)

wflist:
	echo > $(WINFILELIST)
	grep hamledt-data/$(TTBK)/treex $(TESTLOG) | grep -P '^HamleDT::Test::$(TEST)' | cut -f2 | perl -pe 's|/net/work/people/zeman/hamledt-data|C:/Users/Dan/Documents/Lingvistika/Data/treebanks/HamleDT|' >> $(WINFILELIST)

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
