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

https://42basepairs.com/browse/web/giab/data_somatic/HG008?file=README_HG008.md&preview=contents

```
HG008

Sample Descriptions

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

Benchmarks:
https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/NIST_HG008-T_somatic-stvar-CNV_DraftBenchmark_V0.5-20260318/

Recurrent driver SVs / druggable mutations:
https://mitelmandatabase.isb-cgc.org/
https://cancer.sanger.ac.uk/cosmic/download/cosmic
https://www.oncokb.org/

## Quickstart

## License

## Contributing