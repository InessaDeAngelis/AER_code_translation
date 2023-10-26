library(sf)  
library(sp)  
library(ggplot2)
library(raster)
library(ggrepel)
library(ggspatial)

# Objective: replicate Figure 4

replication_dir <- 
setwd(replication_dir)

# Function: Take shapefile and get into sf format, for easy mapping


transform_input_to_sf <- function(
  input, 
  input_coords = c("Easting", "Northing"),
  input_crs = 4326, 
  output_crs = 4326){
  # Load a shape file
  #
  # Args:
  #   input: (obj) a SpatialDataFrame or other object that can be read as sf object
  #   input_coords: (list) a list of current projection coords name, defaults to WGS easting northing
  #   input_crs: (int) a projection code, defaults to WGS84 (==4326). Projection of input
  #   output_crs: (int) a projection code, defaults to WGS84 (==4326). Projected into.
  #
  # Returns:
  #
  # a sf spatial object, behaves as data.frame
  # with extra column holding spatial info
  return(st_transform(x=st_as_sf(input, coords = input_coords, crs = input_crs), crs=output_crs))}

# set theme for maps

paper_theme <- theme(legend.key=element_rect(fill=NA), 
                     panel.grid.major = element_line(colour = NA),
                     panel.grid.minor = element_line(colour = NA),
                     panel.border = element_rect(fill = NA, colour = "black"), 
                     panel.background = element_rect(fill = "lightblue"),
                     axis.ticks = element_blank(), 
                     axis.text.y = element_blank(),
                     axis.text.x = element_blank(),
                     axis.title.y = element_blank(),
                     axis.title.x = element_blank(),
                     legend.title = element_text(size=10, face="bold"),
                     legend.text = element_text(size = 10),
                     plot.title = element_text(face="bold", vjust=1),
                     legend.position = "bottom")


country_fill_color="white"
bbox_border_color <- "black"


river_color = rgb(0, 112, 255, max=255)
#river_color <- "blue"
sea_color <- "lightblue"
city_color <- "black"
settlement_color <- "red"
canal_color <- "black"

main_branch_width <- 2
sec_branch_width <- 1

############################# GET DATA ##########################

# shapefile of modern iraq
Iraq <-getData("GADM", country="IRQ", level=0)
Iraq.SP<-st_as_sf(x=Iraq)
Iraq.SP<-st_transform(x = Iraq.SP, crs = 4326)

# shapefile of modern iran
Iran <-getData("GADM", country="IRN", level=0)
Iran.SP<-st_as_sf(x=Iran)
Iran.SP<-st_transform(x = Iran.SP, crs = 4326)

shape_to_sea <- st_read("Coast_F3.shp")
shape_to_sea <- transform_input_to_sf(shape_to_sea)


################ FIGURE 4A ############


sea_4000BC_1 <- st_read("Algaze5_4000BC_Lagoons.shp")
sea_4000BC_1 <- transform_input_to_sf(sea_4000BC_1)

sea_4000BC_2 <- st_read("Algaze5_4000BC_Marshes.shp")
sea_4000BC_2 <- transform_input_to_sf(sea_4000BC_2)

# 3500 BC
rivers_3500BC <- st_read("Algaze3500BC_Diyala_Final.shp")
rivers_3500BC <- transform_input_to_sf(rivers_3500BC)

euphr_main_3500BC <- dplyr::filter(rivers_3500BC, Euph_main==1)
euphr_sec_3500BC <- dplyr::filter(rivers_3500BC, Euph_sec==1)
tigr_main_3500BC <- dplyr::filter(rivers_3500BC, Tigr_main==1)
tigr_sec_3500BC <- dplyr::filter(rivers_3500BC, Tigr_sec==1)
diyala_3500BC <- dplyr::filter(rivers_3500BC, Diyala==1)

gc_treatment <- st_read("Grid_treated_F4.shp")
gc_treatment <- transform_input_to_sf(gc_treatment)

state_pre_by_city <- st_read("JN_cities_buildings_F4.shp")
state_pre_by_city <- transform_input_to_sf(state_pre_by_city)


