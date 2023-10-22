library(sf)  
library(sp)  
library(ggplot2)
library(raster)
library(ggrepel)
library(ggspatial)

# Objective: Figure 3

# set working dir here
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

# load data

# shapefile of modern iraq
Iraq <-getData("GADM", country="IRQ", level=0)
Iraq.SP<-st_as_sf(x=Iraq)
Iraq.SP<-st_transform(x = Iraq.SP, crs = 4326)

# shapefile of modern iran
Iran <-getData("GADM", country="IRN", level=0)
Iran.SP<-st_as_sf(x=Iran)
Iran.SP<-st_transform(x = Iran.SP, crs = 4326)

## load shapefiles

shape_to_sea <- st_read("Coast_F3.shp")
shape_to_sea <- transform_input_to_sf(shape_to_sea)


################ FIGURE 3A ############

lok_canals <- st_read("A2_LOK_JN_Canals_3500cross_FINAL.shp")
lok_canals <- transform_input_to_sf(lok_canals)

lbb_canals <- st_read("A2_LBB_Late_Uruk_Canals_FINAL.shp")
lbb_canals <- transform_input_to_sf(lbb_canals)

hoc_canals <- st_read("A3_HoC_Canals_Jamdet_Nasr_3500cross_FINAL.shp")
hoc_canals <- transform_input_to_sf(hoc_canals)

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

buildings_pre_by_city <- st_read("JN_cities_buildings_F3.shp")
buildings_pre_by_city <- transform_input_to_sf(buildings_pre_by_city)

cities <- st_read("JN_cities_F3.shp")
cities <- transform_input_to_sf(cities)

state_pre_by_city = dplyr::filter(cities, 
                                  NAME=="Tell Uqair" | 
                                    NAME=="Khafagi" | 
                                    NAME=="Tell Jemdet Nasr"|
                                    NAME=="Esnunna"|
                                    NAME=="Uruk" 
)


ggplot() +
  geom_sf(data=Iraq.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=Iran.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=sea_4000BC_1, alpha=1, color=NA, fill=sea_color) +
  geom_sf(data=sea_4000BC_2, alpha=1, color=NA, fill=sea_color) +
  geom_sf(data=shape_to_sea, alpha=1, color=NA, fill=sea_color) +
  geom_sf(data=euphr_main_3500BC, aes(size="A"), alpha=1, color=river_color,  show.legend="line") +
  geom_sf(data=euphr_sec_3500BC, aes(size="A"), alpha=1, color=river_color,  show.legend="line") +
  geom_sf(data=tigr_main_3500BC, aes(size="A"), alpha=1, color=river_color, show.legend="line") +
  geom_sf(data=tigr_sec_3500BC, aes(size="A"), alpha=1, color=river_color, show.legend="line") +
  geom_sf(data=diyala_3500BC, alpha=1, color=river_color, size=2) +
  geom_sf(data=lbb_canals, aes(size="E"), alpha=1, color=canal_color, linetype="twodash", show.legend="line") +
  geom_sf(data=hoc_canals, aes(size="E"), alpha=1, color=canal_color, linetype="twodash", show.legend="line") +
  geom_sf(data=lok_canals, aes(size="E"), alpha=1, color=canal_color, linetype="twodash", show.legend="line") +
  geom_sf(data=cities, shape=18, color=city_color, size=5) +
  geom_sf(data=state_pre_by_city, alpha=0.5) + 
  geom_sf(data=state_pre_by_city, aes(shape="B"), alpha=1, color=city_color, size=5, show.legend="point") +
  geom_sf(data=state_pre_by_city,
          pch=21, fill="gray", aes(shape="C"), show.legend="point", alpha=0.2, size=12, colour="black", stroke=1) +
  geom_sf(data=state_pre_by_city,
          pch=21, fill=NA, size=12, colour="black", stroke=1) +
  geom_sf(data=buildings_pre_by_city, aes(shape="A"), alpha=1, color="grey", size=5, show.legend="point") +
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
  scale_size_manual(values = c("A" = main_branch_width,
                               "E" = sec_branch_width), 
                    labels = c("River" ,
                               "Canal"),
                    name = "Water:",
                    guide = guide_legend(override.aes = list(linetype = c("solid", "twodash"), 
                                                             shape = c(NA, NA),
                                                             color=c(river_color, canal_color)))) +
  scale_shape_manual(values = c("A" = 16, "B" = 16, "C"=18, "D"=0), 
                     labels = c("City with admin bulding", 
                                "City", "Settlement", "State"),
                     name = "States, buildings, and settlement:",
                     guide = guide_legend(override.aes = list(
                       color = c("grey", "black", "red", "black"), 
                       linetype = c(NA, NA,NA, NA), size=c(5,5,2,5),
                       shape = c(16, 18 ,18, 0)))) +
  paper_theme +
  theme(legend.position = "right")

