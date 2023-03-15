##########################################################
# Housing Price Prediction Model
# Dataset ames -> modeldata 
# Reference for Dataset https://modeldata.tidymodels.org/reference/ames.html
##########################################################

##https://modeldata.tidymodels.org/reference/ames.html


if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if(!require(caret)) install.packages("caret", repos = "http://cran.us.r-project.org")
if(!require(lubridate)) install.packages("lubridate", repos = "http://cran.us.r-project.org")
if(!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")
if(!require(here)) install.packages("here", repos = "http://cran.us.r-project.org")
if(!require(rstudioapi)) install.packages("rstudioapi", repos = "http://cran.us.r-project.org")
if(!require(broom)) install.packages("broom", repos = "http://cran.us.r-project.org")
if(!require(modeldata)) install.packages("modeldata", repos = "http://cran.us.r-project.org")
if(!require(ggplot2)) install.packages("ggplot2", repos = "http://cran.us.r-project.org")
if(!require(moments)) install.packages("moments", repos = "http://cran.us.r-project.org")
if(!require(corrr)) install.packages("corrr", repos = "http://cran.us.r-project.org")
#if(!require(tidymodels)) install.packages("tidymodels", repos = "http://cran.us.r-project.org")
#if(!require(lares)) install.packages("lares", repos = "http://cran.us.r-project.org")
if(!require(GGally)) install.packages("GGally", repos = "http://cran.us.r-project.org")


library(tidyverse)
library(caret)
library(lubridate)
library(dplyr)
library(here)
library(rstudioapi)
library(broom)
library(modeldata)
library(ggplot2)
library(moments)
library(GGally)
library(corrr)


# Load ames Dataset
data(ames)

# Exploratory Data Analysis

knitr::kable(dim(ames),caption = "Ames Housing Dataset dimension")

#knitr::kable(colnames(ames),caption = "Ames Housing Dataset Columns")

knitr::kable(str(ames),caption = "Ames Housing Dataset")

#knitr::kable(summary(ames),caption = "Ames Housing Dataset")

# Sale Price Characteristics 
############### Data Exploration and Visualization

# To make graphs more readable disabling scientific notation
options(scipen = 100)

knitr::kable(dim(ames),caption = "Ames Housing Dataset dimension")

#knitr::kable(colnames(ames),caption = "Ames Housing Dataset Columns")

knitr::kable(str(ames),caption = "Ames Housing Dataset")

# Sale Price Characteristics 

ames %>% 
  ggplot(aes(Sale_Price)) + 
    geom_histogram(aes(y = ..density..), bins = 30,
                   colour = 1, fill = "black") +
  labs(title = "Distribution of house prices", x = "Price($)", y = "Frequency") +
  geom_density() +
  theme_minimal()

# The distribution of SalePrice is right-skewed. Let's check its Skewness and Kurtosis statistics.
cat("\nSale Price skewness :", skewness(ames$Sale_Price))
cat("\nSale Price kurtosis :", kurtosis(ames$Sale_Price))


## Building Age

ames %>%
  ggplot(aes(Year_Built)) +
  geom_bar(color = "black") +
#  scale_x_continuous() +
 # scale_x_discrete(breaks = 10)  +
  labs(title = "Year Built", x = "Year Built", y = "No of Houses") 

# Overall COndition

ames %>%
  ggplot(aes(Overall_Cond)) +
  geom_bar(color = "black") +
  #  scale_x_continuous() +
  labs(title = "Overall Condition of the houses", x = "Overall Cond.", y = "No of Houses")




# Let's see median prices per neighborhood


ames %>% ggplot(aes(x = Neighborhood, y = Sale_Price)) +
  geom_boxplot() +
  ylab("Sale Price") +
  xlab("Neighbothood") +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1))


## House Price varies with the neighborhood with few outliers by neighborhood. 
#Also, the median house price by neighborhood is roughly between 200,000 and 400,000. 
#It seems Neighborhood would have some impact on housing price.
  
