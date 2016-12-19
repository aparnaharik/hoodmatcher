message("Loading csv data in progress")
transportScore <- read.csv("output_step1/transport_score.csv")
biz_total <- read.csv("output_step1/biz_total.csv")
crime_dfnew <- read.csv("output_step1/crime_total.csv")
report_total <- read.csv("output_step1/report_total.csv")
message("Loading csv data complete")

#Merge all data to single file
hood_merge <- merge(transportScore,biz_total,by="NAME")
hood_merge <- merge(hood_merge,report_total,by="NAME")
hood_merge <- merge(hood_merge,crime_dfnew,by="NAME")
hood_merge$area_sqkm <- as.numeric(as.character(hood_merge$area_sqkm))
print(head(hood_merge))
message("Merging csv data complete")

#Calculate density for all data except walk/transit score
hood_density <- hood_merge[,-c(1,2,3,4)] / hood_merge$area_sqkm
hood_density <- cbind(hood_merge[,c(3,4)],hood_density)
rownames(hood_density) <- hood_merge$NAME
write.csv(hood_density, file = "output_step2/hood_density.csv")
print(head(hood_density))
message("Converted data to density format")

message("Running PCA on dataset")
#Run PCA to filter out redundant components
require(caret)
trans = preProcess(hood_density, 
                   method=c("BoxCox", "center", 
                            "scale", "pca"),
                   thresh = 0.99)
PC = predict(trans, hood_density)
write.csv(PC, file = "output_step2/hood_pca.csv")
cat("PCA Reduced components from ", ncol(hood_density), " to ", ncol(PC))

#Create similarity matrix
#install.packages("proxy")
library("proxy")
sim_matrix <- simil(PC, method = "correlation")
sim_matrix <- proxy::as.matrix(sim_matrix, diag = 1)
message("Created similarity matrix")

#Plot multi dimensional scaling
mds <- cmdscale(dist(hood_density))
plot(mds, type = "n")
text(mds[, 1], mds[, 2], row.names(hood_density), cex = 0.7, col = "blue")

#Create data frame with top 5 similar neighborhoods
sim_hood <- data.frame(matrix(data = NA, nrow = nrow(sim_matrix), ncol = 6), row.names = rownames(sim_matrix))
for (i in 1:nrow(sim_matrix) ) {
  sim_hood[i,] <- head(names(sim_matrix[i,order(sim_matrix[i,], decreasing = TRUE)]),n=6)
}
message("Identified top 5 similar neighborhoods")
print(head(sim_hood[,-c(1)]))
saveRDS(sim_hood, "output_step2/sim_hood.rds")


