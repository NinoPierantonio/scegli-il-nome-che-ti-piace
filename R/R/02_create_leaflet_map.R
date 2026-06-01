# Create interactive Leaflet map for GitHub
if (!require("pacman"))
  install.packages("pacman")

pacman::p_load(
  sf,
  terra,
  dplyr,
  leaflet,
  leaflet.extras,
  leafpop,
  leafem,
  htmlwidgets,
  htmltools,
  viridis,
  lubridate,
  ggplot2,
  tidyterra
)

# Set working environment and load the data
setwd(choose.dir()) #set the working directory
data_dir <- "fake_leaflet_data" #select the folder where your data are stored
out_dir  <- "github_map" #create a folder for output

if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

#I prefer working with geopackages so i do not have to deal with all the shp and associated files, much more clean
#if you dont know how to convert each of your shapefiles to separate geopackages do the following:

my_layer_shp <- #read the shapefile from the data directory
  st_read("path/to/my_shapefile.shp")

st_write(
  # Save as GeoPackage
  my_layer,
  "path/to/my_layer.gpkg",
  layer = "my_layer",
  delete_dsn = TRUE
)

whale_points <- st_read(file.path(data_dir, "whale_points_fake.gpkg"))
whale_tracks <- st_read(file.path(data_dir, "whale_tracks_fake.gpkg"))
home_range_95 <- st_read(file.path(data_dir, "home_range_95_fake.gpkg"))
core_range_50 <- st_read(file.path(data_dir, "core_range_50_fake.gpkg"))
mpas <- st_read(file.path(data_dir, "mpas_fake.gpkg"))
traffic_raster <- terra::rast(file.path(data_dir, "traffic_density_fake.tif"))

names(traffic_raster) <- "traffic_density"

# Optional vectorised traffic layer
traffic_polygons <- st_read(file.path(data_dir, "traffic_density_fake_polygons.gpkg"))

#make a quick static map for visual inspection
ggplot() +
  geom_spatraster(data = traffic_raster, aes(fill = traffic_density), alpha = 0.6) +
  scale_fill_viridis_c(name = "Traffic\ndensity", na.value = NA) +
  geom_sf(
    data = home_range_95,
    fill = NA,
    colour = "green",
    linewidth = 0.8
  ) +
  geom_sf(
    data = core_range_50,
    fill = NA,
    colour = "red",
    linewidth = 0.8
  ) +
  geom_sf(
    data = mpas,
    fill = "darkgreen",
    colour = "darkgreen",
    alpha = 0.25,
    linewidth = 0.7
  ) +
  geom_sf(data = whale_tracks,
          colour = "black",
          linewidth = 0.8) +
  geom_sf(
    data = whale_points,
    aes(colour = behaviour),
    size = 2,
    alpha = 0.9
  ) +
  coord_sf(expand = TRUE) +
  labs(
    title = "",
    subtitle = "",
    x = "Longitude",
    y = "Latitude",
    colour = "Whale ID"
  ) +
  facet_wrap( ~ whale_ID) +
  theme_minimal()

# make sure layers are in WGS84 for Leaflet
whale_points  <- st_transform(whale_points, 4326)
whale_tracks  <- st_transform(whale_tracks, 4326)
home_range_95 <- st_transform(home_range_95, 4326)
core_range_50 <- st_transform(core_range_50, 4326)
mpas          <- st_transform(mpas, 4326)
traffic_polygons <- st_transform(traffic_polygons, 4326)


# Prepare attributes for leaflet maps and colouts
whale_points <- whale_points %>%
  mutate(
    timestamp = as.POSIXct(timestamp, tz = "UTC"),
    timestamp_chr = format(timestamp, "%Y-%m-%d %H:%M:%S"),
    date_only = as.Date(timestamp),
    date_chr = format(date_only, "%Y-%m-%d"),
    behaviour = as.factor(behaviour),
    whale_ID = as.factor(whale_ID)
  )

whale_tracks <- whale_tracks %>%
  mutate(whale_ID = as.factor(whale_ID))

home_range_95 <- home_range_95 %>%
  mutate(whale_ID = as.factor(whale_ID))

