LANGCODE=lt
TREEBANK=lt-alksnis22
UDCODE=lt_alksnis
UDNAME=Lithuanian-ALKSNIS
HARMONIZE=Harmonize iset_driver=lt::jablonskis
POST_UD_BLOCKS=HamleDT::Punctuation
include ../common.mak

SOURCEDIR=/net/data/treebanks/lt/Alksnis_2.2
SCHEMADIR=$(SOURCEDIR)/AlksnisSchema-1.3.pml

# There are four folders with different sources and genres.
# general-press:
 # now (version 2.2, omitting the suffix "_2019-01-14.pml", which appears in all files):
  # AMvadovu Estija GMO Haitis Prancuzija Vengrija
  # balandzio baznyciomis biudzetas dviraciu ivaizdis jubarkietis
  # kd1-1 kd1-2 kd1-3 kd1-4 kd1-5 kd1-6 kd1-7 kd1-8 kd1-9 kd1-10
  # kd1-11 kd1-12 kd1-13 kd1-14 kd1-15 kd1-16 kd1-17 kd1-18 kd1-19 kd1-20
  # parazitine patikimiausi
# specialised-press:
  # biuras_namuose galvos_skausmas kalbeti_ar_tyleti myliu_savo_kuna pikti_tevai sveikai_maitintis sventems
# administrative_docs:
  # 2004-AM-Isak_V1.pml 2009-KM-Isak_V1.pml 2009_komunikatas_V2.pml daugiabuciu_V1.pml komunikatas_V1.pml
  # 2004_AM_Isak 2005_daugiabuciu 2009_KM_Isak 2009_komunikatas
# fiction:
  # Jonuskaite Katkus-1 Katkus-2 Kuncinas Navakas-1 Navakas-2
  # Parulskis-1 Parulskis-2 Parulskis-3 Parulskis-4 Parulskis-5 Parulskis-6 Parulskis-7
  # Serelyte-1 Serelyte-2 Serelyte-3 Serelyte-4 Serelyte-5

TRAINFILES=AMvadovu,GMO,Haitis,Prancuzija,balandzio,baznyciomis,biudzetas,ivaizdis,jubarkietis,patikimiausi,kalbeti_ar_tyleti,myliu_savo_kuna,pikti_tevai,sveikai_maitintis,2005_daugiabuciu,Jonuskaite,Katkus-1,Katkus-2,Navakas-1,Navakas-2,Parulskis-1,Parulskis-2,Parulskis-3,Parulskis-4,Parulskis-5,Parulskis-6,Parulskis-7
DEVFILES=Estija,dviraciu,kd1-1,kd1-2,kd1-3,kd1-4,kd1-5,kd1-6,kd1-7,kd1-8,kd1-9,kd1-10,biuras_namuose,2004_AM_Isak,2009_komunikatas,Serelyte-1,Serelyte-3
TESTFILES=Vengrija,parazitine,kd1-11,kd1-12,kd1-13,kd1-14,kd1-15,kd1-16,kd1-17,kd1-18,kd1-19,kd1-20,galvos_skausmas,sventems,2009_KM_Isak,Kuncinas,Serelyte-2,Serelyte-4,Serelyte-5

# Problem: The data files contain references to the schema. Either the schema
# must lie next to the data files (but then Treex will think it is another data
# file) or it cannot be read by our reader.
source:
	for i in $(SOURCEDIR)/{documents,fiction,general-press,specialized-press}/*.pml ; do echo cp $$i $(IN)/`basename $$i _2019-01-14.pml`.pml ; cp $$i $(IN)/`basename $$i _2019-01-14.pml`.pml ; done
	mv $(IN)/AlksnisSchema-1.3.pml.pml $(IN)/AlksnisSchema-1.3.pml
	gzip $(IN)/*.pml
	gunzip $(IN)/AlksnisSchema-1.3.pml.gz

treex:
	$(TREEX) \
		Read::AlksnisPML schema_dir=$(SCHEMADIR) from='!$(IN)/{$(TRAINFILES)}.pml.gz' \
		W2W::RemoveLeadingTrailingSpaces \
		W2W::EstimateNoSpaceAfter \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/
	$(TREEX) \
		Read::AlksnisPML schema_dir=$(SCHEMADIR) from='!$(IN)/{$(DEVFILES)}.pml.gz' \
		W2W::RemoveLeadingTrailingSpaces \
		W2W::EstimateNoSpaceAfter \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/
	$(TREEX) \
		Read::AlksnisPML schema_dir=$(SCHEMADIR) from='!$(IN)/{$(TESTFILES)}.pml.gz' \
		W2W::RemoveLeadingTrailingSpaces \
		W2W::EstimateNoSpaceAfter \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/
	gunzip $(DIR0)/{train,dev,test}/*.treex.gz

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud_enhanced
