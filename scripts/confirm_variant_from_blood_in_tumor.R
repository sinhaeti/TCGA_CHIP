# Load libraries
library(dplyr)
library(stringr)
library(ggplot2)
library(cowplot)
library(magrittr)
library(scales)
library(tidyverse)

# Read in CH Variants from previous subset of TCGA
ch_infiltration_tmb_clinical <- read_csv("/Users/etisinhawork/Box/Work/Weill/Elemento-Jaiswal Collaboration/tcga_ch_tumor_infiltration/ch_infiltration_tmb_clinical.csv", col_types = cols(chip_status = col_character()))
brca_blood_subset <- ch_infiltration_tmb_clinical %>% 
  filter(chip_status == 1) %>% 
  filter(CancerType == "BRCA") %>% 
  select(Patient_ID, Hugo_Symbol:chip_status)

# Read in variants from tumor VCF
brca_tumor_variant_infiltration_table <- read_csv("TCGA_CHIP/scripts/BRCA_variant_infiltration_table.csv", 
                                                  col_types = cols(chip_status = col_character(), 
                                                                   infiltration_VAF = col_number(),
                                                                   i_tumor_f_max= col_number())) %>% 
  filter(!(CHIP_Classification == "Multiple")) %>% 
  filter(!(is.na(Infiltration_status)))

# Plot VAF comparison
ggplot(data = brca_tumor_variant_infiltration_table, aes(x = i_tumor_f_max, y = infiltration_VAF, color=Variant_Type)) +
  geom_point() +
  theme_minimal() +
  labs(title = "Blood VAF vs Tumor VAF", x="VAF in Blood", y="VAF in Tumor") +
  facet_wrap( ~CHIP_Classification)
