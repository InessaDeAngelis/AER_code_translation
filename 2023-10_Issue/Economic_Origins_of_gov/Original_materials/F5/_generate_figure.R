library(ggplot2)

# Objective: Figure 5

# set working dir here
replication_dir 
setwd(replication_dir)

# set formatting
graph_theme <- theme(legend.key=element_rect(fill=NA), 
                     panel.grid.major = element_line(colour = "grey"),
                     panel.grid.minor = element_line(colour = NA),
                     panel.border = element_rect(fill = NA, colour = "black"), 
                     panel.background = element_rect(fill = "white"),
                     axis.text.x = element_text(size=15),
                     axis.text.y = element_text(size=15),
                     axis.title.y = element_text(size=15, face="bold"),
                     axis.title.x = element_text(size=15, face="bold"),
                     legend.title = element_text(size=10, face="bold"),
                     legend.text = element_text(size = 10),
                     plot.title = element_text(face="bold", vjust=1))


#### FIGURE 5A

# load data from regression
treatment_effect_data <- read.table('period_state_regr.csv', header=T, sep=",")
attach(treatment_effect_data)

# create period shift
treatment_effect_data <-dplyr::mutate(treatment_effect_data, period_shift = parm + 1)

# plot figure 5A

ggplot() +
  geom_hline(yintercept=0, linetype="solid", 
             color = "grey", size=2) +
  geom_segment(aes(x = 0, xend=0, y = -0.02, yend = 0.2), linetype="solid", color = "red", size=2) +
  geom_errorbar(data=treatment_effect_data, aes(x=period_shift, ymin=min95,ymax=max95,width=0.1), size=2) +
  geom_point(data=treatment_effect_data, aes(x=period_shift,y=estimate), size=4) +
  geom_line(data=treatment_effect_data, aes(x=period_shift,y=estimate)) +
  graph_theme +
  ylab("Estimated effect of a river shift on being under a state (yes/no)") +
  xlab("") +
  annotate("text", x = -0.5, y = .125, label = 'bold("River shifts\n away")', parse=TRUE, color = "Black", size=8)  +
  annotate("text", x = 2.1, y = 0.1435, 
           label = 'bold(underline("Treatment effect")) \nDID-coefficient: 0.14\nComparisonmean: 0.24', 
           parse=TRUE,
           color = "Black",
           hjust = "right",
           size=4.5) +
  annotate("text", x = 2.1, y = 0.1435, 
           label = "\n \n \n DID-coefficient: 0.14\n Comparison mean: 0.24", 
           color = "Black",
           hjust = "inward",
           size=4.5) 

ggsave(file="F5A.pdf", width = 297, height = 210, units = "mm")



#### FIGURE 5B

# load data from regression
graph_treatment_effects_state_8_het_pop_1 <- read.table('period_state_regr_het_pop_1.csv', header=T, sep=",")
attach(graph_treatment_effects_state_8_het_pop_1)

graph_treatment_effects_state_8_het_pop_0 <- read.table('period_state_regr_het_pop_0.csv', header=T, sep=",")
attach(graph_treatment_effects_state_8_het_pop_0)

# create period shift
graph_treatment_effects_state_8_het_pop_1 <-dplyr::mutate(graph_treatment_effects_state_8_het_pop_1, period_shift = parm + 1)
graph_treatment_effects_state_8_het_pop_0 <-dplyr::mutate(graph_treatment_effects_state_8_het_pop_0, period_shift = parm + 1)

# plot figure 5B

ggplot() +
  geom_hline(yintercept=0, linetype="solid", 
             color = "gray", size=2) +
  geom_segment(aes(x = 0, xend=0, y = -0.02, yend = 0.32), linetype="solid", color = "red", size=2) +
  geom_errorbar(data=graph_treatment_effects_state_8_het_pop_0, aes(x=period_shift, ymin=min95,ymax=max95,width=0.1, colour="nopop"), size=2) +
  geom_point(data=graph_treatment_effects_state_8_het_pop_0, aes(x=period_shift,y=estimate), size=4, colour="gray") +
  geom_line(data=graph_treatment_effects_state_8_het_pop_0, aes(x=period_shift,y=estimate), colour="gray") +
  geom_errorbar(data=graph_treatment_effects_state_8_het_pop_1, 
                aes(x=period_shift, ymin=min95,ymax=max95,width=0.1, colour="pop"), size=2) +
  geom_point(data=graph_treatment_effects_state_8_het_pop_1, aes(x=period_shift,y=estimate), size=4, colour="black") +
  geom_line(data=graph_treatment_effects_state_8_het_pop_1, aes(x=period_shift,y=estimate), colour="black") +
  graph_theme +
  ylab("Estimated effect of a river shift on being under a state (yes/no)") +
  xlab("") +
  scale_colour_manual(name = "Samples:", 
                      breaks = c("pop", "nopop"),
                      values = c("pop"="black", "nopop"="gray"
                      ),
                      labels= c( "High pop. dens. pre-shift", "Low pop. dens. pre-shift")) +
  annotate("text", x = -0.5, y = 0.275, label = 'bold("River shifts\n away")', parse=TRUE, color = "Black", size=8)  +
  annotate("text", x = 2.1, y = 0.1969, 
           label = 'bold(underline("High pop. dens. cells"))', 
           parse=TRUE,
           color = "Black",
           hjust = "right",
           size=4.5) +
  annotate("text", x = 2.1, y = 0.1969, 
           label = "\n \n \n DID-coefficient: 0.18\n Comparison mean: 0.28", 
           color = "Black",
           hjust = "inward",
           size=4.5) +
  annotate("text", x = 2.1, y = 0.053, 
           label = 'bold(underline("Low pop. dens. cells"))', 
           parse=TRUE,
           color = "Black",
           hjust = "right",
           size=4.5) +
  annotate("text", x = 2.1, y = 0.053, 
           label = "\n \n \n DID-coefficient: 0.03\n Comparison mean: 0.17", 
           color = "Black",
           hjust = "inward",
           size=4.5) +
  theme(legend.position=c(.2,.75))

ggsave(file="F5B.pdf", width = 297, height = 210, units = "mm")

