README

Instructions to collect source files for data analysis:

1. SFPD Crime Incidents
 a. https://data.sfgov.org/Public-Safety/SFPD-Incidents-Current-Year-2016-/9v2m-8wqu
 b. Click Export -> Download as csv
 c. Save file in DataAnalyzer/input directory with name as SFPD_Incidents_-_Current_Year__2016_.csv

2. 311 Incidents
 a. https://data.sfgov.org/City-Infrastructure/Case-Data-from-San-Francisco-311-SF311-/vw6y-z8j6
 b. Filter data to starting from 01-01-2016 to 12/31/2016
 c. Click Export -> Download as csv
 d. Save file in DataAnalyzer/input directory with name as Case_Data_from_San_Francisco_311__SF311_.csv

3. Registered Business Locations
 a. https://data.sfgov.org/Economy-and-Community/Registered-Business-Locations-San-Francisco/g8m3-pdis
 b. Click Export -> Download as csv
 c. Save file in DataAnalyzer/input directory with name as Map_of_Registered_Business_Locations.csv

4. SF Neighborhood Map - Shapefile
 a. https://data.sfgov.org/Geographic-Locations-and-Boundaries/Realtor-Neighborhoods/5gzd-g9ns
 b. Click Export -> Download as Shapefile
 c. Extract zip file in input directory.

5. Trulia Real Estate Data
 a. Replace <apikey> placeholder in TruliaDataRetriever with your own api key.
 b. Run TruliaRetriever/src/main/java/com/itu/capstone/neighborhood/matcher/TruliaDataRetriever.java program to retrieve neighborhood stats for San Francisco.
 c. Alternatively, create an executable jar of TruliaDataRetriever.java and run using the command java -jar TruliaDataRetriever.jar.
 d. Since Trulia Public API was decommissioned as of October 2016, SFNeighborhoodStats.csv is placed under DataAnalyzer/input directory.

Instructions to run Data Analyzer scripts
1. Install R/Rscript in machine.
2. Add walkscore API key in hoodDataReducer.R
3. Execute the following commands
 a. cd DataAnalyzer
 b. Rscript hoodDataReducer.R (Output files will be written to output_step1 folder)
 c. Rscript mergeAnalyze.R (Output files will be written to output_step2 folder

Instructions to run Shiny App
1. Execute the following commands
 a. cd DataAnalyzer
 b. Rscript shinyapp-start.R
 c. Shiny App is also hosted on shinyapps.io cloud: https://hoodmatcher.shinyapps.io/shiny/

Note: If any of the R library packages are not installed, uncomment the install.packages() lines and execute the R scripts to install them.
