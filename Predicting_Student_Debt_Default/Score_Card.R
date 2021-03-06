# Create pipeline to select 45 predictor variables. 

library(ggplot2)
library(dplyr)
library(tidyr)

sc1415.all <- scorecard1415 %>% select(OPEID6,INSTNM,STABBR,NUMBRANCH,CONTROL,PREDDEG,
                                       REGION,LOCALE,LATITUDE,LONGITUDE,CCBASIC,
                                       CCUGPROF,CCSIZSET,RELAFFIL,ADM_RATE_ALL,DISTANCEONLY,UGDS,
                                       CURROPER,NPT4_PUB,NPT4_PRIV,NUM4_PUB,NUM4_PRIV,TUITFTE,INEXPFTE,
                                       AVGFACSAL,PFTFAC,PCTPELL,C150_4,RET_FT4,PCTFLOAN,UG25ABV,
                                       CDR2,CDR3,PAR_ED_PCT_1STGEN,DEP_INC_AVG,IND_INC_AVG,
                                       DEBT_MDN,GRAD_DEBT_MDN,WDRAW_DEBT_MDN,FAMINC,MD_FAMINC,POVERTY_RATE,
                                       MN_EARN_WNE_P10,MD_EARN_WNE_P10,CDR3_DENOM)

# Filtering NA values in debt default column. 

sc1415.CDR3 <- sc1415.all %>% filter(!is.na(CDR3))

# Filtering by degree type. 
sc1415 <- sc1415.CDR3 %>% filter(PREDDEG!=4)

# Check column names. 

names(sc1415)[colSums(is.na(sc1415))>0]

# Selecting columns with less than 10% NA values. 

naProportion <- apply(sc1415,2,function(x){sum(is.na(x))/nrow(sc1415)})
naProportion <- naProportion[naProportion<.1]

# Checking variable type for default column(s). 

!is.numeric(sc1415$CDR3)
!is.numeric(sc1415$CDR3_DENOM)

# Selecting columns by name
selectedCols <- names(naProportion)

# Creating new dfs with selected columns
sc1415 <- sc1415[,selectedCols]

sc1415.net <- sc1415[complete.cases(sc1415),]  

# Review new column names
names(sc1415.net)[colSums(is.na(sc1415.net))>0]

names(sc1415.net)

# Summarize new dfs with default rate variable. 
summary(sc1415.all$CDR3)
summary(sc1415$CDR3)
summary(sc1415.net$CDR3)

# Creating categorical variables.
# Create institution type variable. 

control_list <- c(1:3)
control_descs <- c("Public",
                   "Private nonprofit",
                   "Private for-profit")
sc1415.net <- sc1415.net %>% mutate(CONTROL = factor(CONTROL,levels=control_list, labels=control_desc))

# Create degree type variable. 

preddeg_list <- c(1:3)
preddeg_descs <- c(
  "Certificate",
  "Associate's",
  "Bachelor's"
)
sc1415.net <- sc1415.net %>% mutate(PREDDEG = factor(PREDDEG,levels=preddeg_list,
                                                    labels=preddeg_descs))
# Create binary online/not online variable. 

distanceonly_list = c(0:1)
distanceonly_descs = c("Not Online-Ed Only",
                       "Online-Ed Only")
sc1415.net <- sc1415.net %>% mutate(DISTANCEONLY = factor(DISTANCEONLY,levels=distanceonly_list,
                                                          labels=distanceonly_descs))

# Create region/location variables. 

region_list <- c(1:9)
region_descs <- c(
  "New England",
  "Mid East",
  "Great Lakes",
  "Plains",
  "Southeast",
  "Southwest",
  "Rocky Mtn",
  "Far West",
  "Outlying Areas")
sc1415.net <- sc1415.net %>% mutate(REGION = factor(REGION,levels=region_list,
                                                    labels=region_descs))

# Review institution type variable. 

table(sc1415.net$CONTROL)

# Group by institution type. 

sc1415.net %>% group_by(CONTROL) %>% summarize(n(),mean(CDR3),median(CDR3),sd(CDR3))

# Review new tibble df. 
table(sc1415.net$PREDDEG)

# Group by degree type. 
sc1415.net %>% group_by(PREDDEG) %>% summarize(n(),mean(CDR3),median(CDR3),sd(CDR3))

# Visualization for default  rates. 

ggplot(sc1415.net,aes(x=CDR3*100)) + 
  geom_histogram(binwidth=3,alpha=.5, fill='orange', color='black') + ggtitle('Distribution of Historic Default Rate') + labs(x = 'Default Rate (Percent)', y = 'Count', caption='Courtesy of U.S. Department of Education') + theme(plot.title=element_text(face='bold', hjust=0.5))

# Visualization for default rates by degree level. 

ggplot(sc1415.net,aes(x=CDR3*100, fill=PREDDEG)) + 
  geom_histogram(binwidth=3, col='black') +
  facet_grid(PREDDEG~.) +
  ggtitle('Default Rate by Degree Level') +
  labs(x = 'Default Rate (Percent)', y = 'Count', fill='Degree Type', subtitle='2014-2015 data', caption='Courtesy of U.S. Department of Education') +
  theme(plot.title = element_text(hjust=0.5, face='bold')) +
  theme(plot.subtitle= element_text(hjust=0.5))

# Visualization for household income of financially independent students. 

ggplot(sc1415.net,aes(x=IND_INC_AVG,y=CDR3*100)) +
  geom_point(pch=21, size=2, col='black', fill='blue') +
  geom_smooth(method="lm", col="black") +
  labs(title='Average Household Income of Financially Independent Students', subtitle='2014-2015 data', caption='Courtesy of U.S. Department of Education', x = 'Household Income ($)', y = 'Default Rate (%)') +
  theme(plot.title=element_text(hjust=0.5, face='bold')) + 
  theme(plot.subtitle=element_text(hjust=0.5))

