# Reference & Benchmark Datasets

This document lists reference datasets, benchmark callsets, and recommended sequencing read sets for testing and evaluating the SVantigen pipeline.

---

## 1. GIAB Somatic Benchmark (HG008)

[Genome in a Bottle (GIAB)](https://www.nist.gov/programs-projects/cancer-genome-bottle) somatic benchmark dataset for sample **HG008** (Pancreatic Ductal Adenocarcinoma).

* **Browse Datasets (42basepairs)**: [GIAB HG008 Somatic Browse Page](https://42basepairs.com/browse/web/giab/data_somatic/HG008)
* **NCBI FTP Base Directory**: [GIAB HG008 Liss Lab Directory](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/)

### Sample Metadata Summary

* **`HG008-T`**: Primary tumor cell line (Pancreatic Ductal Adenocarcinoma established by Liss laboratory, transferred to NIST at passage p13). Represents a heterogeneous tumor population with clonal and subclonal somatic variants.
* **`HG008-N-D`**: Normal control sample from duodenal tissue.
* **`HG008-N-P`**: Normal control sample from pancreatic tissue.

---

## 2. Benchmark Callsets

### Personal Somatic Structural Variants (SVs) & CNVs (HG008-T, Draft Benchmark V0.5)

* **Base Directory**: [`NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/)
* **PASS Somatic SV Benchmark Calls (VCF)**: [`GRCh38_HG008-T-V0.5_somatic-stvar_PASS.draftbenchmark.vcf.gz`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/GRCh38_HG008-T-V0.5_somatic-stvar_PASS.draftbenchmark.vcf.gz) ([.tbi index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/GRCh38_HG008-T-V0.5_somatic-stvar_PASS.draftbenchmark.vcf.gz.tbi))
* **ALL Somatic SV Calls (VCF)**: [`GRCh38_HG008-T-V0.5_somatic-stvar_ALL.draftbenchmark.vcf.gz`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/GRCh38_HG008-T-V0.5_somatic-stvar_ALL.draftbenchmark.vcf.gz) ([.tbi index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/GRCh38_HG008-T-V0.5_somatic-stvar_ALL.draftbenchmark.vcf.gz.tbi))
* **Somatic CNV Benchmark Calls (BEDPE)**: [`GRCh38_HG008-T-V0.5_somatic-CNV_ALL.draftbenchmark.calls.bedpe`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/GRCh38_HG008-T-V0.5_somatic-CNV_ALL.draftbenchmark.calls.bedpe)
* **Clonal SV Benchmark Regions (BED)**: [`GRCh38_HG008-T-V0.5_somatic-stvar-clonal.draftbenchmark.bed`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/GRCh38_HG008-T-V0.5_somatic-stvar-clonal.draftbenchmark.bed)
* **Clonal & Subclonal SV Benchmark Regions (BED)**: [`GRCh38_HG008-T-V0.5_somatic-stvar-clonal_and_subclonal.draftbenchmark.bed`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/GRCh38_HG008-T-V0.5_somatic-stvar-clonal_and_subclonal.draftbenchmark.bed)

### Personal Somatic Small Variants (SNV/Indel) (HG008-T, Draft Benchmark V0.3)

* **Base Directory**: [`NIST_HG008-T_somatic-smvar_DraftBenchmark_V0.3-20260425`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-smvar_DraftBenchmark_V0.3-20260425/)
* **Somatic Small Variant Calls (VCF)**: [`HG008-T_somatic_smvar_benchmark_v0.3_somatic_tumornormal.vcf.gz`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-smvar_DraftBenchmark_V0.3-20260425/HG008-T_somatic_smvar_benchmark_v0.3_somatic_tumornormal.vcf.gz) ([.tbi index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-smvar_DraftBenchmark_V0.3-20260425/HG008-T_somatic_smvar_benchmark_v0.3_somatic_tumornormal.vcf.gz.tbi))
* **Full Somatic + Germline Calls (VCF)**: [`HG008-T_somatic_smvar_benchmark_v0.3_full_tumornormal.vcf.gz`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-smvar_DraftBenchmark_V0.3-20260425/HG008-T_somatic_smvar_benchmark_v0.3_full_tumornormal.vcf.gz) ([.tbi index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-smvar_DraftBenchmark_V0.3-20260425/HG008-T_somatic_smvar_benchmark_v0.3_full_tumornormal.vcf.gz.tbi))
* **High-Confidence Benchmark Regions (BED)**: [`HG008-T_somatic_smvar_benchmark_v0.3_all.bed`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-smvar_DraftBenchmark_V0.3-20260425/HG008-T_somatic_smvar_benchmark_v0.3_all.bed)

---

## 3. Recommended Sequencing Read Sets

Selected aligned BAM and raw FASTQ read sets for pipeline input.

### Oxford Nanopore Technologies (Long Reads)

* **Tumor (HG008-T) ~54x Ultra-Long (UL) ONT BAM (GRCh38)**:
  [`HG008-T_GRCh38_GIABv3_ONT-UL-R10.4.1-dorado0.4.3_sup4.2.0_5mCG_5hmCG_54x_UCSC_20231031.bam`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/UCSC_ONT-UL_20231207/HG008-T_GRCh38_GIABv3_ONT-UL-R10.4.1-dorado0.4.3_sup4.2.0_5mCG_5hmCG_54x_UCSC_20231031.bam) ([.bai index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/UCSC_ONT-UL_20231207/HG008-T_GRCh38_GIABv3_ONT-UL-R10.4.1-dorado0.4.3_sup4.2.0_5mCG_5hmCG_54x_UCSC_20231031.bam.bai))
* **Tumor (HG008-T) ~63x Standard ONT BAM (GRCh38)**:
  [`HG008-T_GRCh38_GIABv3_ONT-R10.4.1-doradov0.3.4-5mCG-5hmC_63x_UCSC_20230905.bam`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/UCSC_ONT_20231003/HG008-T_GRCh38_GIABv3_ONT-R10.4.1-doradov0.3.4-5mCG-5hmC_63x_UCSC_20230905.bam) ([.bai index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/UCSC_ONT_20231003/HG008-T_GRCh38_GIABv3_ONT-R10.4.1-doradov0.3.4-5mCG-5hmC_63x_UCSC_20230905.bam.bai))
* **Normal Pancreatic (HG008-N-P) ~41x Standard ONT BAM (GRCh38)**:
  [`HG008-N-P_GRCh38-GIABv3_ONT-R1041-dorado_0.5.3_5mC_5hmC_41x.bam`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/Northeastern_ONT-std_20240422/HG008-N-P_GRCh38-GIABv3_ONT-R1041-dorado_0.5.3_5mC_5hmC_41x.bam) ([.bai index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/Northeastern_ONT-std_20240422/HG008-N-P_GRCh38-GIABv3_ONT-R1041-dorado_0.5.3_5mC_5hmC_41x.bam.bai))

### Illumina (Short Reads)

* **Tumor (HG008-T) NYGC WGS BAM (161x total, GRCh38)**:
  [`HG008-T_Illumina_161x_GRCh38-GIABv3.bam`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/NYGC_Illumina-WGS_20231023/HG008-T_Illumina_161x_GRCh38-GIABv3.bam) ([.bai index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/NYGC_Illumina-WGS_20231023/HG008-T_Illumina_161x_GRCh38-GIABv3.bam.bai))
* **Normal Duodenal (HG008-N-D) NYGC WGS BAM (118x total, GRCh38)**:
  [`HG008-N-D_Illumina_118x_GRCh38-GIABv3.bam`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/NYGC_Illumina-WGS_20231023/HG008-N-D_Illumina_118x_GRCh38-GIABv3.bam) ([.bai index](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/NYGC_Illumina-WGS_20231023/HG008-N-D_Illumina_118x_GRCh38-GIABv3.bam.bai))
* **Per-Lane FASTQs Directory (Subsamplable to 30x–80x)**:
  [`NYGC_Illumina-WGS_20231023`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/NYGC_Illumina-WGS_20231023/)

---

## 4. Recurrent Driver SV & Druggable Mutation Databases

* [Mitelman Database of Chromosome Aberrations and Gene Fusions in Cancer](https://mitelmandatabase.isb-cgc.org/)
* [COSMIC (Catalogue Of Somatic Mutations In Cancer)](https://cancer.sanger.ac.uk/cosmic/download/cosmic)
* [OncoKB Precision Oncology Knowledge Base](https://www.oncokb.org/)
