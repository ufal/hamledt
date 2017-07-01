===========================================================
Editing Universal Dependencies in Tred (focused on Windows)
===========================================================

Tred homepage: http://ufal.mff.cuni.cz/tred
Treex homepage: http://ufal.mff.cuni.cz/treex

To be able to work with Universal Dependencies in Tred, you have to convert the CoNLL-U files
to the Treex format. Treex can read and write both .conllu(.gz) and .treex(.gz):

  treex Read::CoNLLU from=myfile.conllu Write::Treex to=myfile.treex.gz
  treex Read::Treex from=myfile.treex.gz Write::CoNLLU to=myfile.conllu

In Tred, you have to use the EasyTreex extension, which contains Treex XML schemas.

Installing Tred with EasyTreex on Windows can be tricky. Some hints:
* Install Tred together with Strawberry Perl to ensure that you have the Perl version that is
  compatible with Tred.
* Follow the installation guide from the Treex homepage. Certain Perl modules have to be installed
  separately using cpanm, with tests disabled, before the actual Treex is installed.
* Launch Tred and install the EasyTreex extension when prompted.
* Make sure you have the latest version of the Treex XML schemas. If you installed Tred in
  Windows, the schemas Tred will use are under a path similar to this:
  C:\Users\Dan\AppData\Roaming\.tred.d\extensions\easytreex\resources
  (Replace "Dan" with your username. Note that the "AppData" folder is hidden by default.)
  The most recent version of the schemas can be found in the Treex repository:
  https://github.com/ufal/treex/tree/master/lib/Treex/Core/share/tred_extension/treex/resources


Tred macros to speed up UD annotation
-------------------------------------

I have created macros that facilitate certain frequently performed actions. Most of the macros
just assign a keyboard shortcut to change a tag or dependency label of a node (without the macro,
one has to double-click the node, navigate through a long list of attributes, double-click the
attribute, type down the new value and click OK; sometimes several related attributes have to be
edited together – for example, the part of speech is projected to several attributes in the
Treex format).

Default Tred macros are stored in the following file:
C:\Users\Dan\AppData\Roaming\tred.mac
(As mentioned above, replace "Dan" by your username, and note that "AppData" is probably hidden.)
The UD-related macros are stored in the tred-ud-treex.mac file next to the README.txt file
you are now reading. On my system, I have a copy of that file in
C:\Users\Dan\AppData\Roaming\tred-ud-treex.mac

I want these macros to be available whenever I am in Treex mode, i.e., I have opened a Treex
file in Tred. The Treex mode has its own default macro file that is defined in the Treex extension
and resides in
C:\Users\Dan\AppData\Roaming\.tred.d\extensions\easytreex\contrib\treex\contrib.mac
When I first tried to use my macros I did not seem to be able to make them automatically loaded
in a better way than edit the contrib.mac file and have my macro file included there. However,
now I have a new installation where the contrib.mac does not explicitly include my macro file,
yet the macros from C:\Users\Dan\AppData\Roaming\tred-ud-treex.mac are loaded when Tred starts,
and they are foregrounded when a Treex file is opened (i.e., the Treex mode is turned on).
I do not know whether the mere presence of a .mac file in the Roaming folder is enough to have
the file loaded.

If you want to modify the contents of the macro file, you should restart Tred for the new macros
to be available. The menu item Macros / Reload Macros does not work as expected; it has side
effects on tree rendering.

See https://ufal.mff.cuni.cz/pdt2.0/doc/tools/tred/ar01s14.html for documentation on how to
write Tred macros.

The following keyboard shortcuts are currently defined (note that the shortcuts are case-
sensitive, i.e. "A" means "Shift+a"). They always apply to the currently highlighted node:

******
DEPREL
******

a ... aux
A ... aux:pass
b ... obl
B ... obl:agent
c ... cop
C ... cc
d ... det
D ... det:nummod
e ... expl:pv
f ... fixed
F ... flat
g ... goeswith
G ... det:numgov
h ... advmod:emph
i ... iobj
j ... conj
k ... ccomp
l ... list
m ... nummod
M ... nummod:gov
n ... nmod
N ... appos
o ... obj
O ... orphan
p ... expl:pass
P ... parataxis
q ... amod
Q ... acl
r ... root
s ... nsubj
S ... csubj
t ... discourse
T ... vocative
u ... compound
v ... advmod
V ... advcl
x ... xcomp
y ... nsubj:pass
Y ... csubj:pass
z ... case
Z ... mark
; ... punct
? ... dep

****
UPOS
****

Ctrl+A ... ADJ
Ctrl+B ... ADV
Ctrl+C ... CCONJ
Ctrl+D ... DET
Ctrl+I ... INTJ
Ctrl+M ... NUM
Ctrl+N ... NOUN
Ctrl+P ... PRON
Ctrl+R ... ADP
Ctrl+S ... SCONJ
Ctrl+T ... PART
Ctrl+U ... AUX
Ctrl+V ... VERB
Ctrl+X ... X
Ctrl+Y ... SYM
Ctrl+Z ... PROPN
; ........ PUNCT (together with deprel punct)

********
Features
********

Ctrl+a ... case=acc
Ctrl+d ... case=dat
Ctrl+f ... gender=fem
Ctrl+g ... case=gen
Ctrl+i ... case=ins
Ctrl+j ... verbform=inf
Ctrl+l ... case=loc
Ctrl+m ... gender=masc
Ctrl+n ... case=nom
Ctrl+o ... gender=neut
Ctrl+p ... number=plur
Ctrl+s ... number=sing
Ctrl+v ... case=voc

*****
Other
*****

Shift+Space ... SpaceAfter=No
1 ............. move node left
2 ............. move node right
(menu) ........ merge node left
(menu) ........ remove node
