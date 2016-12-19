#install.packages("factoextra")
#install.packages("tidyr")
#install.packages("ape")
#install.packages("tidyr")
#install.packages("raster")
#install.packages("RCurl")
#install.packages("rjson")
#install.packages("rgeos")
#install.packages("rgdal")
#install.packages("caret")
#install.packages("e1071")

# load up area shape file:
#library(maptools)
library(raster)
library(RCurl)
library(rjson)
library(rgeos)
library(sp)
library(rgdal)
library(dplyr)
library(tidyr)
library(e1071)

#Function to call API to retrieve walk score
getWalkScore <- function(df) {
  url <- paste("http://api.walkscore.com/score?format=json&lat=",df[3],
                "&lon=",df[2],"&wsapikey=<addApiKey>", sep="")
  walkscoreJSON = fromJSON(getURL(url = url))
  df[5] = walkscoreJSON$walkscore
}

#Function to call API to retrieve transit score
getTransitScore <- function(df) {
  url <- paste("http://transit.walkscore.com/transit/score/?city=San%20Francisco&state=CA&lat=",df[3],
                "&lon=",df[2],"&wsapikey=<addApiKey>", sep="")
  walkscoreJSON = fromJSON(getURL(url = url))
  df[5] = walkscoreJSON$transit_score
}

generateTransportHoodData <- function(areaDF) {
  #Calculate area of neighborhood for density calculation
  area_sqkm <- abs(area(areaDF)) / 1000000
  #Calculate centroid coordinates to calculate walkscore and transit score
  coordinates <- coordinates(gCentroid(areaDF, byid = TRUE))
  saveRDS(areaDF, "output_step1/hood_area.rds")
  transportScore <- data.frame(cbind(areaDF$NAME, coordinates, area_sqkm))

  #Call Walkscore APIs to calulate neighborhood walk score
  message("Walkscore retrieval in progress...")
  transportScore$walkScore <- apply(transportScore, 1, getWalkScore)
  message("Transitscore retrieval in progress...")
  transportScore$transitScore <- apply(transportScore, 1, getTransitScore)
  message("Walkscore API calls completed")

  names(transportScore)[1]<- "NAME"

  #Filter selected data and write to csv
  transportScore <- dplyr::select(transportScore, NAME, area_sqkm, walkScore, transitScore)
  message("Printing head of transport data")
  print(head(transportScore))
  write.csv(transportScore, file = "output_step1/transport_score.csv", row.names = FALSE)
  message("Output successfully written to transport_score.csv")
}

#Function to identify the neighborhood which a location belongs
addNeighborhoodName <- function(df, hood_polygon) {
  #Set empty or invalid values to NA
  df$X <- as.numeric(as.character(df$X))
  df$Y <- as.numeric(as.character(df$Y))
  #Filter all data having no location
  df <- df[!is.na(df$X) & !is.na(df$Y), ]
  polygon <- df
  #Adding neighbourhood column by checking crime location falls under which neighborhood
  coordinates(polygon) <- ~ X + Y
  proj4string(polygon) <- proj4string(hood_polygon)
  df <- cbind(df, over(polygon, hood_polygon))
  df <- df[!(is.na(df$NAME) | df$NAME==""), ]
}

#Function to collect crime data and bin to neighborhood
crimeDataReshape <- function(areaDF) {
  #Read crime data from csv
  message("Loading SF crime data from csv...")
  crime_df<- read.csv("input/SFPD_Incidents_-_Current_Year__2016_.csv")
  message("Loading completed")
  crime_type <- read.csv("input/crimeTypes.csv")
  #Remove unwanted columns
  crime_df<- dplyr::select(crime_df, Category, Date, X, Y)

  #Add Neighborhood column based on location of crime
  crime_df <- addNeighborhoodName(crime_df, areaDF)

  #Filter unwanted columns
  crime_df <- dplyr::select(crime_df, Category, Date, NAME)

  #Reduce category types to 5 standard crime categories
  crime_df <- merge(crime_df,crime_type,by="Category")
  crime_df <- crime_df[!(is.na(crime_df$Type) | crime_df$Type==""), ]

  #Get count of each crime type for every neighborhood
  crime_dfnew <- spread(count(crime_df, NAME, Type), Type, n, fill = 0)
  message("Printing head of crime hood data")
  print(head(crime_dfnew))
  write.csv(crime_dfnew, file = "output_step1/crime_total.csv", row.names = FALSE)
  message("Output successfully written to crime_total.csv")
}

