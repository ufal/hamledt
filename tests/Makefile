SHELL=bash
JOBS=200
VALLOG=validation.log
TESTLOG=test.log
#LANGS={en,cs}
LANGS=*
SETS={train,test}
FILES=$(TMT_ROOT)/share/data/resources/normalized_treebanks/$(LANGS)/treex/001_pdtstyle/$(SETS)/*treex

validate:
	treex -p --survive --jobs $(JOBS) -- $(FILES)  2>&1 | tee $(VALLOG)
	@echo
	@echo Output of the validation test stored in $(VALLOG)

resume_validation:
	cat $(VALLOG) | grep -v TREEX > errors.log

tests:
	treex -p --survive --jobs $(JOBS) \
	Util::SetGlobal language=mul \
	Test::A::CoApAboveEveryMember \
	Test::A::LeafAux \
	Test::A::MemberInEveryCoAp \
	Test::A::NonemptyAttr \
	Test::A::NonleafAuxC \
	Test::A::NonleafAuxP \
	Test::A::SubjectBelowVerb \
	-- $(FILES) 2>&1 | tee $(TESTLOG)

resume_tests:
	cat $(TESTLOG) | ./resume_tests.pl


clean:
	rm *.log