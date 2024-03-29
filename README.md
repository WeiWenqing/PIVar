# PIVar
## 1. Introduction

To investigate the potential impact of genomic mutations on post-transcriptional regulation, we developed a new heuristic scoring system, PIVar, according to the functional confidence of variants based on experimental data of genome-wide association studies (GWAS), expression quantitative trait locus (eQTL), CLIP-seq (cross-linking and immunoprecipitation followed by high-throughput sequencing) derived RBP binding sites, and miRNA targets. The scoring system represents with increasing confidence if a variant lies in more functional elements. To evaluate the impact of RBP binding by mutations, we employed LS-GKM (10-mer) and deltaSVM to predict the impact of SNVs on the binding of specific RBPs by calculating the delta SVM scores. We also employed the RNAsnp or RNAfold to estimate the mutation effects on local RNA secondary structure, and calculated the empirical P values based on the base pair probabilities of mutant RNA sequences, or cumulative probabilities of the Poisson distribution, respectively. Only the functional SNVs produces >5 change in gkm-SVM scores for the effect of RBP binding, and P-value < 0.1 and free energy change >1 for the effect of SNVs on RNA secondary structure change were determined to be a piSNVs. Alternative allele of certain genetic mutation may confer different binding specificity for an RBP, resulting in allele-specific functional consequences.

## 2. Prepare annotation and required softwares

PIVar annotation files could be downloaded from http://159.226.67.237/sun/PIVar/; We updated PIVAR algorithm to evaluate the impact of mutations on posttranscriptional regulation by adding the latest 318 eCLIP-seq data from ENCODE (112 RBPs) to identify piSNVs, which replaced file "CLIP.tar.gz" by new file "new-CLIP.tar.gz" (2022/08), which could disrupt the binding between RNAs and RBPs;

Before running the pipeline, you should download and install dependent software ViennaRNA-2.4.10, RNAsnp-1.2 and bedtools2;
And prepare the necessary input file, like example.input(remove the header), format detail below;

## 3. Install and run pipeline

In pipeline folder, you should run the work* shell files in turn;

## 4. Input and output format

### Input format:

(example.input)
"Chr Start End Ref Alt Func.refGene symbol effect Variant_Type cytoBand Ref/Alt chromosome_chain Variant_Type NOID";
   1) Chr: chromosome
   2) Start: start position
   3) End: end position
   4) Ref: reference allele
   5) Alt: altered allele
   6) Func.refGene: gene region
   7) symbol: gene symbol
   8) effect: frameshift, nonframeshift, nonsynonymous, splicing, synonymous, stopgain and stoploss, etc
   9) Variant_Type: deletion, insertion and SNV, etc
   10) cytoBand: chromosome band track 
   11) Ref/Alt: reference allele/altered allele
   12) chromosome_chain: +/-
   13) Variant_Type: deletion, insertion and SNV, etc(same with 9))
   14) NOID: record ID
   
### Output format:

"Chr, Start, End, Ref, Alt, Func.refGene, symbol, effect, Variant_Type, cytoBand, Ref/Alt, chromosome_chain, Variant_Type, NOID, Chr, Start, End, RBP_Var_score, CLIP:, CLIP, miRNA:, miRNA, Motif:, Motif, Energy:, Energy, p_value";
(1 - 14 are the same with input format)

   15) Chr: chromosome
   16) Start: start position
   17) End： end position
   18) RBP_Var_score:1a, 1b, 1c, 1d, 1e, 2a, 2b, 2c, 2d, 3a, 3b, 4, 5 and 6
   19) CLIP: CLIP title
   20) CLIP: the mutation can influence the binding in the CLIP
   21) miRNA: miRNA title
   22) miRNA: the mutation can influence the binding with miRNA
   23) Motif: Motif title
   24) Motif: the mutation can influence the binding with motif
   25) Energy: Energy title
   26) Energy: the energy change of the transcripts of mutation
   27) p_value: probability value of energy change
 
## Citation: 
Prevalence and architecture of posttranscriptionally impaired synonymous mutations in 8,320 genomes across 22 cancer types. Nucleic Acids Res. 2020 Feb 20;48(3):1192-1205
