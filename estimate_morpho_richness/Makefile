FORMS=forms.txt


all: print_forms summarize

print_forms:
	treex -p --survive --jobs 200 Util::Eval bundle='my $$z=$$bundle->get_zone(qw(mul)); my $$l=$$z->language; foreach my $$node ($$z->get_atree->get_descendants({ordered=>1})) {print $$l."\t".$$node->form."\n"} ' -- /net/projects/tectomt_shared/data/resources/hamledt/*/treex/001_pdtstyle/t*/*.treex  > $(FORMS)

summarize:
	cat $(FORMS) | ./unseen_words_percentage.pl
