### COMPLETE CODE: INTERACTIVE INDIAN STATE MAP ###
# Install required packages
if (!requireNamespace("geodata", quietly = TRUE)) install.packages("geodata")
if (!requireNamespace("tmap", quietly = TRUE)) install.packages("tmap")
if (!requireNamespace("sf", quietly = TRUE)) install.packages("sf")

# Load libraries
library(geodata)
library(tmap)
library(sf)

# Download India state boundaries
india <- gadm(country = "IND", level = 1, path = tempdir()) |> 
  st_as_sf()  # Convert to simple features format

# Create interactive map
tmap_mode("view")  # Set interactive viewing mode

tm_shape(india) +
  tm_polygons(
    fill = "NAME_1",               # Color by state name
    fill.scale = tm_scale_intervals(
      values = "Oranges",          # Orange color palette
      n = 5                        # Number of color intervals
    ),
    id = "NAME_1",                 # Show state name on hover
    popup.vars = c("State" = "NAME_1"),  # Show state name on click
    border.col = "white",          # White state borders
    lwd = 0.3                      # Border line width
  ) +
  tm_title("BJP WINS - Indian States") +
  tm_compass(position = c("right", "top")) +    # Add compass
  tm_scale_bar(position = c("left", "bottom"))  # Add scale bar

