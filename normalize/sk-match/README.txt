Dan Zeman took the unreleased treebank data from the Slovak National Corpus, merged annotations from two annotators
where they were available and took only those sentences where the two annotators perfectly agreed. The resulting
data should be the most reliable part of the treebank but it is biased towards short and easy sentences. This part
is processed here as sk-match.

IMPORTANT: IF YOU NEED TO RE-RUN (AND POSSIBLY MODIFY) THE PROCESSING OF THE ORIGINAL DATA RECEIVED FROM BRATISLAVA,
GO TO ../sk/ AND CHECK THE FILE poznamky.txt (IN CZECH).

The rest of this README file is the original README.txt I wrote for the Slovak Treebank in HamleDT:

=======================================================================================================================



Slovak National Corpus (SNK)

We got this data on request, directly from the authors, for two purposes:
experiments with Slovak t-layer and Slovallex (Jan-Feb 2014 visit of Daniela Majchráková at ÚFAL, working with Eda
    Bejček and Ondra Dušek)
experiments with HamleDT (Zdeněk Žabokrtský asked Radovan Garabík, the main contact person, about this)

License: no agreement at the moment; so: research only, do not distribute, cite their paper in publications.
The treebank has not been released yet. The data we have often contain two independent annotations of the same file,
unmerged. In these cases we take always "Annotator 1". Some texts have just one annotation.

https://svn.ms.mff.cuni.cz/svn/slovallex/trunk/
/ha/home/zeman/network/slovallex

As there is no official training/test data split, we designed our own.
Every tenth file goes to test, the immediately following file goes to development.
The rest goes to train.

training size    = 51913 sentences, 814561 tokens
development size =  5833 sentences,  93404 tokens
test size        =  5492 sentences,  85903 tokens



Morphology (lemmas and tags) seems to be mostly annotated manually. Agáta Karčová (see copy of her message below) has
confirmed this for seven texts. Dan Zeman inspected sample files of all texts and found only one (BallekPomocnik) that
apparently was tagged automatically. One other text (DominoForum) seemed to have manual morphology but severely
damaged sentence segmentation. Provided that one file is a good representative of all other files in the same folder,
all texts but these two seem to be reasonably trustworthy.



Subject: informácia o syntakticky anotovaných textoch
Date: Fri, 14 Feb 2014 16:09:06 +0100
From: Agata Karcova <agatak@korpus.juls.savba.sk>
To: Jan Hajič <hajic@ufal.mff.cuni.cz>

Dobrý deň,

posielam základné informácie o opravách syntakticky anotovaných textov
(R. Brída, A. Karčová), ktoré sme nahrali do repozitára SVN (R. Garabík).
Prvú časť súborov sme nahrávali koncom januára 2014, druhú časť 13.
februára 2014.
Pred nahratím sme urobili niekoľko kontrol a základných opráv, ktoré sa
zameriavali hlavne na to, aby:

- každý text bol vo formátoch a, m, w
- texty, ktoré boli zanotované dvojmo, boli rozdelené do priečinkov
anotator1, anotator2
- názvy súborov navzájom korešpondovali a každý obsahoval informáciu o
anotátorovi (identifikátor je názov súboru po znak '_')
- boli zaradené len zanotované súbory (v niektorých sa ešte môžu
objavovať otázniky (???) namiesto určenia vetného člena, ale nemali by
tam byť celé nezanotované súbory)
- texty neobsahovali chybne kódované znaky (opravili sme niekoľko
chybných lem aj tvarov, zle kódované úvodzovky; niekoľko chybných znakov
však pravdepodobne ostalo)

Ďalej sme vyradili defektné súbory (nedali sa otvoriť), súbory s tým
istým kódom, ale rozličným počtom slov a pod.

V prvom termíne sme do hlavného adresára nahrali tieto súbory s textami
(všetky sú párne, t. j. zanotované dvoma anotátormi):

BallekPomocnik
blogSME
Durovic
Inzine
MilosFerko
MilosFerko2
MojaPrvaLaska
Mucska
Orwell1984
Patmos
ProgramVyhlasenie
PsiaKoza
RaczovaOslov
Rozpravky
SME
Wikipedia

V druhom termíne sme do hlavného adresára pridali adresár Wikipedia2
(ďalšie texty z Wikipédie anotované dvojmo); do adresára
'single_annotator' sme nahrali ďalšie texty zanotované len jedným
anotátorom:

blogSME
DominoForum
HvoreckyLovciaZberaci
KralikMorus
Lenco
RaczovaRoman
Stavebnictvo
zber1-zvysne (ide o súbory, ktoré sme odfiltrovali z 1. súboru textov;
nie sú defektné, len nemajú pár)

Chcela by som upozorniť aj na skutočnosť, že iba niektoré texty, ktoré
sú syntakticky anotované, boli predtým ručne morfologicky anotované
(Orwell1984, MojaPrvaLaska, Mucska, MilosFerko, MilosFerko2, Patmos,
PsiaKoza a niektoré ďalšie).

Prajem vám úspešný deň.

S pozdravom

Agáta Karčová
SNK JÚĽŠ SAV v Bratislave

