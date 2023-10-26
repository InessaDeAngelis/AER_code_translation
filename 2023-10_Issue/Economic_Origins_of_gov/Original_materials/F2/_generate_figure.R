library(sf)  
library(tidyverse)
library(ggspatial)
library(ggrepel)

# Objective: Figure 2

# set working dir here
replication_dir <-
setwd(replication_dir)


# load data
graph_series_under_state <- read.table('time_series_state.csv', header=T, sep=",")
attach(graph_series_under_state)

graph_rainfall_path_states <- read.table('time_series_rainfall.csv', header=T, sep=",")
attach(graph_rainfall_path_states)

# set theme
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
    

############################ REPLICATE FIGURE 2 ################################

ggplot() +
  
  geom_segment(aes(x = -2900, y = 0, xend = -2900, yend = 1), linetype="solid", color = "grey", size=3) +
  annotate("text", x = -2900, y = -0.05, label = "(1)") +
  geom_segment(aes(x = -2600, y = 0, xend = -2600, yend = 1), linetype="dotted", color = "grey", size=2) +
  annotate("text", x = -2600, y = -0.05, label = "(2)") +
  geom_segment(aes(x = -1800, y = 0, xend = -1800, yend = 1), linetype="dotted", color = "grey", size=2) +
  annotate("text", x = -1800, y = -0.05, label = "(3)") +
  geom_segment(aes(x = -1200, y = 0, xend = -1200, yend = 1), linetype="dotted", color = "grey", size=2) +
  annotate("text", x = -1200, y = -0.05, label = "(4)") +
  geom_segment(aes(x = -626, y = 0, xend = -626, yend = 1), linetype="dotted", color = "grey", size=2) +
  annotate("text", x = -626, y = -0.05, label = "(5)") +
  geom_segment(aes(x = 224, y = 0, xend = 224, yend = 1), linetype="dotted", color = "grey", size=2) +
  annotate("text", x = 224, y = -0.05, label = "(6)") +
  
  annotate("text", x = -3300, y = 1.18, label = "bold('MAIN STUDY PERIOD')", parse=TRUE, color="blue") +
  annotate("segment", x = -3900, xend = -2700, y = 1.13, yend = 1.13, arrow=arrow(ends = "both"), size=2, color="blue") +
  annotate("text", x = -1500, y = 1.10, label = "Extended Study period", color="grey") +
  annotate("segment", x = -5000, xend = 1950, y = 1.05, yend = 1.05, arrow=arrow(ends = "both"), size=2, color="grey") +
  geom_line(data=graph_series_under_state, aes(x = start_year, y = is_under_city_state_map_tot, color="buildings"), size=2)  +
  geom_line(data=graph_rainfall_path_states, aes(x = year, y = scaled_rainfall, color="rainfall"), size=2) +
  scale_y_continuous(breaks=seq(0,1,0.2), sec.axis = sec_axis(~./10, labels=NULL, name = "Rainfall (<- wetter, drier ->)")) +
  scale_color_manual(name = "Legend:",
                     values = c("buildings"="blue", "rainfall"="black"),
                     labels = c("Fraction of sample area under state",
                                "Average rainfall"),
                     guide = guide_legend(override.aes = list(color = c("blue", "black")))) +
  scale_x_continuous(breaks=seq(-5500, 2000, 1000)) +
  ylab("Fraction of sample area under state") +
  xlab("Year (BCE/CE)") +
  graph_theme +
  theme(legend.position = "bottom")

ggsave(file="F2.pdf", width = 297, height = 210, units = "mm")

