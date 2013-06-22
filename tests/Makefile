SHELL=bash
JOBS=100
VALLOG=validation.log
TESTLOG=test.log
# You can also specify the languages and datasets you are interested in (you should also set e.g. JOBS=10)
#LANGS={en,cs}
LANGS=*
#LANGS=nl
SETS={train,test}
FILES='!$(TMT_ROOT)/share/data/resources/hamledt/$(LANGS)/treex/*_pdtstyle/$(SETS)/*.treex.gz'
TRANSFFILES='!$(TMT_ROOT)/share/data/resources/hamledt/$(LANGS)/treex/trans*/$(SETS)/*.treex.gz'


validate:
	treex -p --jobs=$(JOBS) --survive -- $(FILES)  2>&1 | tee $(VALLOG)
	@echo
	@echo Output of the validation test stored in $(VALLOG)

summarize_validation:
	grep -v TREEX $(VALLOG) || exit 0

# DZ: Removing --survive from the treex command below.
# Sometimes a job fails to produce .stderr, treex does not know what to do (it is supposed to pass the stderrs in the original order)
# but it does not kill the jobs because of the --survive flag.
tests:
	treex  -p --jobs=$(JOBS) \
	Util::SetGlobal \
	Test::A::AfunDefined            Test::A::AfunKnown           Test::A::AfunNotNR \
	Test::A::CoApAboveEveryMember   Test::A::MemberInEveryCoAp   Test::A::MemberInEveryCoord \
	Test::A::NonleafAuxC            Test::A::NonleafAuxP         Test::A::PrepIsAuxP \
	Test::A::LeafAux                Test::A::FinalPunctuation \
	Test::A::NonemptyAttr           Test::A::NounGovernsDet \
	Test::A::PredUnderRoot          Test::A::SubjectBelowVerb    Test::A::MaxOneSubject \
	-- $(FILES) 2> test.err > $(TESTLOG)

table:
	cat $(TESTLOG) | ./summarize_tests.pl


clean:
	rm -rf *.log ???-cluster-run-* test.err

transftest:
	treex  -p --jobs=$(JOBS) --survive  \
	Test::A::CoordStyle stylefrompath=1 \
	-- $(TRANSFFILES) 2> transftest.err > transftest.log

# TLNG=hi TEST=SubjectBelowVerb make ttred
#TLNG=hi
#TEST=LeafAux
FILELIST=ttred.$(TLNG).$(TEST).filelist
ttred:
	grep hamledt/$(TLNG)/treex $(TESTLOG) | grep $(TEST) | cut -f2 > $(FILELIST)
	ttred -l $(FILELIST)

