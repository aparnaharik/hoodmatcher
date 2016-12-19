#install.packages('ape')

library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)

# load package ape; remember to install it: install.packages('ape')
library(ape)
library("ggplot2")
suppressPackageStartupMessages(library(dendextend))

#Load input data
hood_density <- read.csv("output_step2/hood_density.csv", row.names = 1)
PC <- read.csv("output_step2/hood_pca.csv", row.names = 1)
sim_hood <- readRDS("output_step2/sim_hood.rds")
prices_spread <- read.csv("output_step1/prices_spread.csv", row.names = 1)
area <- readRDS("output_step1/hood_area.rds")

#Dendrogram Rendering logic
dend <- PC %>% dist %>% 
  hclust %>% as.dendrogram %>%
  set("branches_k_color", k=3)


# plot the Base Mapin usual "base" plotting engine:
basemap <- leaflet()  %>%
  addPolygons(
    data = area, 
    stroke = TRUE, weight = 1, fillOpacity = 0.5, smoothFactor = 1,
    popup = paste("<b>",area$NAME,"</b>"),
    color = "white"
  ) %>%
  addProviderTiles("CartoDB.Positron", options = providerTileOptions(opacity = 1))


function(input, output, session) {
  #Render Neighborhood dropdown
  output$hoods <- renderUI({
    selectInput("hood", 
                "Select a neighborhood", 
                as.list(rownames(sim_hood)))
  })
  
  output$map <- renderLeaflet({basemap})
  ## Interactive Map ###########################################
  
  observe({
    hood <- input$hood
    tab <- input$nav
    #Check if hood is selected and active tab is Interactive Map
    if(!is.null(hood) && !is.null(tab) && tab == "Interactive Map") {
      
      sim_area <- area[area$NAME %in% sim_hood[hood,],]
      factpal <- colorFactor(brewer.pal(n = 6, name ="Spectral") , sim_area$NAME) 
      
      # Create the map
      leafletProxy("map", data = sim_area) %>% 
        #Clear previous shapes
        clearShapes() %>%
        #Render similar neghborhood polygons
        addPolygons(
          data = sim_area, 
          stroke = TRUE, weight = 1, fillOpacity = .8, smoothFactor = 0.5,
          popup = paste("<b>",sim_area$NAME,"</b>"),
          color = "black",
          fillColor = factpal(sim_area$NAME))
      
      #Render WalkScore plot based on selected hood
      output$walkScore <- renderPlot({
        ## widen right margin
        par(mar=par('mar')+c(0,10,0,0));
        
        barplot(hood_density[sim_area$NAME,"walkScore"] ,
                names.arg = sim_area$NAME,
                horiz = TRUE,
                las = 2,
                main = "Walk Score Comparison",
                xlim=c(0,100),
                #xlab = "Similar Neighborhoods",
                col = factpal(sim_area$NAME),
                border = 'white')
        
      })
      
      #Render CrimeData plot based on selected hood
      output$crime <- renderPlot({
        plot(c(1:6), seq(0,100,length.out = 6), 
             main = "Crime Rate Comparison",
             xaxt ="n",  type="n", xlab="Neighborhoods",
             ylab="Crime Rate" )
        x <- as.character(sim_hood[hood,])
        axis(1, at=1:6, labels=x)
        colors <- colorFactor(brewer.pal(n = 5, name ="Spectral") , colnames(hood_density[,c(49:53)])) 
        crimeTypes <- colnames(hood_density[,c(49:53)])
        legend("topright", legend = crimeTypes, lwd=c(2.5,2.5), lty = 3, col = colors(crimeTypes))
        # add lines 
        for (crimeType in crimeTypes) { 
          max_x <- max(hood_density[,crimeType])
          y <- hood_density[x,crimeType]*100/max_x
          lines(1:6, y, type="b", lwd=3,
                lty=3,
                col=colors(crimeType), pch=2) 
        } 
      })
      
      #Render HousingData plot based on selected hood
      output$housingprices <- renderPlot({
        x <- as.character(sim_hood[hood,])
        plot(c(1:6), 
             seq(min(prices_spread[x,11]/1000000, na.rm = TRUE), 
                      max(prices_spread[x,11]/1000000, na.rm = TRUE), 
                      length.out = 6), 
             main = "Mean Housing Price Comparison",
             xaxt ="n",  type="n", xlab="Neighborhoods",
             ylab="Housing Prices")
        axis(1, at=1:6, labels=x)
        
        y <- prices_spread[x,11]/1000000
        lines(1:6, y, type="b", lwd=3,
              lty=3,
              col="blue", pch=2) 

      }) 
    }
   
  })
  
  #Observe block to render dendrogram
  observe({
    tab <- input$nav
    if(tab == "Dendrogram") {
      output$dendrogram <- renderPlot({
        ggplot(as.ggdend(dend), horiz = TRUE, theme = theme_minimal()) 
      })
    } 
    
   
  })
  
  #Render Component dropdown
  output$input_factor <- renderUI({
    selectInput("selected_factor", 
                "Select an input factor", 
                as.list(colnames(hood_density)))
  })
  
  
  output$input_map <- renderLeaflet({basemap})
  observe({
    tab <- input$nav
    factor <- input$selected_factor
    if(tab == "Input Explorer" && !is.null(factor)) {
      
      numericpal <- colorNumeric(
                                palette = "Blues",
                                domain = hood_density[,factor]
                              ) 
      
      # Create the map
      leafletProxy("input_map", data = area) %>% clearShapes() %>%
        addPolygons(
          data = area, 
          stroke = TRUE, weight = 1, fillOpacity = 0.5, smoothFactor = 0.5,
          popup = paste("<b>",area$NAME,"</b></br>",factor,": ", as.integer(hood_density[area$NAME,factor])),
          color = "black",
          fillColor = numericpal(hood_density[area$NAME,factor])
          )
      
      
      }  
    })
    
}
