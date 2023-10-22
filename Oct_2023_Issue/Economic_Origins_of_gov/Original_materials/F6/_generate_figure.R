library(ggplot2)
library(forcats)

# Objective: Figure 6

# set working dir here
replication_dir <- 
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


# load data
graph_bar_tablet_data <- read.table('graph_bar_tablets.csv', header=T, sep=",")
attach(graph_bar_tablet_data)


### Figure 6A

# select, and reorder data
sub_df <- dplyr::filter(graph_bar_tablet_data, outcome=="Chief" | outcome=="Lineage head")
sub_df <- dplyr::mutate(sub_df, outcome = fct_relevel(outcome, "Lineage head", "Chief"))

ggplot(sub_df, fill=as_factor(treatment), aes(y=m_, x=as_factor(treatment))) + 
  geom_col(aes(fill=as_factor(treatment))) +
  facet_grid(~ outcome ) +
  scale_fill_manual(name = "Post-treatment: ", values=c("grey", "maroon")) +
  ylab("Fraction of cuneiform tablets that mention: ") +
  theme(legend.key=element_rect(fill=NA), 
        legend.position="bottom", 
        panel.grid.major = element_line(colour = "grey"),
        panel.grid.minor = element_line(colour = NA),
        panel.border = element_rect(fill = NA, colour = "black"), 
        panel.background = element_rect(fill = "white"),
        axis.text.x = element_blank(),
        axis.text.y = element_text(size=15),
        axis.title.y = element_text(size=15, face="bold"),
        axis.title.x = element_blank(),
        legend.title = element_text(size=20, face="bold"),
        legend.text = element_text(size = 20),
        plot.title = element_text(face="bold", vjust=1),
        strip.text.x = element_text(size = 20, face="bold"))


ggsave(file="F6A.pdf", height = 297, width = 210, units = "mm")


### Figure 6B

# load data
sub_df <- dplyr::filter(graph_bar_tablet_data, outcome=="Canals" | outcome=="Tribute")

ggplot(sub_df, fill=as_factor(treatment), aes(y=m_, x=as_factor(treatment))) + 
  geom_col(aes(fill=as_factor(treatment))) +
  facet_grid(~ outcome ) +
  scale_fill_manual(name = "Post-treatment: ", values=c("grey", "maroon")) +
  ylab("Fraction of cuneiform tablets that mention: ") +
  theme(legend.key=element_rect(fill=NA), 
        legend.position="bottom", 
        panel.grid.major = element_line(colour = "grey"),
        panel.grid.minor = element_line(colour = NA),
        panel.border = element_rect(fill = NA, colour = "black"), 
        panel.background = element_rect(fill = "white"),
        axis.text.x = element_blank(),
        axis.text.y = element_text(size=15),
        axis.title.y = element_text(size=15, face="bold"),
        axis.title.x = element_blank(),
        legend.title = element_text(size=20, face="bold"),
        legend.text = element_text(size = 20),
        plot.title = element_text(face="bold", vjust=1),
        strip.text.x = element_text(size = 20, face="bold"))


ggsave(file="F6B.pdf", height = 297, width = 210, units = "mm")

