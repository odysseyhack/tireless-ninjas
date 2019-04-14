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
  Tcumulative=0
  Ncumulative=0
  for (row in c(1:nrow(data))){
    
    if (data$net[row] < 0){
      Tcumulative=Tcumulative+(data$net[row]*0.25/1e3)
      Ncumulative=Ncumulative+(data$Backdelivery[row]-runif(1,30,55))*0.25/1e3
      data$Tcumulative[row]=Tcumulative
      data$Ncumulative[row]=Ncumulative
    }else{
      data$Tcumulative[row]=Tcumulative
      data$Ncumulative[row]=Ncumulative
      if (data$Backdelivery [row]<0){
      data$Ncumulative[row]=Ncumulative+(data$Backdelivery[row]-runif(1,30,55))*0.25/1e3  
      }
      
    }

    # if (abs(data$cumulative[row]) > 10){
    #   data$TGO[row]="Y"
    # } else {
    #   data$TGO[row]="N"
    # }
    data$TGO[row]="No"
    data$NTGO[row]="No"
  }
  
  data=select(data,c("Datum","Tcumulative","Ncumulative","TGO","NTGO"))
  
  min_Tcumulative=min(data$Tcumulative)
  aantal_certificate=round(-1*(min_Tcumulative/10))
  for (h in c(1:aantal_certificate)){
    data1=data  
    data1$Tcumulative=(data1$Tcumulative+h*10)
    data1=subset(data1,data1$Tcumulative<0)
    target=max(data1$Tcumulative)-h*10
    index=which(data$Tcumulative==target)[1]
    data$TGO[index]="Yes"
  }
  
  min_Ncumulative=min(data$Ncumulative)
  aantal_certificate=round(-1*(min_Ncumulative/10))
  for (h in c(1:aantal_certificate)){
    data1=data  
    data1$Ncumulative=(data1$Ncumulative+h*10)
    data1=subset(data1,data1$Ncumulative<0)
    target=max(data1$Ncumulative)-h*10
    index=which(data$Ncumulative==target)[1]
    data$NTGO[index]="Yes"
  }
  
  
 #cleaning and saving the csv file
 select=seq(1,35040,192*2)
 data2=data[select,1]
 data3=subset(data, data$TGO=="Yes" | data$NTGO=="Yes" | data$Datum %in% data2)

 write.csv2(data3,file=paste0("C:/Users/604297/Desktop/certifified.homes/", list[i]), row.names = F)

}

##

###making profiles
nedu=read.csv(file="./data/modeldata/ls/neduprofiel2018.csv",header=TRUE,sep=",",dec=",", stringsAsFactors = F)

norm=1500*as.integer(nedu$E1A)[1:192]
base_consmption=min(norm)
pv=-4*profielPV[1:192]
consumption=data$net[1:192]-pv

par(mfrow=c(2,2))

plot(data$net[1:192],type = "l")
plot(pv,type = "l")
