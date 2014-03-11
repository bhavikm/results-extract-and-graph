#just need to set these two variables
dataset <- "localization"
learner <- "A3DE"

results_dir <- "results/"

results_type <- paste(dataset,learner,sep="_")
results_path <- paste(results_dir,results_type, sep="")
results_path <- paste(results_path,"/extracted_data/extracted_results_", sep="")
results_path <- paste(results_path,results_type, sep="")
results_path <- paste(results_path,".txt", sep="")
mydata <- read.table(results_path,sep="\t",fill=TRUE,header=TRUE)
pdf(paste(paste(results_dir,paste(learner,dataset,sep="-"),sep=""),".pdf",sep=""))
title <- paste(paste(learner,dataset,sep=" "),"Results",sep=" ")
matplot(mydata[,1]/1000, mydata[,2:5],type="b",lty=1,pch=19,main=title,xlab="Memory (MB)",ylab="RMSE",cex.axis=1.3,cex.lab=1.3)
legend('topright', names(mydata)[2:5],col=c('black','red','green','blue'),lty=1,pch=19,bty='n', cex=1.5)
dev.off()