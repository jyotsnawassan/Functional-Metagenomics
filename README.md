# Functional-Metagenomics

1. Phylogeny in Data Preprocessing and Engineering
An algorithmic procedure is proposed to create a novel data structure of Phylogeny and Abundance-aware Matrix (PAAM)
exploiting the phylogenetic ancestral, and; integrating taxonomical evolution of microorganisms 
with their abundances at the data-preprocessing level for downstream microbiome classification.

The code relates to the generation of a new phylogeny and abundnace-aware Matrix PAAM in following publications :
Phy-PMRFI : Phylogeny-aware Prediction of Metagenomic Functions using Random Forest Feature Importance
Wassan, J.T., Wang, H., Browne, F. and Zheng, H., 2019. Phy-PMRFI: Phylogeny-aware Prediction of Metagenomic Functions using Random Forest Feature Importance.
IEEE transactions on nanobioscience.

PAAM-ML: A novel Phylogeny and Abundance aware Machine Learning Modelling Approach for Microbiome Classification 
Wassan, J.T., Wang, H., Browne, F. and Zheng, H., 2018, December. PAAM-ML: A novel Phylogeny and Abundance aware Machine
Learning Modelling Approach for Microbiome Classification. 
In 2018 IEEE International Conference on Bioinformatics and Biomedicine (BIBM) (pp. 44-49). IEEE.

ML employed over the Phylogeny and Abundance-aware data modelling (PAAM-ML) : Functionality available as PAAMWebpage.html (linked to related inputs)

2. Phylogney in Feature Selection

The microbial profiles of metagenomic samples are modelled firstly by merging the abundance profiles of OTUs into ancestral nodes, creating a data structure of a Phylogeny Topology and Abundance-aware Matrix (PTAM) along the taxonomical hierarchy (topology). Here only the topology of a phylogenetic tree is considered to model the relationships between OTUs and the ancestral nodes in the input data modelling. However, the phylogenetic distances are introduced in the feature selection criteria later. The abundances of leaf-level OTUs remained same in PTAM. The profiles of ancestral nodes in the PTAM matrix were computed by combining abundances of its constituting OTUs, forming a hierarchal topology. Ancestral elements were ranked according to their contribution to separating microbial samples into phenotype classes using phylogeny-aware Relief measure. A recently developed index of phylogenetic similarity termed as Phylogenetic INteraction-Adjusted index (PINA) is utilised.The process is termed as PINA-PhyloRelief and is under publication:-

Wassan, J.T., Zheng, H., Wang, H, Browne, F., Walsh, Manning, Roehe, R., Dewhurst, R., 2019, November. A Phylogeny-aware feature ranking for classification of Cattle Rumen Microbiome. In DAM Workshop, 2019 IEEE International Conference on Bioinformatics and Biomedicine (BIBM) (in press) IEEE. [Conference Publication]

Phylogenetic Ranking of Features at higher taxonomical level 
(Phylogeny-PINA Relief)
Perl Script to generate phylogeny-aware feature space and it’s ranking, and; R package to apply ML : PINAPhyloReliefWebPage.html

3. Phylogeny in Random Forest Model.

Publication under Process.
Initial Code available as Phylogney-RF.