# Correlation between Sale Price and other variables 
  

  
  ames_num <- ames %>% select_if(~is.numeric(.x)) 
  
  
  ames_num %>% ggcorr() +
              ggplot2::labs(title = "Correlation between Numeric Variables")
  
  # Correlation of Sales Price with other numeric variables
  
  var_cors <- sapply(ames_num, function(var){
    var_cor <- cor(ames$Sale_Price,var )
    return(var_cor)
  })
  

  knitr::kable(var_cors,caption = "Ames Housing Dataset - correlated numeric variables with the Sale Price")
  
  # Correlation of Sales Price with other non-numeric variables
  
  ames_nonnum <- ames %>% select(where(~!is.numeric(.x) ))
  
  
  var_cors <- sapply(ames_nonnum, function(var){
    var_cor <- cor(ames$Sale_Price,rank(var) )
    return(var_cor)
  })
  
  knitr::kable(var_cors,caption = "Ames Housing Dataset - correlated non-numeric variables with the Sale Price")
  
  # Looking at the non-numeric variable, I identified few variables which are highly correlated - 
  # MS_Zoning, Lot_Shape, Foundation, Sale_Condition , Garage_Finish, House_Style, Heating_QC, 
  



# Getting the path of your current open file
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path ))
#print( getwd() )


options(timeout = 120)




#unique(ames$Overall_Cond)

#as.numeric(unique(ames$Overall_Cond))

  

  
#  housing <- housing %>%
#    mutate(TotalArea = as.integer(X1stFlrSF),
#           price = as.numeric(SalePrice))
  
  

  

  
#housing <- housing %>%
  #  mutate(Year.Built = as.integer(Year.Built),
  #         TotalArea = as.integer(TotalArea),
  #         SalePrice = as.numeric(SalePrice))
  


summarise(ames)

### Data Wrangling 

########################################################

# Created a variable total_area = First_Flr_SF + Second_Flr_SF + Gr_Liv_Area
# Exclude Longitude

ames <- ames %>%
  mutate(TotalArea = First_Flr_SF + Second_Flr_SF + Gr_Liv_Area)

### SalePrice_T -> Sales Price in Thousands

ames <- ames %>%
  mutate(Sale_Price_T = round(Sale_Price/1000))

ames$Sale_Price_T[is.na(ames$Sale_Price_T)] <- 0

### Overall Condition
# 5 6 7 2 8 4 9 3 1
# unique(ames$Overall_Cond)
#[1] Average       Above_Average Good          Poor          Very_Good     Below_Average Excellent     Fair         
#[9] Very_Poor    
#Levels: Very_Poor Poor Fair Below_Average Average Above_Average Good Very_Good Excellent Very_Excellent

ames <- ames %>%
  mutate(Overall_Cond_n = as.numeric(Overall_Cond)) 



      


ames <- ames %>% select (Sale_Price_T,TotalArea, Year_Built,Overall_Cond_n,Garage_Cars,Garage_Area,
                         Total_Bsmt_SF, Year_Remod_Add, Mas_Vnr_Area, MS_Zoning, Lot_Shape, Foundation, Sale_Condition , Garage_Finish, House_Style, Heating_QC  )



# Total area
ames %>% 
  ggplot(aes(TotalArea)) + 
  geom_histogram(bins = 25, color = "black") + 
  #scale_x_log10() + 
  scale_x_continuous() +
  labs(title = "Distribution of Area", x = "Area (sqft)", y = "Frequency") +
  theme_minimal()


