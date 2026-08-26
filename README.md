# SVantigen: Identifying candidate neoantigens and druggable mutations in SV space

On August 20, 2026, [Moderna and Merck published a blockbuster paper with initial results from a Phase II clinical trial demonstrating the efficacy of combined Keytruda + personal neoantigen therapy](https://www.nature.com/articles/d41586-026-02612-3). This approach
used small variants unique to each patient's tumor - for over 1,000 patients - to create unique vaccines.


But small variants aren't the only variants that generate neoantigens. We know SVs exist in cancer cells and
are often protein modifiers. If we can expand neoantigen candidate prediction to SV space, we will serve more cancer patients, especially since SV drivers and SSV drivers are often mutually exclusive in many cancer types.

![SV antigen detection by a bunch of pipelines](https://github.com/collaborativebioinformatics/SVantigen/blob/main/images/SV_neoantigen_detection.drawio.png)


## Goals

## Approach

### Papers
https://www.nist.gov/programs-projects/cancer-genome-bottle

https://www.nature.com/articles/s41597-025-05438-2

https://www.biorxiv.org/content/10.64898/2026.05.01.722316v2

### Datasets

- [GIAB Somatic Data Browse Page (42basepairs)](https://42basepairs.com/browse/web/giab/data_somatic/HG008)
- [GIAB Somatic HG008 Directory (NCBI FTP)](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/)

```
HG008 Sample Descriptions:

HG008-T
The Liss laboratory established a pancreatic ductal adenocarcinoma cell line from the
primary tumor of a female patient (GIAB ID: HG008). This cell line is believed to be a
mixture of cells, with many somatic variants occurring in all cells but additional somatic
variants occur in only certain cell populations. The cell line (p13) was transferred to
NIST for further growth.

HG008-N-D
HG008 normal duodenal tissue

HG008-N-P
HG008 normal pancreatic tissue
```

#### Benchmark Callsets

- **Personal Somatic Structural Variants & CNVs (HG008-T, V0.5)**:
  - Directory: [`NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/)
  - PASS Somatic SV Benchmark VCF: [`GRCh38_HG008-T-V0.5_somatic-stvar_PASS.draftbenchmark.vcf.gz`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/GRCh38_HG008-T-V0.5_somatic-stvar_PASS.draftbenchmark.vcf.gz) ([.tbi index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/GRCh38_HG008-T-V0.5_somatic-stvar_PASS.draftbenchmark.vcf.gz.tbi))
  - ALL Somatic SV Calls VCF: [`GRCh38_HG008-T-V0.5_somatic-stvar_ALL.draftbenchmark.vcf.gz`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/GRCh38_HG008-T-V0.5_somatic-stvar_ALL.draftbenchmark.vcf.gz) ([.tbi index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/GRCh38_HG008-T-V0.5_somatic-stvar_ALL.draftbenchmark.vcf.gz.tbi))
  - Somatic CNV Benchmark Calls (BEDPE): [`GRCh38_HG008-T-V0.5_somatic-CNV_ALL.draftbenchmark.calls.bedpe`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/GRCh38_HG008-T-V0.5_somatic-CNV_ALL.draftbenchmark.calls.bedpe)
  - Benchmark Regions (Clonal BED): [`GRCh38_HG008-T-V0.5_somatic-stvar-clonal.draftbenchmark.bed`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/GRCh38_HG008-T-V0.5_somatic-stvar-clonal.draftbenchmark.bed)
  - Benchmark Regions (Clonal & Subclonal BED): [`GRCh38_HG008-T-V0.5_somatic-stvar-clonal_and_subclonal.draftbenchmark.bed`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/GRCh38_HG008-T-V0.5_somatic-stvar-clonal_and_subclonal.draftbenchmark.bed)

- **Personal Somatic Small Variants (SNV/Indel) (HG008-T, V0.3)**:
  - Directory: [`NIST_HG008-T_somatic-smvar_DraftBenchmark_V0.3-20260425`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-smvar_DraftBenchmark_V0.3-20260425/)
  - Somatic Small Variant VCF: [`HG008-T_somatic_smvar_benchmark_v0.3_somatic_tumornormal.vcf.gz`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-smvar_DraftBenchmark_V0.3-20260425/HG008-T_somatic_smvar_benchmark_v0.3_somatic_tumornormal.vcf.gz) ([.tbi index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-smvar_DraftBenchmark_V0.3-20260425/HG008-T_somatic_smvar_benchmark_v0.3_somatic_tumornormal.vcf.gz.tbi))
  - Full Somatic + Germline VCF: [`HG008-T_somatic_smvar_benchmark_v0.3_full_tumornormal.vcf.gz`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-smvar_DraftBenchmark_V0.3-20260425/HG008-T_somatic_smvar_benchmark_v0.3_full_tumornormal.vcf.gz) ([.tbi index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-smvar_DraftBenchmark_V0.3-20260425/HG008-T_somatic_smvar_benchmark_v0.3_full_tumornormal.vcf.gz.tbi))
  - High-Confidence Benchmark Regions (BED): [`HG008-T_somatic_smvar_benchmark_v0.3_all.bed`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-smvar_DraftBenchmark_V0.3-20260425/HG008-T_somatic_smvar_benchmark_v0.3_all.bed)

#### Selected Read Sets

- **Oxford Nanopore Technologies (ONT)**:
  - **Tumor (HG008-T) ~54x Ultra-Long (UL) ONT (GRCh38)**: [`HG008-T_GRCh38_GIABv3_ONT-UL-R10.4.1-dorado0.4.3_sup4.2.0_5mCG_5hmCG_54x_UCSC_20231031.bam`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/UCSC_ONT-UL_20231207/HG008-T_GRCh38_GIABv3_ONT-UL-R10.4.1-dorado0.4.3_sup4.2.0_5mCG_5hmCG_54x_UCSC_20231031.bam) ([.bai index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/UCSC_ONT-UL_20231207/HG008-T_GRCh38_GIABv3_ONT-UL-R10.4.1-dorado0.4.3_sup4.2.0_5mCG_5hmCG_54x_UCSC_20231031.bam.bai))
  - **Tumor (HG008-T) ~63x Standard ONT (GRCh38)**: [`HG008-T_GRCh38_GIABv3_ONT-R10.4.1-doradov0.3.4-5mCG-5hmC_63x_UCSC_20230905.bam`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/UCSC_ONT_20231003/HG008-T_GRCh38_GIABv3_ONT-R10.4.1-doradov0.3.4-5mCG-5hmC_63x_UCSC_20230905.bam) ([.bai index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/UCSC_ONT_20231003/HG008-T_GRCh38_GIABv3_ONT-R10.4.1-doradov0.3.4-5mCG-5hmC_63x_UCSC_20230905.bam.bai))
  - **Normal Pancreatic (HG008-N-P) ~41x ONT (GRCh38)**: [`HG008-N-P_GRCh38-GIABv3_ONT-R1041-dorado_0.5.3_5mC_5hmC_41x.bam`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/Northeastern_ONT-std_20240422/HG008-N-P_GRCh38-GIABv3_ONT-R1041-dorado_0.5.3_5mC_5hmC_41x.bam) ([.bai index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/Northeastern_ONT-std_20240422/HG008-N-P_GRCh38-GIABv3_ONT-R1041-dorado_0.5.3_5mC_5hmC_41x.bam.bai))

- **Illumina Short-Read WGS**:
  - **Tumor (HG008-T) NYGC WGS BAM (161x total, GRCh38)**: [`HG008-T_Illumina_161x_GRCh38-GIABv3.bam`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/NYGC_Illumina-WGS_20231023/HG008-T_Illumina_161x_GRCh38-GIABv3.bam) ([.bai index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/NYGC_Illumina-WGS_20231023/HG008-T_Illumina_161x_GRCh38-GIABv3.bam.bai))
  - **Normal (HG008-N-D) NYGC WGS BAM (118x total, GRCh38)**: [`HG008-N-D_Illumina_118x_GRCh38-GIABv3.bam`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/NYGC_Illumina-WGS_20231023/HG008-N-D_Illumina_118x_GRCh38-GIABv3.bam) ([.bai index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/NYGC_Illumina-WGS_20231023/HG008-N-D_Illumina_118x_GRCh38-GIABv3.bam.bai))
  - **NYGC Per-Lane FASTQs (Subsamplable to 30x-80x)**: [`NYGC_Illumina-WGS_20231023`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/NYGC_Illumina-WGS_20231023/)

#### Recurrent Driver SVs & Druggable Mutations Databases

- [Mitelman Database of Chromosome Aberrations and Gene Fusions](https://mitelmandatabase.isb-cgc.org/)
- [COSMIC (Catalogue Of Somatic Mutations In Cancer)](https://cancer.sanger.ac.uk/cosmic/download/cosmic)
- [OncoKB Precision Oncology Knowledge Base](https://www.oncokb.org/)

## Quickstart

## License

## Contributing