ggplot() +
  geom_sf(data=Iraq.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=Iran.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=sea_4000BC_2, alpha=1, color=NA, fill=sea_color) +
  geom_sf(data=sea_4000BC_2, alpha=1, color=NA, fill=sea_color) +
  geom_sf(data=shape_to_sea, alpha=1, color=NA, fill=sea_color) +
  geom_sf(data=euphr_main_3500BC, aes(size="A"), alpha=1, color=river_color,  show.legend="line") +
  geom_sf(data=euphr_sec_3500BC, aes(size="A"), alpha=1, color=river_color,  show.legend="line") +
  geom_sf(data=tigr_main_3500BC, aes(size="A"), alpha=1, color=river_color, show.legend="line") +
  geom_sf(data=tigr_sec_3500BC, aes(size="A"), alpha=1, color=river_color, show.legend="line") +
  geom_sf(data=diyala_3500BC, alpha=1, color=river_color, size=2) +
  geom_sf(data=gc_treatment, color="gray", fill=NA) +
  coord_sf(xlim = c(44, 47), ylim = c(30.8, 33.95)) +
  annotate("text", x = 46.5, y = 33.2, label = 'bold("Iran")', parse=TRUE) +
  annotate("text", x = 46.8, y = 31.2, label = 'italic("Persian \n Gulf/Marshes")', parse=TRUE) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotate("text", x = 44.2, y = 33.37, label = '.', size=60) +
  scale_size_manual(values = c("A" = main_branch_width),
                    labels = c("River"),
                    name = "Water:",
                    guide = guide_legend(override.aes = list(linetype = c("solid"), 
                                                             shape = c(NA),
                                                             color=c(river_color)))) +
  paper_theme 


ggsave(file="F4A.pdf", width = 210, height = 297, units = "mm")


################ FIGURE 4B ############


ggplot() +
  geom_sf(data=Iraq.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=Iran.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=sea_4000BC_2, alpha=1, color=NA, fill=sea_color) +
  geom_sf(data=sea_4000BC_2, alpha=1, color=NA, fill=sea_color) +
  geom_sf(data=shape_to_sea, alpha=1, color=NA, fill=sea_color) +
  geom_sf(data=euphr_main_3500BC, aes(size="A"), alpha=1, color=river_color,  show.legend="line") +
  geom_sf(data=euphr_sec_3500BC, aes(size="A"), alpha=1, color=river_color,  show.legend="line") +
  geom_sf(data=tigr_main_3500BC, aes(size="A"), alpha=1, color=river_color, show.legend="line") +
  geom_sf(data=tigr_sec_3500BC, aes(size="A"), alpha=1, color=river_color, show.legend="line") +
  geom_sf(data=diyala_3500BC, alpha=1, color=river_color, size=2) +
  geom_sf(data=tigr_main_3500BC, alpha=1, color=river_color, size=2) +
  geom_sf(data=state_pre_by_city, alpha=0.5) + 
  geom_sf(data=state_pre_by_city, aes(shape="B"), alpha=1, color=city_color, size=5, show.legend="point") +
  geom_sf(data=state_pre_by_city,
          pch=21, fill="gray", aes(shape="C"), show.legend="point", alpha=0.2, size=12, colour="black", stroke=1) +
  geom_sf(data=state_pre_by_city,
          pch=21, fill=NA, size=12, colour="black", stroke=1) +
  geom_sf(data=gc_treatment, color="gray", fill=NA) +
  coord_sf(xlim = c(44, 47), ylim = c(30.8, 33.95)) +
  ggrepel::geom_label_repel(
    data = state_pre_by_city,
    aes(label = NAME, geometry = geometry),
    stat = "sf_coordinates",
    min.segment.length = 0,
    colour = city_color,
    segment.colour = "black",
    nudge_y = 0,
    nudge_x = -0.3) +
  annotate("text", x = 46.5, y = 33.2, label = 'bold("Iran")', parse=TRUE) +
  annotate("text", x = 46.8, y = 31.2, label = 'italic("Persian \n Gulf/Marshes")', parse=TRUE) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotate("text", x = 44.2, y = 33.37, label = '.', size=60) +
  scale_shape_manual(values = c("A"=18, "B" = 18, "C"=0), 
                     labels = c("Settlement", "City", "State"),
                     name = "Settlement and States:",
                     guide = guide_legend(override.aes = list(
                       color = c("maroon", "black", "black"), 
                       linetype = c(NA, NA, NA), size=c(4, 5, 5),
                       shape = c(18, 18, 1)))) +
  scale_size_manual(values = c("A" = main_branch_width),
                    labels = c("River"),
                    name = "Water:",
                    guide = guide_legend(override.aes = list(linetype = c("solid"), 
                                                             shape = c(NA),
                                                             color=c(river_color)))) +
  paper_theme 

ggsave(file="F4B.pdf", width = 210, height = 297, units = "mm")


################ FIGURE 4C ############


# 3000 BC
rivers_3000BC <- st_read("Adams_3000BC_Diyala_final.shp")
rivers_3000BC <- transform_input_to_sf(rivers_3000BC)

euphr_main_3000BC <- dplyr::filter(rivers_3000BC, Euph_main==1)
euphr_sec_3000BC <- dplyr::filter(rivers_3000BC, Euph_sec==1)
tigr_main_3000BC <- dplyr::filter(rivers_3000BC, Tigr_main==1)
tigr_sec_3000BC <- dplyr::filter(rivers_3000BC, Tigr_sec==1)
diyala_3000BC <- dplyr::filter(rivers_3000BC, Diyala==1)

