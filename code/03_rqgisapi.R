# Filename: 03_rqgisapi.R (2017-08-01)
#
# TO DO: Checking out the Network API and rqgisapi
#
# Author(s): Jannes Muenchow
#
#**********************************************************
# CONTENTS-------------------------------------------------
#**********************************************************
#
# 1. ATTACH PACKAGES AND DATA
# 2. rqgisapi
#
#**********************************************************
# 1 ATTACH PACKAGES AND DATA-------------------------------
#**********************************************************

# attach packages
library("RQGIS")
library("qgisremote")
library("sf")

# define directories
dir_main <- "D:/uni/fsu/teaching/misc/geostats_rqgis"
dir_data <- file.path(dir_main, "data")
dir_ima <- file.path(dir_main, "images")

# attach data
load(file.path(dir_ima, "02_poisson.Rdata"))

#**********************************************************
# 2 rqgisapi-----------------------------------------------
#**********************************************************

# install Network API
browseURL("https://gitlab.com/qgisapi/networkapi#testing")
# copy plugin into:
# Windows: C:/OSGeo4W64/apps/qgis/python/plugins
# Linux: /usr/share/qgis/python/plugins

# install qgisremote.git
# devtools::install_git('https://gitlab.com/qgisapi/qgisremote.git', 
#                       quiet = FALSE)
# tutorial
browseURL("https://qgisapi.gitlab.io/qgisremote/articles/tutorial.html/")

# open QGIS manually or try
if (Sys.info()["sysname"] == "Windows") {
  # QGIS 2.18
  shell.exec("C:\\OSGEO4~1\\bin\\qgis.bat")  
  # QGIS 2.14
  # shell.exec("C:\\OSGEO4~1\\bin\\qgis-ltr.bat")
} else {
  system("qgis &")
}

# Enable manually Network API!!!

# inspect default connection settings
qgis_options('api')
# start with a blank canvas
iface.newProject()

# tile server services are supported natively from QGIS 2.18 onwards!!! If you
# use QGIS 2.14 add the WMS manually with the help of the OpenLayers Plugin
iface.addTileLayer('http://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                   layerName = 'Google Satellite')
# We could also use OSM
# iface.addTileLayer('http://c.tile.openstreetmap.org/{z}/{x}/{y}.png',
#                    layerName = 'OSMlayer')

# add our points layer to the QGIS map canvas
iface.addRasterLayer(pred_1, layerName = "pred")
# Properties - STyle - Render type: Singleband pseudocolor
iface.addVectorLayer(st_transform(random_points, 4326), baseName = "points")

# since we have added first a google map canvas, the crs is 3857, and we need to
# use the corresponding coordinates to center our map (otherwise it would have
# been 4326, i.e. WGS84).
# reproject random_points and extract the coordinates
x <- random_points %>%
  # in case you are using QGIS 2.14 uncomment the next line and comment out the
  # next line after that
  # st_transform(., 4326) %>%
  st_transform(., 3857) %>%
  st_coordinates
# take the mean of the xy-columns and convert the point into an sfc-object
x <- colMeans(x)

mapCanvas.setCenter(x[[1]], x[[2]])
mapCanvas.zoomScale(15000)
# zoom out again
# mapCanvas.zoomToFullExtent()

x <- mapLayers()
names(x)
# retrieve our edited points layer (just attribute data)
features <- mapLayer.getFeatures(x[[3]])
# retrieve an sf-object
layerdata <- mapLayer.getFeatures(x[[3]], geometry = TRUE)
plot(st_geometry(layerdata))