# Visualization for median loan amount vs. default rate. 

ggplot(sc1415.net,aes(x=DEBT_MDN,y=CDR3*100)) +
  geom_point(pch=21, size=2, col='black', fill='orange') +
  geom_smooth(method="lm", col="black") +
  labs(title='Median Loan Amount vs. Default Rate', subtitle='2014-2015 data', caption='Courtesy of U.S. Department of Education', x='Median Debt', y = 'Default Rate') +
  theme(plot.title=element_text(hjust=0.5, face='bold')) +
  theme(plot.subtitle=element_text(hjust=0.5))

# Visualization for first generation students vs. default rate (by school type)

ggplot(sc1415.net,aes(y=CDR3*100,x=PAR_ED_PCT_1STGEN*100, col=CONTROL)) +
  geom_point(pch=21, size=2) +
  facet_grid(CONTROL~.) +
  geom_smooth(col="black", method="lm") +
  labs(title='First Generation Students vs. Default Rate', subtitle='Percentage by School Type (2014-2015)', caption='Courtesy of U.S. Department of Education', x='First Generation Student(%)', y = 'Default Rate(%)', col='Institution Type') +
  theme(plot.title=element_text(hjust=0.5, face='bold')) +
  theme(plot.subtitle=element_text(hjust=0.5))

# Visualization for pell grants vs. default rate (by type of degree awarded)

ggplot(sc1415.net,aes(y=CDR3*100,x=PAR_ED_PCT_1STGEN*100, col=PREDDEG)) +
  geom_point(pch=21, size=2) +
  facet_grid(PREDDEG~.) +
  geom_smooth(col="black", method="lm") + 
  labs(title='Pell Grants Awarded vs. Default Rate', subtitle='Based on Awarded Degree', caption='Courtesy of U.S. Department of Education', x = 'Students Receiving Pell(%)', y = 'Default Rate(%)', col='Degree Type') + 
  theme(plot.title=element_text(hjust=0.5, face='bold')) +
  theme(plot.subtitle = element_text(hjust=0.5))

# Import linear model generation library. 

library(caret)

# Creating dummy variables.

dummies <- dummyVars("~ CONTROL + PREDDEG + REGION", data=sc1415.net,fullRank=TRUE)
dummies <- data.frame(predict(dummies,newdata=sc1415.net))
sc1415.final <- as.data.frame(cbind(sc1415.net,dummies))

# Eliminating unused variables. 

sc1415.final$OPEID6 <-  NULL
sc1415.final$STABBR <-  NULL
sc1415.final$INSTNM <-  NULL

sc1415.final$CONTROL <- NULL
sc1415.final$REGION  <- NULL
sc1415.final$PREDDEG <- NULL
sc1415.final$DISTANCEONLY <- NULL

# Saving dfs to CSV files.

write.csv(sc1415.net,"sc1415net.csv")
write.csv(sc1415.final,"sc1415final.csv")

# MODEL 1: Linear Regression 

# Import caTools library. 

library(caTools)

# Create train/test split and set random seed. 

set.seed(100)
split_vec <- sample.split(sc1415.final$CDR3,SplitRatio=.75)
Train <- sc1415.final[split_vec,]
Test <- sc1415.final[!(split_vec),]

set.seed(100)
k = 10
train.control <- trainControl(method = "cv", number = k)

nvmaxCV <- train(CDR3 ~., data = Train,
                 method = "leapBackward", 
                 tuneGrid = data.frame(nvmax = 1:(ncol(Train)-1)),
                 trControl = train.control
)
nvmaxCV$results

names(coef(nvmaxCV$finalModel,19))

# Create linear model. 

lm1 <- lm(CDR3 ~ UGDS+INEXPFTE+PCTPELL+PAR_ED_PCT_1STGEN+
            DEP_INC_AVG+IND_INC_AVG+
            DEBT_MDN+GRAD_DEBT_MDN+WDRAW_DEBT_MDN+
            CONTROL.Private.nonprofit+CONTROL.Private.for.profit+
            PREDDEG.Associate.s+PREDDEG.Bachelor.s+
            REGION.Mid.East+REGION.Plains+REGION.Southeast+REGION.Southwest+REGION.Rocky.Mtn+REGION.Outlying.Areas,
          
          data=Train)

# Summarize linear model. 

summary(lm1)

# Visualization of linear regression model. 
ggplot(data=Train,aes(x=as.numeric(row.names(Train)),y=lm1$residuals)) + geom_point(pch=21, size=2, color='black', fill='purple') +
  geom_smooth(method="lm") +
  labs(title='Linear Regression Model Results', subtitle='Root Mean Square Error (RMSE)', caption='Courtesy of U.S. Department of Education', x = 'Training Set Row Index', y = 'Residual') +
  theme(plot.title=element_text(hjust=0.5, face='bold')) +
  theme(plot.subtitle=element_text(hjust=0.5))

lm1.pred <- predict(lm1, newdata=Test)
residualTest <- (lm1.pred - Test$CDR3)
# RMSE
sqrt(sum(residualTest^2)/nrow(Test))

# MODEL 2: Classification and Regression Tree (CART)

# Import libraries for creating decision tree. 

library(rpart)
library(rpart.plot)

# Creating tree.

defaultsTree = rpart(CDR3 ~ .,
                     data=Train)
prp(defaultsTree)

predictCART = predict(defaultsTree,newdata=Test)    

residualTestCART <- (predictCART- Test$CDR3)
sqrt(sum(residualTestCART^2)/nrow(Test))