### Linear 
# Total Area vs. Price
ames %>%
  ggplot(aes(TotalArea,Sale_Price_T)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm") +
  labs(title = "Total Area vs. Sales Price", x = "Total Area (sqft)", y = "Sale Price ($,000)")


# Year Built vs. Price

ames %>%
  ggplot(aes(Year_Built,Sale_Price_T)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm") +
  labs(title = "Year Built vs. Sales Price", x = "Year Built", y = "Sale Price ($,000)")




# Overall Condition vs. Price

ames %>%
  ggplot(aes(Overall_Cond_n,Sale_Price_T)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm") +
  labs(title = "Overall Condition vs. Sales Price", x = "Overall Condition", y = "Sale Price ($,000)")

cor(ames$Sale_Price_T,ames$Overall_Cond_n)



## "SalePrice"


#housing<- housing %>% 
#mutate_if(is.numeric, ~replace_na(., 0)) %>%
#  mutate_if(is.character, ~replace_na(., ""))

#housing<- housing %>% 
#  mutate(across(everything(), ~replace(.x, is.nan(.x), 0)))




# test set will be 20% of housing_data data
set.seed(2023, sample.kind="Rounding")
test_index <- createDataPartition(y = ames$Sale_Price_T, times = 1,
                                  p = 0.2, list = FALSE)
train_set <- ames[-test_index,]
test_set <- ames[test_index,]



############## Data Exploration and Visualization



knitr::kable(dim(ames),caption = "Ames Housing Dataset dimension")

knitr::kable(head(ames), caption = "Ames Housing Dataset")

knitr::kable(summary(ames), caption = "Ames Housing Dataset Summary") 

#distinct_Housing <- housing_data %>% summarize(n_users = n_distinct(userId),
#                              n_movies = n_distinct(movieId), n_genres = n_distinct(genres))

#knitr::kable(distinct_Housing, "pandoc", caption = "Unique users, movies, and genres")



 



###########################################################################################################################
# Recommendation System Model - develop, train and test
###########################################################################################################################



# Linear Model

RMSE <- function(true_ratings, predicted_ratings){
  sqrt(mean((true_ratings - predicted_ratings)^2, na.rm = TRUE))
}


# Calculate the overall average rating across all movies included in the training set

mu_hat <- mean(train_set$Sale_Price_T)


# Calculate RMSE based on naive model
naive_rmse <- round(RMSE(test_set$Sale_Price_T, mu_hat),2)
rmse_results <- tibble(method = "Just the average in ,000", RMSE = naive_rmse)
cat("\nNaive RMSE in ,000 :",naive_rmse)

# Estimate Area effect (b_a)


head(train_set)

model <- train_set %>%
  #filter(yearID %in% 1961:2001) %>%
  #mutate(BB = BB/G, HR = HR/G, R = R/G) %>%
  lm(Sale_Price_T ~ TotalArea , data = .)

y_hat <- predict(model, newdata = test_set)

RMSE(test_set$Sale_Price_T,y_hat)



# Calculate RMSE based on area effects
model_rmse <- RMSE(test_set$Sale_Price_T,y_hat)
rmse_results <- bind_rows(rmse_results,
                          tibble(method="Area Effect Model in in ,000",
                                     RMSE = model_rmse ))

rmse_results %>% knitr::kable()

# Estimate year built effect along with total area  effect

model <- ames %>%
  #filter(yearID %in% 1961:2001) %>%
  #mutate(BB = BB/G, HR = HR/G, R = R/G) %>%
  lm(Sale_Price_T ~ TotalArea + Year_Built + Overall_Cond + Garage_Cars + Garage_Area +
     Total_Bsmt_SF + Year_Remod_Add +Mas_Vnr_Area, data = .)

y_hat <- predict(model, newdata = test_set)

RMSE(test_set$Sale_Price_T,y_hat)

tidy(model, conf.int = TRUE)


# Calculate RMSE based on movie and user effects
model_rmse <- RMSE(test_set$Sale_Price_T,y_hat)

rmse_results <- bind_rows(rmse_results,
                          tibble(method="Area + Year Built Effects Model in ,000",  
                                     RMSE = model_rmse ))
rmse_results %>% knitr::kable()


## Non-Linear Model

## K Nearest Neighbor 

train_knn <- train(Sale_Price_T ~ ., method = "knn",
                   data = train_set,
                   tuneGrid = data.frame(k = seq(9, 71, 2)))

ggplot(train_knn, highlight = TRUE)

y_hat <- round(predict(train_knn, test_set, type = "raw"))

# Calculate RMSE based on Knn Model
model_rmse <- RMSE(test_set$Sale_Price_T,y_hat)

rmse_results <- bind_rows(rmse_results,
                          tibble(method="Knn Model in ,000",  
                                 RMSE = model_rmse ))
rmse_results %>% knitr::kable()



confusionMatrix(factor(y_hat,levels=1:490),factor(test_set$Sale_Price_T,levels=1:490))$overall["Accuracy"]



# fit a classification tree and plot it
train_rpart <- train(Sale_Price_T ~ .,
                     method = "rpart",
                     tuneGrid = data.frame(cp = seq(0.0, 0.1, len = 25)),
                     data = train_set)
plot(train_rpart)

predict(train_rpart, test_set)

y_hat <- round(predict(train_rpart, test_set))

#y_hat <- factor(predict(train_rpart, test_set))

# Calculate RMSE based on Knn Model
model_rmse <- RMSE(test_set$Sale_Price_T,y_hat)

rmse_results <- bind_rows(rmse_results,
                          tibble(method="Knn Model in ,000",  
                                 RMSE = model_rmse ))
rmse_results %>% knitr::kable()

confusionMatrix(factor(y_hat,levels=1:490),factor(test_set$Sale_Price_T,levels=1:490))$overall["Accuracy"]


#######################
