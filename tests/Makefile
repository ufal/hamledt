JOBS=120
VALLOG=validation.log

validate:
	treex -p --survive --jobs $(JOBS) -- $(TMT_ROOT)/share/data/resources/normalized_treebanks/*/treex/001_pdtstyle/*/*treex 2>&1 | tee $(VALLOG)
	@echo
	@echo Output of the validation test stored in $(VALLOG)

resume:
	cat $(VALLOG) | grep -v TREEX > errors.log

clean:
	rm *.log