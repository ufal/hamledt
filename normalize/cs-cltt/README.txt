Czech Legal Text Treebank 2.0
released via LINDAT/CLARIN on 1.9.2017
http://hdl.handle.net/11234/1-2498
https://ufal.mff.cuni.cz/czech-legal-text-treebank

License: Attribution-ShareAlike 4.0 (CC BY-SA 4.0)
(Dan asked Bára and obtained her consent (mail 2016-04-21, "after consulting Martin Nečaský"); the original resource in Lindat has CC BY-NC-SA 4.0.)

size = 1121 sentences
Original tokenization does not match the UD tokenization; in UD, there are 35997 surface tokens, 36013 syntactic words.

See the manual for the annotations on the analytical layer:
http://ufal.mff.cuni.cz/pdt2.0/doc/pdt-guide/en/html/ch05.html

ÚFAL paths:
/net/data/treebanks/cs/cltt-1.0 ... Dan's copy of the published version 1.0, dated 2015-10-18
In an e-mail from 2017-02-19, Vincent wrote that he was planning to return to CLTT and fix errors before his dissertation D-day would come. So perhaps CLTT 2.0 is better (besides also adding a new annotation layer).
In an e-mail from 2016-05-12, Vincent mentioned their upcoming LREC (Portorož) poster about CLTT; the paper should mention also the UD conversion.
/net/data/treebanks/cs/cltt-2.0 ... Dan's copy of the published version 2.0, taken from http://hdl.handle.net/11234/1-2498
* same text as CLTT 1.0 (although changes in tokenization and sentence segmentation may lead to slightly different statistics)
* fixed some annotation errors?
* new annotation layer: accounting entities
* new annotation layer: semantic entity relations
https://github.com/ufal/cltt ... GitHub repository with Vincent's tools for CLTT but not with the data
I added part of the data (sentences/pml/*.[amw]) to the repository and cloned it to /net/work/projects/cltt/data/sentences/pml so that errors can be fixed upstream and versioned.
