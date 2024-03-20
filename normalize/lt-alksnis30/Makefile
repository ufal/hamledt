LANGCODE=lt
TREEBANK=lt-alksnis30
UDCODE=lt_alksnis
UDNAME=Lithuanian-ALKSNIS
HARMONIZE=Harmonize iset_driver=lt::jablonskis
POST_UD_BLOCKS=HamleDT::Punctuation HamleDT::LT::FixUD
include ../common.mak

SOURCEDIR=/net/data/treebanks/lt/alksnis-v3.0
SCHEMADIR=$(SOURCEDIR)/AlksnisSchema-3.0.pml

# There are five folders with different sources and genres.
# general-press / bendroji_periodika:
  # AMvadovu Estija GMO Haitis Prancuzija Vengrija
  # balandzio baznyciomis biudzetas dviraciu ivaizdis jubarkietis
  # kd1-1 kd1-2 kd1-3 kd1-4 kd1-5 kd1-6 kd1-7 kd1-8 kd1-9 kd1-10
  # kd1-11 kd1-12 kd1-13 kd1-14 kd1-15 kd1-16 kd1-17 kd1-18 kd1-19 kd1-20
  # parazitine patikimiausi
# specialised-press / specialioji_periodika:
  # biuras_namuose galvos_skausmas kalbeti_ar_tyleti myliu_savo_kuna pikti_tevai sveikai_maitintis sventems
# administrative_docs / administraciniai_dokumentai:
  # 2004_AM_Isak 2005_daugiabuciu 2009_KM_Isak 2009_komunikatas
  # Nutarimas_kulturos_politikos_kaitos_gaires Pasto_paslaugos_teikimo_taisykles Smulkiojo_ir_vidutinio_verslo_pletros_istatymas Veiklos_ataskaita
# fiction / grozine_literatura:
  # Jonuskaite Katkus-1 Katkus-2 Kuncinas Navakas-1 Navakas-2
  # Parulskis-1 Parulskis-2 Parulskis-3 Parulskis-4 Parulskis-5 Parulskis-6 Parulskis-7
  # Serelyte-1 Serelyte-2 Serelyte-3 Serelyte-4 Serelyte-5
# nonfiction / moksline_literatura
# I moved the subfolders up to simplify processing: moksline_literatura_recenzijos, moksline_literatura_santraukos.
  # moksl_recenzijos (reviews)
    # Antanaicio_rec_77s Ciubrinsko_rec_74s Kaceviciaus_rec_76s Kanopienes_rec_73s Ruzaites_rec_109s
  # moksl_santraukos (summaries)
    # mok_santr1_77_sak mok_santr2_91_sak mok_santr3_63_sak mok_santr4_82_sak

TRAINFILES=AMvadovu,GMO,Haitis,Prancuzija,balandzio,baznyciomis,biudzetas,ivaizdis,jubarkietis,patikimiausi,kalbeti_ar_tyleti,myliu_savo_kuna,pikti_tevai,sveikai_maitintis,2005_daugiabuciu,Jonuskaite,Katkus-1,Katkus-2,Navakas-1,Navakas-2,Parulskis-1,Parulskis-2,Parulskis-3,Parulskis-4,Parulskis-5,Parulskis-6,Parulskis-7,Nutarimas_kulturos_politikos_kaitos_gaires,Pasto_paslaugos_teikimo_taisykles,Smulkiojo_ir_vidutinio_verslo_pletros_istatymas,Veiklos_ataskaita,Antanaicio_rec_77s,Ciubrinsko_rec_74s,Kaceviciaus_rec_76s,Kanopienes_rec_73s,Ruzaites_rec_109s,mok_santr1_77_sak,mok_santr2_91_sak,mok_santr3_63_sak,mok_santr4_82_sak
DEVFILES=Estija,dviraciu,kd1-1,kd1-2,kd1-3,kd1-4,kd1-5,kd1-6,kd1-7,kd1-8,kd1-9,kd1-10,biuras_namuose,2004_AM_Isak,2009_komunikatas,Serelyte-1,Serelyte-3
TESTFILES=Vengrija,parazitine,kd1-11,kd1-12,kd1-13,kd1-14,kd1-15,kd1-16,kd1-17,kd1-18,kd1-19,kd1-20,galvos_skausmas,sventems,2009_KM_Isak,Kuncinas,Serelyte-2,Serelyte-4,Serelyte-5

# Problem: The data files contain references to the schema. Either the schema
# must lie next to the data files (but then Treex will think it is another data
# file) or it cannot be read by our reader.
source:
	for i in $(SOURCEDIR)/{administraciniai_dokumentai,grozine_literatura,moksline_literatura_recenzijos,moksline_literatura_santraukos,bendroji_periodika,specialioji_periodika}/*.pml ; do echo cp $$i $(IN) ; cp $$i $(IN) ; done
	gzip $(IN)/*.pml
	gunzip $(IN)/AlksnisSchema-3.0.pml.gz

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
ud: prague_to_ud_enhanced export

# We need our own export because we need specific post-processing.
#UDAPISCEN=ud.sk.FixEdeprels
export: ud_export default_ud_postprocessing

ud_export:
	@echo `date` cat train started | tee -a time.log
	cat $(CONLLUDIR)/train/*.conllu | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train.conllu
	@echo `date` cat dev started | tee -a time.log
	cat $(CONLLUDIR)/dev/*.conllu | ../conllu_docpar_from_sentid.pl >  $(UDCODE)-ud-dev.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-dev.conllu
	@echo `date` cat test started | tee -a time.log
	cat $(CONLLUDIR)/test/*.conllu | ../conllu_docpar_from_sentid.pl >> $(UDCODE)-ud-test.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-test.conllu
