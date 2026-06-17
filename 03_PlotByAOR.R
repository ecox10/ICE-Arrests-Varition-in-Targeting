#############################
# ICE Arrests - Variation in Targeting 
#############################
# By  Ellie Cox
# June 17, 2026
#############################

#############################
# This uses cleaned DDP and Garcia Hernandez data to plot arrests by method and area
#############################

#=============================
# Load Packages  
#=============================

library(ggplot2)
library(dplyr)
library(gridExtra)
library(ggpubr)
library(patchwork)
library(scales)
library(zoo)
library(tidyr)
library(lubridate)

#=============================
# Define Function to control breaks
#=============================

equal_breaks <- function(n = 3, s = 0.1,...){
  function(x){
    d <- s * diff(range(x)) / (1+2*s)
    seq = seq(min(x)+d, max(x)-d, length=n)
    round(seq, 1)
  }
}

#=============================
# Read and Prepare Data
#=============================

setwd("") # Set working directory path here

relinaug_dat <- read.csv("Data/arrests_relinaug_v2.csv")
noncit <- read.csv("Data/noncit_2023_byaor.csv") %>% select(ApprehensionAOR, year, noncit_2023)

noncit <- reshape(noncit, idvar = "ApprehensionAOR", timevar = "year", direction = "wide")
noncit$ApprehensionAOR <- gsub(" Area of Responsibility", " AOR", noncit$ApprehensionAOR)

relinaug_dat <- relinaug_dat %>% filter(ApprehensionAOR != "")
relinaug_dat <- left_join(relinaug_dat, noncit, by = c("ApprehensionAOR"))
relinaug_dat$ApprehensionAOR[which(relinaug_dat$ApprehensionAOR == "Washington AOR")] <- "Washington DC AOR"

#=============================
# Plot
#=============================

aors <- unique(relinaug_dat$ApprehensionAOR) 

relinaug_dat$ma_lea_noncit <- (relinaug_dat$ma_lea/relinaug_dat$noncit_2023.2015)*100000
relinaug_dat$ma_new_lea_noncit <- (relinaug_dat$ma_new_lea/relinaug_dat$noncit_2023.2023)*100000
relinaug_dat$ma_commarr_noncit <- (relinaug_dat$ma_commarr/relinaug_dat$noncit_2023.2015)*100000
relinaug_dat$ma_new_commarr_noncit <- (relinaug_dat$ma_new_commarr/relinaug_dat$noncit_2023.2023)*100000

# Plot
for (i in 1:length(unique(relinaug_dat$ApprehensionAOR))) {
  tempdat <- relinaug_dat %>% filter(ApprehensionAOR == aors[i])
  
  tempplot <- ggplot(tempdat) + 
    geom_line(aes(x = date_rel_inaug, y = ma_lea_noncit, color = "01")) + 
    geom_line(aes(x = date_rel_inaug, y = ma_new_lea_noncit, color = "02")) + 
    geom_line(aes(x = date_rel_inaug, y = ma_commarr_noncit, color = "03")) + 
    geom_line(aes(x = date_rel_inaug, y = ma_new_commarr_noncit, color = "04")) + 
    geom_vline(xintercept = 0, color = "red", linetype = "dashed") + 
    scale_x_continuous(limits = c(-400, 400), breaks = c(-400, -300, -200, -100, 0, 100, 200, 300, 400)) +    scale_y_continuous(breaks=equal_breaks(n=3, s=0.1)) + 
    scale_color_manual(values = c("01" = "#FF8A8A", "02" = "#CC0000", "03" = "#B8E2FF", "04" = "#0099FF"), 
                       labels = c("LEA, Term 1", "LEA, Term 2", "Community Arrests, Term 1", "Community Arrests, Term 2")) + 
    guides(color = guide_legend(nrow = 2)) +
    labs(title = paste0(aors[i]), y="Number of Arrests per 100,000 Non-Citizens", x="Days Relative to Inauguration", color = "Legend") + 
    theme(plot.title = element_text(size = 10, hjust = 0.5), axis.title = element_text(size = 14), 
          legend.position = "bottom", legend.direction = "horizontal", 
          legend.title = element_text(size = 0.25),
          legend.key = element_rect(fill = "transparent", colour = "transparent"), 
          panel.grid.major.x = element_line(color = "#D3D3D3", size = 0.25, linetype = "dotted"), 
          legend.text = element_text(size = 12), 
          panel.grid.major.y = element_line(color = "#D3D3D3", size = 0.25, linetype = "dotted"),  
          panel.border = element_blank(), panel.background = element_blank(), 
          axis.line.x = element_line(color="black", size = 0.5), 
          axis.line.y = element_line(color = "#808080", size = 0.25), 
          plot.caption = element_text(size = 8, hjust = 0),
          axis.text.x = element_text(angle = 90, vjust = 0.5)) 
  
  name <- paste0("plot", aors[i]) 
  assign(name, tempplot)
}

# Grid Arrange 
combined <- `plotAtlanta AOR` + `plotBaltimore AOR` + `plotBoston AOR` + `plotBuffalo AOR` + `plotChicago AOR` +
  `plotDallas AOR` + `plotDenver AOR` + `plotDetroit AOR` + `plotEl Paso AOR` + `plotLos Angeles AOR` + 
  `plotMiami AOR` + `plotNew Orleans AOR` + `plotNew York City AOR` + `plotNewark AOR` + `plotPhiladelphia AOR` + 
  `plotPhoenix AOR` + `plotSalt Lake City AOR` + `plotSan Antonio AOR` + `plotSan Diego AOR` + 
  `plotSan Francisco AOR` + `plotSeattle AOR` + `plotSt. Paul AOR` + `plotWashington DC AOR` + 
  plot_layout(ncol = 4, guides = "collect", axis_titles = "collect") & theme(legend.position = "bottom")

ggsave("Figs/arrests_relinaug_cat2_byAOR_noncit_short.pdf", 
       plot = last_plot(),
       width =7,
       height = 7,
       dpi = 600,
       device = "pdf")   
