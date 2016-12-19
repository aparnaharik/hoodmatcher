library(leaflet)



navbarPage("SF Neighborhood Matcher", id="nav",
       
           tabPanel("Interactive Map", id = "sim_map",
                    div(class="outer",
                        
                        tags$head(
                          # Include our custom CSS
                          includeCSS("styles.css")
                        ),
                        
                        leafletOutput("map", width="100%", height="100%"),
                        
                        # Shiny versions prior to 0.11 should use class="modal" instead.
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                      width = "40%", height = "auto",
                                      
                                      h2("Neighborhood Explorer"),
                                      
                                      uiOutput("hoods"),
                                      
                                      plotOutput("walkScore", height = 250),
                                      plotOutput("housingprices", height = 250),
                                      plotOutput("crime", height = 250)
                        )
                    )
           ),
           tabPanel("Input Explorer", id = "input_explorer",
                    div(class="outer",
                        
                        tags$head(
                          # Include our custom CSS
                          includeCSS("styles.css")
                        ),
                        
                        leafletOutput("input_map", width="100%", height="100%"),
                        
                        # Shiny versions prior to 0.11 should use class="modal" instead.
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                      width = "25%", height = "auto",
                                      
                                      h2("Input Explorer"),
                                      
                                      uiOutput("input_factor")
                        )
                    )
           ),

           tabPanel("Dendrogram", id = "dendrogram",
                    
                    plotOutput("dendrogram", height = 2000)
           )
 
)