core_range_50 <- core_range_50 %>%
  mutate(whale_ID = as.factor(whale_ID))

#create colour palettes
pal_whale <- colorFactor(palette = c("#1b9e77", "#d95f02", "#7570b3"),
                         domain = whale_points$whale_ID)

pal_behaviour <- colorFactor(
  palette = c("ARS" = "#e7298a", "Travelling" = "#66a61e"),
  domain = whale_points$behaviour
)

pal_date <- colorNumeric(
  palette = colorRampPalette(c("darkgreen", "yellow", "orange", "red"))(100),
  domain = as.numeric(whale_points$date_only),
  na.color = "transparent"
)

pal_traffic <- colorNumeric(
  palette = "viridis",
  domain = terra::values(traffic_raster),
  na.color = "transparent"
)

#create text for popups
point_popup <- paste0(
  "<b>Whale ID:</b> ",
  whale_points$whale_ID,
  "<br>",
  "<b>Date and time:</b> ",
  whale_points$timestamp_chr,
  "<br>",
  "<b>Behaviour:</b> ",
  whale_points$behaviour,
  "<br>",
  "<b>Latitude:</b> ",
  round(whale_points$lat, 4),
  "<br>",
  "<b>Longitude:</b> ",
  round(whale_points$lon, 4)
)

track_popup <- paste0(
  "<b>Whale ID:</b> ",
  whale_tracks$whale_ID,
  "<br>",
  "<b>Number of points:</b> ",
  whale_tracks$n_points
)

home_popup <- paste0("<b>Whale ID:</b> ",
                     home_range_95$whale_ID,
                     "<br>",
                     "<b>Range:</b> 95% home range")

core_popup <- paste0("<b>Whale ID:</b> ",
                     core_range_50$whale_ID,
                     "<br>",
                     "<b>Range:</b> 50% core area")

mpa_popup <- paste0("<b>MPA name:</b> ",
                    mpas$mpa_name,
                    "<br>",
                    "<b>Type:</b> ",
                    mpas$mpa_type)