#Function to collect 311 Quality if Life data and bin to neighborhood
quality311DataReshape <- function(areaDF) {
  #Read 311 data from csv
  message("Loading SF 311 data  from csv...")
  report <- read.csv("input/Case_Data_from_San_Francisco_311__SF311_.csv")
  message("Loading completed")
  report <- dplyr::select(report, Opened, Category, Point)

  #Convert Point to latitude/longitude columns
  report <- report[!(is.na(report$Point) | report$Point==""), ]
  report <- report %>% tidyr::extract(Point, c("Y", "X"), "\\(([^,]+), ([^)]+)\\)")

  report <- addNeighborhoodName(report, areaDF)
  report_total <- spread(count(report, NAME, Category), Category, n, fill = 0)
  message("Printing head of 311 hood data")
  print(head(report_total))
  write.csv(report_total, file = "output_step1/report_total.csv", row.names = FALSE)
  message("Output successfully written to report_total.csv")
}

#Function to collect active registered businesses in each neighborhood and group them by type
registeredBizDataReshape <- function(areaDF) {
  #Read Business location data
  message("Loading SF registered business locations data...")
  biz <- read.csv("input/Map_of_Registered_Business_Locations.csv")
  message("Loading completed")
  #Convert Business.Location to latitude/longitude columns
  biz <- biz %>% tidyr::extract(Business.Location, c("Y", "X"), "\\(([^,]+), ([^)]+)\\)")

  biz <- dplyr::select(biz, Ownership.Name, Location.Start.Date, Location.End.Date, NAICS.Code.Description, X, Y)

  biz <- addNeighborhoodName(biz, areaDF)
  biz <- biz[!(is.na(biz$NAICS.Code.Description) | biz$NAICS.Code.Description=="")
              & (is.na(biz$Location.End.Date) | biz$Location.End.Date==""), ]

  biz_total <- spread(count(biz, NAME,NAICS.Code.Description), NAICS.Code.Description, n, fill = 0)
  message("Printing head of active business hood data")
  print(head(biz_total))
  write.csv(biz_total, file = "output_step1/biz_total.csv", row.names = FALSE)
  message("Output successfully written to biz_total.csv")
}

#Function to reshape housing data based on prices from Trulia
housingDataReshape <- function(hood_mapping) {
  message("Processing SF housing data...")
  prices <- read.csv("input/SFNeighborhoodStats.csv")
  message("Processing completed")
  prices <- prices[prices$CITY == "San Francisco",]
  prices <- dplyr::select(prices, NAME, TYPE, MEAN_PRICE)

  prices_avg <- aggregate(MEAN_PRICE ~ ., mean, data = prices)
  prices_spread <- spread(prices_avg, TYPE, MEAN_PRICE, fill = NA )
  prices_spread <- merge(prices_spread,hood_mapping,by="NAME")
  rownames(prices_spread) <- prices_spread$HOOD_MAP
  message("Printing head of active housing data")
  print(head(prices_spread))
  write.csv(prices_spread, file = "output_step1/prices_spread.csv")
}


#Start - Main program
message("Loading SF Neighborhood boundary data...")
area <- shapefile("input/Realtor_Neighborhoods/geo_export_9b21f642-45da-4a73-adc5-3f4759a4e6c1.shp")
message("Loading completed")
#Rename neighborhood column
area@data$NAME <- area@data$nbrhood

hood_mapping <- read.csv("input/realestate_map_hood_mapping.csv")

#Filter Parks and other neighborhoods with no residences
area <- area[area$NAME %in% hood_mapping$HOOD_MAP,]
crs(area)

generateTransportHoodData(area)

crimeDataReshape(area)

quality311DataReshape(area)

registeredBizDataReshape(area)

housingDataReshape(hood_mapping)

#End - Main program
