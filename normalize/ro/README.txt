Romanian Dependency Treebank
downloaded from: http://www.phobos.ro/roric/texts/xml/

License: unknown (but freely available on the web)

training size    = 3776 sentences, 33510 tokens
development size =  255 sentences,  2155 tokens
test size        =  266 sentences,  2640 tokens
total            = 4042 sentences, 36150 tokens

RDT is missing:
* diacritics (originally encoded in ASCII which has no Ă, Â, Î, Ș, Ț)
* punctuation
* complex grammatical structures (many sentences are split into clauses!)


The master's thesis of Mihaela Călăcean (2008) contains a description of RDT:
* the treebank was never described in any publicly available resource.
* the texts in RDT were strictly selected, eliminating, for instance, sentences with flexible word order and, in general, simplifying the complex structures.
* texts including complex ambiguities were avoided as much as possible, being removed from the corpus.
* newspapers articles, mostly on political and administrative subjects.
* The annotation was performed completely manually by a Romanian linguist, using only the graphical interface tool DGA. Since there was only
one annotator, the parts-of-speech (POS) and grammatical functions were relatively coherently used throughout the whole material.
* All the pieces of information regarding this phase of the RORIC-LING project were obtained through personal correspondence from Prof. Dr. Florentina Hristea, the coordinator of the RORIC-LING project.
* inconsistencies still occur, especially within the annotational scheme. Four of the twenty POS tags and one dependency type appear only in the first 6% of the material, reducing significantly the POS tagset for the rest of the material. For instance, verbs and adjectives in participle form are annotated as such only in the first part of the material. On the other hand, the definite article POS tag is present only in the last 90% of the material.
* All complex-compound sentences (including coordinated sentences) were split into simple sentences, therefore there are no subordinate clauses in the treebank.
* Proper names consisting of two or more elements were collapsed into one lexical element (E.g., ‘Tony Blair’ becomes a lexical unit ‘TonyBlair’).
* For evaluation purposes, I randomly selected 3% of the total number of sentences (i.e., 122 sentences) and manually corrected all the errors, thus creating a gold-standard material.
* The errors and inconsistencies detected in the material were fixed in the data sets used for the experiments. The corrected version of the treebank will be available on the TreebankWiki site.


