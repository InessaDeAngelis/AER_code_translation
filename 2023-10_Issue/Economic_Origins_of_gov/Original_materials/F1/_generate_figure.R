library(ggplot2)
library(ggspatial)
library(maptools)
library(raster)
library(sf)
library(sp)

# Objective: Replicate figure 1

# set working dir here
replication_dir <- 
setwd(replication_dir)

############################# PRELIMINARIES ##########################


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
                     plot.title = element_text(face="bold", vjust=1))


country_fill_color <- "white"
bbox_border_color <- "black"

river_color <- "blue"
sea_color <- "lightblue"
modern_city_color <- "black"

main_branch_width <- 2
sec_branch_width <- 1

world_basemap_bounding_box = st_as_sfc(st_bbox(c(xmin = 43, xmax = 49.5,
                                                 ymin = 28.2, ymax = 35.025),
                                               crs = 4326))

iraq_basemap_bounding_box = st_as_sfc(st_bbox(c(xmin = 44, xmax = 47,
                                                ymin = 30.8, ymax = 33.95),
                                              crs = 4326))


############################# GET DATA ##########################

# shapefile of modern iraq
Iraq <-getData("GADM", country="IRQ", level=0)
Iraq.SP<-st_as_sf(x=Iraq)
Iraq.SP<-st_transform(x = Iraq.SP, crs = 4326)

# shapefile of modern iran
Iran <-getData("GADM", country="IRN", level=0)
Iran.SP<-st_as_sf(x=Iran)
Iran.SP<-st_transform(x = Iran.SP, crs = 4326)

# shapefile of modern kuwait
Kuwait <-getData("GADM", country="KWT", level=0)
Kuwait.SP<-st_as_sf(x=Kuwait)
Kuwait.SP<-st_transform(x = Kuwait.SP, crs = 4326)

# shapefile of modern saudi arabia
sarabia <-getData("GADM", country="SAU", level=0)
sarabia.SP<-st_as_sf(x=sarabia)
sarabia.SP<-st_transform(x = sarabia.SP, crs = 4326)

# get world and asia
world <- data(wrld_simpl)
world <- st_transform(x = st_as_sf(wrld_simpl), crs = 4326)
asia <- dplyr::filter(world, REGION==142)
europe <- dplyr::filter(world, REGION==2)
africa <- dplyr::filter(world, REGION==150)

# load local datasets
baghdad <- st_read("Baghdad_F1.shp")
baghdad <- transform_input_to_sf(baghdad)

euphrates <- st_read("Euphrates_F1.shp")
euphrates <- transform_input_to_sf(euphrates)

tigris <- st_read("Tigris_F1.shp")
tigris <- transform_input_to_sf(tigris)

hilla <- st_read("Hilla_F1.shp")
hilla <- transform_input_to_sf(hilla)

kut_branch <- st_read("Kut_F1.shp")
kut_branch <- transform_input_to_sf(kut_branch)

shape_to_sea <- st_read("Coast_F1.shp")
shape_to_sea <- transform_input_to_sf(shape_to_sea)

# import grid
grid_cells <- st_read("Grid_F1.shp")
grid_cells <- transform_input_to_sf(grid_cells)


########################## REPLICATE FIGURE 1 ##################################

# Figure 1, subfigure a

ggplot() +
  geom_sf(data=asia, alpha=1, fill=country_fill_color) +
  geom_sf(data=europe, alpha=1, fill=country_fill_color) +
  geom_sf(data=africa, alpha=1, fill=country_fill_color) +
  geom_sf(data=world_basemap_bounding_box, alpha=0.4, color=bbox_border_color) +
  coord_sf(xlim = c(30, 65), ylim = c(10, 50)) +
  annotate("text", x = 41, y = 33, label = 'bold("Iraq")', parse=TRUE) +
  annotate("text", x = 55, y = 33, label = 'bold("Iran")', parse=TRUE) +
  annotate("text", x = 45, y = 25, label = 'bold("Saudi-Arabia")', parse=TRUE) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  paper_theme