sea_3000BC <- st_read("Rsoska_3000BC.shp")
sea_3000BC <- transform_input_to_sf(sea_3000BC)

states_post <- st_read("States_boundaries_F4.shp")
states_post <- transform_input_to_sf(states_post)

state_post_by_city <- st_read("ED1_cities_buildings_F4.shp")
state_post_by_city <- transform_input_to_sf(state_post_by_city)


ggplot() +
  geom_sf(data=Iraq.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=Iran.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=sea_3000BC, alpha=1, color=NA, fill=sea_color) +
  geom_sf(data=shape_to_sea, alpha=1, color=NA, fill=sea_color) +
  geom_sf(data=euphr_main_3000BC, aes(size="A"), alpha=1, color=river_color,  show.legend="line") +
  geom_sf(data=euphr_sec_3000BC, aes(size="A"), alpha=1, color=river_color,  show.legend="line") +
  geom_sf(data=tigr_main_3000BC, aes(size="A"), alpha=1, color=river_color, show.legend="line") +
  geom_sf(data=tigr_sec_3000BC, aes(size="A"), alpha=1, color=river_color, show.legend="line") +
  geom_sf(data=gc_treatment, color="gray", fill=NA) +
  annotate("text", x = 44.2, y = 33.37, label = '.', size=60) +
  coord_sf(xlim = c(44, 47), ylim = c(30.8, 33.95)) +
  annotate("text", x = 46.5, y = 33.2, label = 'bold("Iran")', parse=TRUE) +
  annotate("text", x = 46.8, y = 31.2, label = 'italic("Persian \n Gulf")', parse=TRUE) +
  scale_size_manual(values = c("A" = main_branch_width),
                    labels = c("River"),
                    name = "Water:",
                    guide = guide_legend(override.aes = list(linetype = c("solid"), 
                                                             shape = c(NA),
                                                             color=c(river_color)))) +
  paper_theme 

ggsave(file="F4C.pdf", width = 210, height = 297, units = "mm")


################ FIGURE 4D ############


ggplot() +
  geom_sf(data=Iraq.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=Iran.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=sea_3000BC, alpha=1, color=NA, fill=sea_color) +
  geom_sf(data=shape_to_sea, alpha=1, color=NA, fill=sea_color) +
  geom_sf(data=euphr_main_3000BC, aes(size="A"), alpha=1, color=river_color,  show.legend="line") +
  geom_sf(data=euphr_sec_3000BC, aes(size="A"), alpha=1, color=river_color,  show.legend="line") +
  geom_sf(data=tigr_main_3000BC, aes(size="A"), alpha=1, color=river_color, show.legend="line") +
  geom_sf(data=tigr_sec_3000BC, aes(size="A"), alpha=1, color=river_color, show.legend="line") +
  geom_sf(data=diyala_3000BC, alpha=1, color=river_color, size=2) +
  geom_sf(data=gc_treatment, color="gray", fill=NA) +
  geom_sf(data=states_post, alpha=0.5, aes(shape="C"), show.legend="point") + 
  geom_sf(data=state_post_by_city, aes(shape="B"), alpha=1, color=city_color, size=5, show.legend="point") +
  coord_sf(xlim = c(44, 47), ylim = c(30.8, 33.95)) +
  ggrepel::geom_label_repel(
    data = state_post_by_city,
    aes(label = NAME, geometry = geometry),
    stat = "sf_coordinates",
    min.segment.length = 0,
    colour = city_color,
    segment.colour = "black",
    nudge_y = 0,
    nudge_x = -0.3) +
  annotate("text", x = 46.5, y = 33.2, label = 'bold("Iran")', parse=TRUE) +
  annotate("text", x = 46.8, y = 31.2, label = 'italic("Persian \n Gulf")', parse=TRUE) +
  scale_shape_manual(values = c("A"=18, "B" = 18, "C"=0), 
                     labels = c("Settlement", "City", "State"),
                     name = "Settlement and States:",
                     guide = guide_legend(override.aes = list(
                       color = c("maroon", "black", "black"), 
                       linetype = c(NA, NA, NA), size=c(4, 5, 5),
                       shape = c(18, 18, 0)))) +
  scale_size_manual(values = c("A" = main_branch_width),
                    labels = c("River"),
                    name = "Water:",
                    guide = guide_legend(override.aes = list(linetype = c("solid"), 
                                                             shape = c(NA),
                                                             color=c(river_color)))) +
  paper_theme 


ggsave(file="F4D.pdf", width = 210, height = 297, units = "mm")




