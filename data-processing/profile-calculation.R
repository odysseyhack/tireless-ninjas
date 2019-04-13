library(dplyr)

list=list.files(path="C:/Users/604297/Desktop/Energy-20190412T093936Z-001/Energy")

###TGO

for (i in c(1:100)){
  data=read.csv(paste0("C:/Users/604297/Desktop/Energy-20190412T093936Z-001/Energy/", list[i]))
  data=select(data,c("utc_timestamp","year","B_consumption","D_consumption"))
  data$B_consumption=data$B_consumption*-1
  data=subset(data, data$year==2017)
  data$net=data$B_consumption+data$D_consumption
  colnames(data)[1]="Datum"
  colnames(data)[3]="Backdelivery"
  colnames(data)[4]="Delivery"
  cumulative=0
  for (row in c(1:nrow(data))){
    
    if (data$net[row] < 0){
      cumulative=cumulative+(data$net[row]*0.25/1e3)
      data$cumulative[row]=cumulative
    }else{
      data$cumulative[row]=cumulative
    }

    # if (abs(data$cumulative[row]) > 10){
    #   data$TGO[row]="Y"
    # } else {
    #   data$TGO[row]="N"
    # }
    
    data$TGO[row]="No"
  }
  data=select(data,c("Datum","cumulative","TGO"))
  min_cumulative=min(data$cumulative)
  aantal_certificate=round(-1*(min_cumulative/10))
  for (h in c(1:aantal_certificate)){
    data1=data  
    data1$cumulative=(data1$cumulative+h*10)
    data1=subset(data1,data1$cumulative<0)
    target=max(data1$cumulative)-h*10
    index=which(data$cumulative==target)[1]
    data$TGO[index]="Yes"
  }
  
 write.csv2(data,file=paste0("C:/Users/604297/Desktop/certifified.homes/", list[i]), row.names = F)

}

###making profiles
nedu=read.csv(file="./data/modeldata/ls/neduprofiel2018.csv",header=TRUE,sep=",",dec=",", stringsAsFactors = F)

norm=1500*as.integer(nedu$E1A)[1:192]
pv=-4*profielPV[1:192]
consumption=data$net[1:192]-pv

par(mfrow=c(2,2))

plot(data$net[1:192],type = "l")
plot(pv,type = "l")
