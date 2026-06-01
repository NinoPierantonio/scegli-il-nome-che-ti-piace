#Create simple fake whale tracking data for Leaflet workflow
if (!require("pacman"))
  install.packages("pacman")

pacman::p_load(sf, dplyr, lubridate, purrr, adehabitatHR, sp, terra)

#set working environment #select the working directory
setwd(choose.dir())

out_dir <- "fake_leaflet_data" #choose where to save the fake data

if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

#Create fake whale positions
set.seed(123)
n_points <- 50 #50 points per whale

make_fake_whale <- function(whale_id,
                            start_lon,
                            start_lat,
                            end_lon,
                            end_lat) {
  tibble(
    whale_ID = whale_id,
    timestamp = seq(
      from = ymd_hms("2026-05-01 00:00:00"),
      by = "6 hours",
      length.out = n_points
    ),
    lon = seq(start_lon, end_lon, length.out = n_points) + rnorm(n_points, 0, 0.15),
    lat = seq(start_lat, end_lat, length.out = n_points) + rnorm(n_points, 0, 0.15),
    behaviour = sample(
      c("ARS", "Travelling"),
      size = n_points,
      replace = TRUE,
      prob = c(0.45, 0.55)
    )
  )
}

whale_data <- bind_rows(
  make_fake_whale("Whale_01", -32, 54, -30, 42),
  make_fake_whale("Whale_02", -28, 55, -27, 43),
  make_fake_whale("Whale_03", -24, 53, -25, 41)
)

# Convert to sf points
whale_points <- st_as_sf(
  whale_data,
  coords = c("lon", "lat"),
  crs = 4326,
  remove = FALSE
)

#Create fake whale track lines
whale_tracks <- whale_points %>%
  arrange(whale_ID, timestamp) %>%
  group_by(whale_ID) %>%
  summarise(
    first_timestamp = min(timestamp),
    last_timestamp = max(timestamp),
    n_points = n(),
    geometry = st_combine(geometry),
    .groups = "drop"
  ) %>%
  st_cast("LINESTRING")

#Calculate home range and core range
# Kernel home ranges need projected coordinates, not lon/lat
# Use a North Atlantic Lambert Azimuthal Equal Area projection
laea_crs <- "+proj=laea +lat_0=48 +lon_0=-28 +datum=WGS84 +units=m +no_defs"
whale_points_laea <- st_transform(whale_points, laea_crs)

whale_sp <- as(whale_points_laea, "Spatial")# Convert to Spatial object for adehabitatHR

# Kernel utilisation distribution by whale
kud <- kernelUD(whale_sp[, "whale_ID"],
                h = "href",
                grid = 1000,
                extent = 10)

# 95% home range
home_range_95_sp <- getverticeshr(kud, percent = 95)

# 50% core range
core_range_50_sp <- getverticeshr(kud, percent = 50)

# Convert back to sf and WGS84
home_range_95 <- st_as_sf(home_range_95_sp) %>%
  st_transform(4326) %>%
  rename(whale_ID = id) %>%
  mutate(range_type = "Home range 95")

core_range_50 <- st_as_sf(core_range_50_sp) %>%
  st_transform(4326) %>%
  rename(whale_ID = id) %>%
  mutate(range_type = "Core range 50")

#Create fake MPA polygons
mpa_1_coords <- matrix(c(-33, 51, -27, 51, -27, 46, -33, 46, -33, 51),
                       ncol = 2,
                       byrow = TRUE)

mpa_2_coords <- matrix(c(-29, 48, -22, 48, -22, 42, -29, 42, -29, 48),
                       ncol = 2,
                       byrow = TRUE)

mpa_1 <- st_polygon(list(mpa_1_coords))
mpa_2 <- st_polygon(list(mpa_2_coords))

mpas <- st_sf(
  mpa_name = c("Fake MPA North", "Fake MPA South"),
  mpa_type = c("Marine Protected Area", "Marine Protected Area"),
  geometry = st_sfc(mpa_1, mpa_2),
  crs = 4326
)

#Create fake traffic raster
traffic_raster <- rast(
  xmin = -37,
  xmax = -18,
  ymin = 38,
  ymax = 58,
  resolution = 1,
  crs = "EPSG:4326"
) # Raster extent covering the fake whale data

xy <- crds(traffic_raster, df = TRUE) # Create fake traffic values

traffic_values <- with(
  # add higher traffic area
  xy,
  exp(-((x + 27)^2 / 20 + (y - 45)^2 / 18)) * 100 +
    runif(nrow(xy), 0, 15)
)

values(traffic_raster) <- traffic_values
names(traffic_raster) <- "fake_traffic_density"

#Save everything
# Vector layers as GeoPackage
st_write(
  whale_points,
  file.path(out_dir, "whale_points_fake.gpkg"),
  layer = "whale_points_fake",
  delete_dsn = TRUE
)

st_write(
  whale_tracks,
  file.path(out_dir, "whale_tracks_fake.gpkg"),
  layer = "whale_tracks_fake",
  delete_dsn = TRUE
)

st_write(
  home_range_95,
  file.path(out_dir, "home_range_95_fake.gpkg"),
  layer = "home_range_95_fake",
  delete_dsn = TRUE
)

st_write(
  core_range_50,
  file.path(out_dir, "core_range_50_fake.gpkg"),
  layer = "core_range_50_fake",
  delete_dsn = TRUE
)

st_write(
  mpas,
  file.path(out_dir, "mpas_fake.gpkg"),
  layer = "mpas_fake",
  delete_dsn = TRUE
)

# Raster as GeoTIFF
writeRaster(traffic_raster,
            file.path(out_dir, "traffic_density_fake.tif"),
            overwrite = TRUE)

# Optional: also save traffic raster as polygon GeoPackage
# This is useful if you want everything as vector layers for Leaflet
traffic_polygons <- as.polygons(traffic_raster) %>%
  st_as_sf() %>%
  rename(traffic_density = fake_traffic_density)

st_write(
  traffic_polygons,
  file.path(out_dir, "traffic_density_fake_polygons.gpkg"),
  layer = "traffic_density_fake_polygons",
  delete_dsn = TRUE
)

#Quick check
print(whale_points)
print(whale_tracks)
print(home_range_95)
print(core_range_50)
print(mpas)
print(traffic_raster)

message("Fake data saved in folder: ", out_dir)
