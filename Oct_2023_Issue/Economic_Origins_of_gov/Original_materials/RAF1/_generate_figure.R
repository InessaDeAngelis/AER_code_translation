library(ggplot2)

# Objective: Replicate Figure 1 in the results appendix

# set working dir here
replication_dir <- 
setwd(replication_dir)

# load data
graph_rainfall_shifts <- read.table('data_for_rainfall_graph.csv', header=T, sep=",")
attach(graph_rainfall_shifts)

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


################ REPLICATE RESULTS APPENDIX FIGURE 1 ###########################

ggplot(graph_rainfall_shifts, aes(x = year_100, y = first_diff, group=1)) +
  geom_line(size=2) +
  ylab("First difference of rainfall (sd)") +
  xlab("Year (BCE/CE)") +
  geom_segment(aes(x = -4200, y = -0.25, xend = -4200, yend = 0.5),  color = "blue") +
  annotate("text", x = -4200, y = 0.53, label = "(1)") +
  geom_segment(aes(x = -3500, y = -0.25, xend = -3500, yend = 0.5),  color = "blue") +
  annotate("text", x = -3500, y = 0.53, label = "(2)") +
  geom_segment(aes(x = -2900, y = -0.25, xend = -2900, yend = 0.5),  color = "blue") +
  annotate("text", x = -2900, y = 0.53, label = "(3)") +
  geom_segment(aes(x = -2600, y = -0.25, xend = -2600, yend = 0.5),  color = "blue") +
  annotate("text", x = -2600, y = 0.53, label = "(4)") +
  geom_segment(aes(x = -1750, y = -0.25, xend = -1750, yend = 0.5),  color = "blue") +
  annotate("text", x = -1750, y = 0.53, label = "(5)") +
  geom_segment(aes(x = -1000, y = -0.25, xend = -1000, yend = 0.5),  color = "blue") +
  annotate("text", x = -1000, y = 0.53, label = "(6)") +
  geom_segment(aes(x = -700, y = -0.25, xend = -700, yend = 0.5),  color = "blue") +
  annotate("text", x = -700, y = 0.53, label = "(7)") +
  geom_segment(aes(x = 500, y = -0.25, xend = 500, yend = 0.5),  color = "blue") +
  annotate("text", x = 500, y = 0.53, label = "(8)") +
  geom_segment(aes(x = 900, y = -0.25, xend = 900, yend = 0.5),  color = "blue") +
  annotate("text", x = 900, y = 0.53, label = "(9)") +
  geom_segment(aes(x = 1850, y = -0.25, xend = 1850, yend = 0.5),  color = "blue") +
  annotate("text", x = 1850, y = 0.53, label = "(10)") +
  scale_x_continuous(breaks=seq(-5000, 2000, 1000)) +
  graph_theme

ggsave(file="RAF1.pdf", width = 297, height = 210, units = "mm")

