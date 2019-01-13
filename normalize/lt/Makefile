LANGCODE=lt
TREEBANK=lt
UDCODE=lt_alksnis
UDNAME=Lithuanian-ALKSNIS
include ../common.mak

SOURCEDIR=/net/data/treebanks/lt/ALKSNIS_v2
SCHEMADIR=$(SOURCEDIR)/antisDplus_schema.pml

# There are four folders with different sources and genres.
# general_periodicals:
  # AMvadovu_V1.pml Estija_V1.pml GMO_V1.pml Haitis_V1.pml Prancuzija_V1.pml Vengrija_V1.pml
  # balandzio_V1.pml baznyciomis_V1.pml biudzetas_V1.pml dviraciu_V1.pml ivaizdis_V1.pml jubarkietis_V1.pml
  # parazitine_V1.pml patikimiausi_V1.pml
  # tb1-10_V2.pml tb1-11_V2.pml tb1-12_V2.pml tb1-13_V2.pml tb1-14_V2.pml tb1-15_V2.pml tb1-16_V2.pml tb1-17_V2.pml
  # tb1-18-V2.pml tb1-19_V2.pml tb1-1_V2.pml tb1-2-V2.pml tb1-20_V2.pml tb1-3-V2.pml tb1-4_V2.pml tb1-5_V2.pml
  # tb1-6_V2.pml tb1-7_V2.pml tb1-8_V2.pml tb1-9_V2.pml
# specialised_periodicals:
  # biuras_namuose_V1.pml galvos_skausmas_V1.pml kalbeti_ar_tyleti_V1.pml pikti_tevai_V1.pml
  # savo_kuna_V1.pml sveikai_maitintis_V1.pml sventems_V1.pml
# administrative_docs:
  # 2004-AM-Isak_V1.pml 2009-KM-Isak_V1.pml 2009_komunikatas_V2.pml daugiabuciu_V1.pml komunikatas_V1.pml
# fiction:
  # Jonuskaite_V2.pml Katkus-1_V2.pml Katkus-2_V2.pml Kuncinas_V2.pml Navakas-1_V2.pml Navakas-2_V2.pml
  # Parulskis-1_V2.pml Parulskis-2_V2.pml Parulskis-3-V2.pml Parulskis-4_V2.pml Parulskis-5-V2.pml Parulskis-6_V2.pml Parulskis-7_V2.pml
  # Serelyte-1_V2.pml Serelyte-2_V2.pml Serelyte-3_V2.pml Serelyte-4_V2.pml Serelyte-5_V2.pml

# Problem: The data files contain references to the schema. Either the schema
# must lie next to the data files (but then Treex will think it is another data
# file) or it cannot be read by our reader.
source:
	for i in $(SOURCEDIR)/{administrative_docs,fiction,general_periodicals,specialised_periodicals}/*.pml ; do echo cp $$i $(IN) ; cp $$i $(IN) ; done
	gzip $(IN)/*.pml
	gunzip $(IN)/antisDplus_schema.pml.gz

treex:
	$(TREEX) \
		Read::AlksnisPML schema_dir=$(SCHEMADIR) from='!$(IN)/{AMvadovu_V1,GMO_V1,Haitis_V1,Prancuzija_V1,balandzio_V1,baznyciomis_V1,biudzetas_V1,ivaizdis_V1,jubarkietis_V1,patikimiausi_V1,kalbeti_ar_tyleti_V1,pikti_tevai_V1,savo_kuna_V1,sveikai_maitintis_V1,sventems_V1,daugiabuciu_V1,Jonuskaite_V2,Katkus-1_V2,Katkus-2_V2,Kuncinas_V2,Navakas-1_V2,Navakas-2_V2,Parulskis-1_V2,Parulskis-2_V2,Parulskis-3-V2,Parulskis-4_V2,Parulskis-5-V2,Parulskis-6_V2,Parulskis-7_V2}.pml.gz' \
		W2W::EstimateNoSpaceAfter \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/
	$(TREEX) \
		Read::AlksnisPML schema_dir=$(SCHEMADIR) from='!$(IN)/{Estija_V1,dviraciu_V1,tb1-1_V2,tb1-2-V2,tb1-3-V2,tb1-4_V2,tb1-5_V2,tb1-6_V2,tb1-7_V2,tb1-8_V2,tb1-9_V2,tb1-10_V2,biuras_namuose_V1,2004-AM-Isak_V1,2009_komunikatas_V2,Serelyte-1_V2,Serelyte-3_V2}.pml.gz' \
		W2W::EstimateNoSpaceAfter \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/
	$(TREEX) \
		Read::AlksnisPML schema_dir=$(SCHEMADIR) from='!$(IN)/{Vengrija_V1,parazitine_V1,tb1-11_V2,tb1-12_V2,tb1-13_V2,tb1-14_V2,tb1-15_V2,tb1-16_V2,tb1-17_V2,tb1-18-V2,tb1-19_V2,tb1-20_V2,galvos_skausmas_V1,2009-KM-Isak_V1,komunikatas_V1,Serelyte-2_V2,Serelyte-4_V2,Serelyte-5_V2}.pml.gz' \
		W2W::EstimateNoSpaceAfter \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
