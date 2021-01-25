Prague Czech-English Dependency Treebank 2.0 Coref
released via LINDAT/CLARIN on 2016-03-30
http://hdl.handle.net/11234/1-1664
http://ufal.mff.cuni.cz/pcedt2.0/en/index.html

License:
- The English part is based on Penn Treebank 3 and therefore to use PCEDT, you need a license for Treebank 3 (https://catalog.ldc.upenn.edu/LDC99T42). By accepting this license and downloading the data you declare that you have a valid license for Treebank 3.
- The dependency annotation of the English data, as well as all the Czech data is licensed under the terms of Creative Commons Attribution-NonCommercial-ShareAlike 3.0 (CC BY-NC-SA 3.0)

Data split:

According to https://aclweb.org/aclwiki/Parsing_(State_of_the_art), the standard data split for (phrase-based) parsing evaluation is:
training ... sections 02-21
test ....... section  23

There is no mention of sections 00, 01, 22 and 24; but there is also no mention of development data, so these four sections could be dev.

ACL Wiki also mentions tagging split, de-facto standard since (Collins, 2002), which is different from parsing:
training ...... sections 00-18
development ... sections 19-21
test .......... sections 22-24

The CoNLL 2019 and 2020 shared tasks on Meaning Representation Parsing
(http://mrp.nlpl.eu/2019/index.php?page=4) also used datasets based on
the Wall Street Journal (Penn Treebank), and they employed the following
data split (no designated dev data):
training ... sections 00-20
test ....... the rest, i.e., 21-24? The web does not state it explicitly.

PROPOSAL: TAKE THE TAGGING SPLIT FROM THE ACL WIKI, I.E., 00-18 TRAIN, 19-21 DEV, 22-24 TEST.

Unlike the original conversion in the "cs" folder, here we try to take
advantage of tectogrammatical annotation where it is available.

See the manual for the annotations on the analytical layer:
http://ufal.mff.cuni.cz/pdt2.0/doc/pdt-guide/en/html/ch05.html