ggsave(file="F1A.pdf", width = 210, height = 297, units = "mm")

# Figure 1, subfigure b

ggplot() +
  geom_sf(data=Iraq.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=Iran.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=Kuwait.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=sarabia.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=euphrates, alpha=1, color=river_color) +
  geom_sf(data=tigris, alpha=1, color=river_color) +
  geom_sf(data=hilla, alpha=1, color=river_color) +
  geom_sf(data=kut_branch, alpha=1, color=river_color) +
  geom_sf(data=baghdad, size=5, colour=modern_city_color) +
  geom_sf(data=iraq_basemap_bounding_box, alpha=0.4, color=bbox_border_color) +
  coord_sf(xlim = c(43, 49.5), ylim = c(28.2, 35)) +
  scale_shape_discrete(name = '\n Places:', labels = c('Baghdad')) +
  annotate("text", x = 47.4, y = 29.3, label = "bold(Kuwait)", parse=TRUE) +
  annotate("text", x = 49.1, y = 33.2, label = 'bold("Iran")', parse=TRUE) +
  annotate("text", x = 45, y = 28.4, label = 'bold("Saudi-Arabia")', parse=TRUE) +
  annotate("text", x = 45, y = 33.3, label = 'italic("Baghdad")', parse=TRUE) +
  annotate("text", x = 45, y = 31, label = 'italic("Euphrates")', parse=TRUE) +
  annotate("text", x = 46.35, y = 32.25, label = 'italic("Tigris")', parse=TRUE) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  paper_theme

ggsave(file="F1B.pdf", width = 210, height = 297, units = "mm")

# Figure 1, subfigure c

ggplot() +
  geom_sf(data=Iraq.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=Iran.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=euphrates, alpha=1, color=river_color) +
  geom_sf(data=tigris, alpha=1, color=river_color) +
  geom_sf(data=hilla, alpha=1, color=river_color) +
  geom_sf(data=baghdad, size=5, colour=modern_city_color) +
  geom_sf(data=kut_branch, alpha=1, color=river_color) +
  coord_sf(xlim = c(44, 47), ylim = c(30.8, 33.95)) +
  annotate("text", x = 46.5, y = 33.3, label = 'bold("Iran")', parse=TRUE) +
  annotate("text", x = 44.7, y = 33.3, label = 'italic("Baghdad")', parse=TRUE) +
  annotate("text", x = 45, y = 31.2, label = 'italic("Euphrates")', parse=TRUE) +
  annotate("text", x = 46.5, y = 32.2, label = 'italic("Tigris")', parse=TRUE) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  paper_theme 

ggsave(file="F1C.pdf", width = 210, height = 297, units = "mm")

# Figure 1, subfigure d

ggplot() +
  geom_sf(data=Iraq.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=Iran.SP, alpha=1, fill=country_fill_color) +
  geom_sf(data=euphrates, alpha=1, color=river_color) +
  geom_sf(data=tigris, alpha=1, color=river_color) +
  geom_sf(data=hilla, alpha=1, color=river_color) +
  geom_sf(data=baghdad, size=5, colour=modern_city_color) +
  geom_sf(data=kut_branch, alpha=1, color=river_color) +
  geom_sf(data=grid_cells, fill="grey", alpha=0.1) +
  coord_sf(xlim = c(44, 47), ylim = c(30.8, 33.95)) +
  annotate("text", x = 46.5, y = 33.3, label = 'bold("Iran")', parse=TRUE) +
  annotate("text", x = 44.7, y = 33.3, label = 'italic("Baghdad")', parse=TRUE) +
  annotate("text", x = 45, y = 31.2, label = 'italic("Euphrates")', parse=TRUE) +
  annotate("text", x = 46.5, y = 32.2, label = 'italic("Tigris")', parse=TRUE) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  paper_theme 

ggsave(file="F1D.pdf", width = 210, height = 297, units = "mm")