#create the Leaflet map
m <- leaflet(options = leafletOptions(
  preferCanvas = TRUE,
  minZoom = 3,
  maxZoom = 12
)) %>%
  addProviderTiles(
    #add several selectable basemaps based on what you like
    providers$CartoDB.Positron,
    group = "CartoDB Positron"
  ) %>%
  addProviderTiles(providers$Esri.WorldImagery, group = "ESRI World Imagery") %>%
  addProviderTiles(providers$OpenStreetMap, group = "OpenStreetMap") %>%
  addRasterImage(
    #add traffic data
    traffic_raster,
    colors = pal_traffic,
    opacity = 0.55,
    group = "Fake traffic density",
    project = TRUE
  ) %>%
  addPolygons(
    #add MPAs
    data = mpas,
    group = "Fake MPAs",
    color = "#006d2c",
    weight = 2,
    opacity = 1,
    fillColor = "#74c476",
    fillOpacity = 0.20,
    popup = mpa_popup,
    label = ~ mpa_name
  ) %>%
  addPolygons(
    #add ranges
    data = home_range_95,
    group = "95% home range",
    color = "#de2d26",
    weight = 2,
    opacity = 1,
    fillColor = "#fb6a4a",
    fillOpacity = 0.15,
    popup = home_popup,
    label = ~ paste0(whale_ID, " - 95% home range")
  ) %>%
  addPolygons(
    data = core_range_50,
    group = "50% core area",
    color = "#54278f",
    weight = 2,
    opacity = 1,
    fillColor = "#756bb1",
    fillOpacity = 0.25,
    popup = core_popup,
    label = ~ paste0(whale_ID, " - 50% core area")
  ) %>%
  addPolylines(
    #add whale tracks
    data = whale_tracks,
    group = "Whale tracks",
    color = ~ pal_whale(whale_ID),
    weight = 3,
    opacity = 0.9,
    popup = track_popup,
    label = ~ as.character(whale_ID)
  ) %>%
  addCircleMarkers(
    #hale positions coloured by whale ID
    data = whale_points,
    group = "Whale positions by ID",
    radius = 4,
    color = ~ pal_whale(whale_ID),
    fillColor = ~ pal_whale(whale_ID),
    fillOpacity = 0.85,
    stroke = FALSE,
    popup = point_popup,
    label = ~ paste0(whale_ID, " - ", timestamp_chr)
  ) %>%
  addCircleMarkers(
    #Whale positions coloured by behaviour
    data = whale_points,
    group = "Whale positions by behaviour",
    radius = 4,
    color = ~ pal_behaviour(behaviour),
    fillColor = ~ pal_behaviour(behaviour),
    fillOpacity = 0.85,
    stroke = FALSE,
    popup = point_popup,
    label = ~ paste0(whale_ID, " - ", behaviour)
  ) %>%
  addCircleMarkers(
    #Whale positions coloured by date
    data = whale_points,
    group = "Whale positions by date",
    radius = 4,
    color = ~ pal_date(as.numeric(date_only)),
    fillColor = ~ pal_date(as.numeric(date_only)),
    fillOpacity = 0.85,
    stroke = FALSE,
    popup = point_popup,
    label = ~ paste0(whale_ID, " - ", date_chr)
  ) %>%
  addLegend(
    #add legends
    position = "bottomright",
    pal = pal_whale,
    values = whale_points$whale_ID,
    title = "Whale ID",
    group = "Whale positions by ID"
  ) %>%
  addLegend(
    position = "bottomright",
    pal = pal_behaviour,
    values = whale_points$behaviour,
    title = "Behaviour",
    group = "Whale positions by behaviour"
  ) %>%
  addLegend(
    position = "bottomright",
    pal = pal_date,
    values = as.numeric(whale_points$date_only),
    title = "Date<br>early to late",
    labFormat = labelFormat(
      transform = function(x)
        as.Date(x, origin = "1970-01-01")
    ),
    group = "Whale positions by date"
  ) %>%
  addLegend(
    position = "bottomleft",
    pal = pal_traffic,
    values = terra::values(traffic_raster),
    title = "Fake traffic density",
    group = "Fake traffic density"
  ) %>%
  addLayersControl(
    #layer controls for leaflet
    baseGroups = c("CartoDB Positron", "ESRI World Imagery", "OpenStreetMap"),
    overlayGroups = c(
      "Fake traffic density",
      "Fake MPAs",
      "95% home range",
      "50% core area",
      "Whale tracks",
      "Whale positions by ID",
      "Whale positions by behaviour",
      "Whale positions by date"
    ),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  addScaleBar(
    #add scalebar
    position = "bottomleft",
    options = scaleBarOptions(metric = TRUE, imperial = FALSE)
  ) %>%
  addMiniMap(
    #add inset map
    tiles = providers$CartoDB.Positron,
    toggleDisplay = TRUE,
    position = "bottomright"
  ) %>%
  addMeasure(
    #add some useful tools for measuring for example
    position = "topleft",
    primaryLengthUnit = "kilometers",
    secondaryLengthUnit = "meters",
    primaryAreaUnit = "sqkilometers",
    secondaryAreaUnit = "hectares",
    activeColor = "#de2d26",
    completedColor = "#756bb1"
  ) %>%
  addFullscreenControl(position = "topleft") %>%
  addResetMapButton() %>%
  addMouseCoordinates() %>%
  fitBounds(
    #set initial map view
    lng1 = min(whale_points$lon, na.rm = TRUE) - 2,
    lat1 = min(whale_points$lat, na.rm = TRUE) - 2,
    lng2 = max(whale_points$lon, na.rm = TRUE) + 2,
    lat2 = max(whale_points$lat, na.rm = TRUE) + 2
  )

m <- m %>% # optionally hide duplicate/overlapping point layers by default
  hideGroup("Whale positions by behaviour") %>%
  hideGroup("Whale positions by date")

m # view the interactive map

#save the map as a self-contained HTML
htmlwidgets::saveWidget(
  widget = m,
  file = file.path(out_dir, "index.html"),
  selfcontained = TRUE,
  libdir = "index_files",
  title = "Fake whale tracking interactive map"
)

message("Map saved to: ", file.path(out_dir, "index.html"))
