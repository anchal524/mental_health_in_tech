rm(list=ls()) 

##Reading the data
name <-file.choose() 
mentalData <- read.csv(name,na.string="?")
View(mentalData)
summary(mentalDataWithoutNA)

##Loading the libraries
library(kknn)
library ("dplyr")

mentalDataWithoutNA <- na.omit(mentalData)

##Removing the irrelevant columns of dataset
remove_list <- c('Timestamp', 'state','comments','work_interfere')                
new_df <- mentalDataWithoutNA[, !names(mentalDataWithoutNA) %in% remove_list]
mentalDataWithoutNA = new_df


## Cleaning the data


#age
boxplot(mentalData$Age,main = 'Box plot of Age',
        col= rgb(0, 0.8, 1, alpha = 0.5)) ##shows outliers
quantile(mentalDataWithoutNA$Age, probs = c(.25, .5, .75))
firstPecentile<-quantile(mentalDataWithoutNA$Age, probs = c(.25))
thirdPercentile <-quantile(mentalDataWithoutNA$Age, probs = c(.75))
iqr<-thirdPercentile - firstPecentile
iqr<-iqr*1.5
for(i in seq(from=1, to=nrow(mentalDataWithoutNA), by=1))
{
  if(mentalDataWithoutNA$Age[i]<firstPecentile- iqr|mentalDataWithoutNA$Age[i]>thirdPercentile+ iqr){
    mentalDataWithoutNA$Age[i] <- NA; #marking the outliers as NA
  } 
}
is.na(mentalDataWithoutNA$Age)
mentalDataWithoutNA <- na.omit(mentalDataWithoutNA)
boxplot(mentalDataWithoutNA$Age,main = 'Box plot of Age',col= rgb(0, 0.8, 1, alpha = 0.5)) #after data cleaning


#gender
F_list = c('F', 'female', 'Woman', 'woman', 'Female', 'Femake',
           'femail', 'f', 'cis-female/femme', 'Cis Female')

M_list = c('M', 'm', 'male', 'Mail', 'maile', 'Mal', 'male',
           'Guy (-ish) ^_^', 'cis male', 'Cis Man', 'Cis Male',
           'Male ', 'Male (CIS)', 'male leaning androgynous',
           'Male-ish', 'Malr', 'Man', 'msle', '','Male')

getGender <- function(types){
  new_char_list = c(1, length(types))
  for (i in 1:length(types)) {
    type = types[i]
    new_char = 'unknown'   
    
    if(type %in% F_list){
      new_char = 'Female'
    }
    else if(type %in% M_list){
      new_char = 'Male'
    }
    
    else{
      new_char = 'unknown'
    }
    new_char_list[i] = new_char 
  }
  return(new_char_list) 
}

mentalDataWithoutNA = mentalDataWithoutNA %>% mutate(Gender = getGender(mentalDataWithoutNA$Gender))



#self-employed
for(i in seq(from=1, to=nrow(mentalDataWithoutNA), by=1))
{
  if(mentalDataWithoutNA$self_employed[i]=="NA"){
    mentalDataWithoutNA$self_employed[i] <- NA;
  } 
}

mentalDataWithoutNA<-na.omit(mentalDataWithoutNA)


##factoring the data
data2 <- mentalDataWithoutNA
data2$Age <- as.factor(data2$Age)      
data2$Gender <- as.factor(data2$Gender)      
data2$Country <- as.factor(data2$Country)      
data2$self_employed <- as.factor(data2$self_employed)      
data2$family_history <- as.factor(data2$family_history)      
data2$treatment <- as.factor(data2$treatment)      
data2$no_employees <- as.factor(data2$no_employees)      
data2$remote_work <- as.factor(data2$remote_work)      
data2$tech_company <- as.factor(data2$tech_company)      
data2$benefits <- as.factor(data2$benefits)      
data2$care_options <- as.factor(data2$care_options)      
data2$wellness_program <- as.factor(data2$wellness_program)      
data2$seek_help <- as.factor(data2$seek_help)      
data2$anonymity <- as.factor(data2$anonymity)      
data2$leave <- as.factor(data2$leave)      
data2$mental_health_consequence <- as.factor(data2$mental_health_consequence)      
data2$phys_health_consequence <- as.factor(data2$phys_health_consequence)      
data2$coworkers <- as.factor(data2$coworkers)      
data2$supervisor <- as.factor(data2$supervisor)      
data2$mental_health_interview <- as.factor(data2$mental_health_interview)      
data2$phys_health_interview <- as.factor(data2$phys_health_interview)      
data2$mental_vs_physical <- as.factor(data2$mental_vs_physical)      
data2$obs_consequence <- as.factor(data2$obs_consequence)      
mentalDataWithoutNA <-data2
summary(mentalDataWithoutNA)

mental_health_matrix <- data.matrix(mentalDataWithoutNA)
heatmap(mental_health_matrix)

##creating test and training data
index <- sort(sample(1:nrow(mentalDataWithoutNA),0.7*nrow(mentalDataWithoutNA)))
training <-mentalDataWithoutNA[index,]
test<-mentalDataWithoutNA[-index,]

##predicting data
predict_k5 <- kknn(formula=treatment~., training, test, k=5,kernel ="triangular")
fit_k5 <- fitted(predict_k5) #predictions

#creating confusion matrix
tab_5 <-table(Actual=test$treatment,Treatment=fit_k5) #tabulate predictions
tab_5

##finding accuracy and error rate
accuracy <- function(x){sum(diag(x)/(sum(rowSums(x)))) * 100}
accurate_5 <-accuracy(tab_5) #gets accuracy
accurate_5
error_rate_5 <- 1 - as.double(accurate_5/100) #error rate for k=5
error_rate_5