ggsave(filename="F3A.pdf", width = 210, height = 297, units = "mm")


################### Figure 3, subfigure b ################################


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

hoc_canals <- st_read("A4_HoC_Canals_Early_Dynastic1_FINAL.shp")
hoc_canals <- transform_input_to_sf(hoc_canals)

lbb_canals <- st_read("A3_LBB_Early_Dynastic_Canals_FINAL.shp")
lbb_canals <- transform_input_to_sf(lbb_canals)

states_post <- st_read("States_boundaries_F4.shp")
states_post <- transform_input_to_sf(states_post)

buildings_post_by_city <- st_read("ED1_cities_buildings_F3.shp")
buildings_post_by_city <- transform_input_to_sf(buildings_post_by_city)

cities <- st_read("ED1_cities_F3.shp")
cities <- transform_input_to_sf(cities)

state_post_by_city = dplyr::filter(cities, 
                                   NAME=="Abu Salabikh" | 
                                     NAME=="Adab"|
                                     NAME=="Esnunna"|
                                     NAME=="Larsa" |
                                     NAME=="Nippur" |
                                     NAME=="Umma" |
                                     NAME=="Uruk" 
)


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
  geom_sf(data=lbb_canals, aes(size="E"), alpha=1, color=canal_color, linetype="twodash", show.legend="line") +
  geom_sf(data=hoc_canals, aes(size="E"), alpha=1, color=canal_color, linetype="twodash", show.legend="line") +
  geom_sf(data=cities, shape=18, color=city_color, size=5) +
  geom_sf(data=states_post, alpha=0.5, aes(shape="D"), show.legend="point") + 
  geom_sf(data=state_post_by_city, alpha=0.3, color=city_color, size=5) +
  geom_sf(data=buildings_post_by_city, aes(shape="A"), alpha=1, color="grey", size=5, show.legend="point") +
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
  annotation_scale(location = "bl", width_hint = 0.5) +
  scale_size_manual(values = c("A" = main_branch_width,
                               "E" = sec_branch_width), 
                    labels = c("River" ,
                               "Canal"),
                    name = "Water:",
                    guide = guide_legend(override.aes = list(linetype = c("solid", "twodash"), 
                                                             shape = c(NA, NA),
                                                             color=c(river_color, canal_color)))) +
  scale_shape_manual(values = c("A" = 16, "B" = 16, "C"=18, "D"=0), 
                     labels = c("City with admin bulding", 
                                "City", "Settlement", "State"),
                     name = "States, buildings, and settlement:",
                     guide = guide_legend(override.aes = list(
                       color = c("grey", "black", "red", "black"), 
                       linetype = c(NA, NA,NA, NA), size=c(5,5,2,5),
                       shape = c(16, 18 ,18, 0)))) +
  paper_theme +
  theme(legend.position = "right")

ggsave(filename="F3B.pdf", width = 210, height = 297, units = "mm")




