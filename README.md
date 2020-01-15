# Functional-Metagenomics
# Functionality available as PAAMWebpage.html

An algorithmic procedure is proposed to create a novel data structure of Phylogeny and Abundance-aware Matrix (PAAM)
exploiting the phylogenetic ancestral, and; integrating taxonomical evolution of microorganisms 
with their abundances at the data-preprocessing level for downstream microbiome classification (Functional-Metagenomics).

The code relates to the generation of a new phylogeny and abundnace-aware Matrix PAAM in following publications :
Phy-PMRFI : Phylogeny-aware Prediction of Metagenomic Functions using Random Forest Feature Importance
Wassan, J.T., Wang, H., Browne, F. and Zheng, H., 2019. Phy-PMRFI: Phylogeny-aware Prediction of Metagenomic Functions using Random Forest Feature Importance.
IEEE transactions on nanobioscience.

PAAM-ML: A novel Phylogeny and Abundance aware Machine Learning Modelling Approach for Microbiome Classification 
Wassan, J.T., Wang, H., Browne, F. and Zheng, H., 2018, December. PAAM-ML: A novel Phylogeny and Abundance aware Machine
Learning Modelling Approach for Microbiome Classification. 
In 2018 IEEE International Conference on Bioinformatics and Biomedicine (BIBM) (pp. 44-49). IEEE.

PAAM ALGORITHM


Algorithm 1: Construction of PAAM Feature Space 

Required Input:  A phylogenetic tree ‘Tn’ with ‘n’ OTUs and ‘n-1’ ancestral nodes; taxa abundance Matrix X (m, n) with ‘m’ as number of samples & ‘n’ as number of OTU features.
Expected Output:  A new phylogeny and taxa abundance aware matrix       
X (m,2n-1) with ‘m’ samples and ‘2*n-1’ features containing n-1 ancestral nodes as the new features.
Procedure:
i ← 0
j ← 0
For each sample row ‘i’ in Matrix X (m, n) do
      j ← n +1 //indexing for newly constructed feature in PAAM
      For each ancestral node ‘v’ in Tn do 
          X (i, j) ← 0
           For each OTU ‘u’ in Tn and X (m, n) do
                 If OTU ‘u’ in sample i, is descendent of    
                  node ‘v’ in the Tn, then
                          PD u, v ← phylogenetic distance of OTU ‘u' from node ‘v’
                          A u, i ← abundance count of   OTU ‘u’ in sample ‘i'
                         Weighted abundance of ancestral node ‘v’ i.e. 〖WA〗_(v )=    A_(u,i  )/〖PD〗_(u,v) 
                          X (i, j) ←   X (i, j) + 〖WA〗_(v )
                End
             End
            j ← j + 1 
       End
End.     
