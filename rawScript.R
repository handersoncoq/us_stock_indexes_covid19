

### Libraries

```{r libraries}

#install.packages("quantmod")
#install.packages("tidyquant")
library(quantmod)
library(tidyquant)
library(dplyr)
library(tidyr)


### Get major stock indexes' data

stockIndexes = c("^GSPC", "^DJI", "^IXIC")

############

indexesData <- tq_get(stockIndexes,
                 from = "2020-01-01",
                 to = Sys.Date(),
                 get = "stock.prices")

### See the first row of data of each index

indexesData %>%
  group_by(symbol) %>%
  slice(1)

############

GSPC <- indexesData %>% 
  filter(symbol == "^GSPC")

DJI <- indexesData %>% 
  filter(symbol == "^DJI")

IXIC <- indexesData %>% 
  filter(symbol == "^IXIC")

### Add daily return for each stock index

GSPC$return <- diff(GSPC$adjusted)/Lag(GSPC$adjusted)

DJI$return <- diff(DJI$adjusted)/Lag(DJI$adjusted)

IXIC$return <- diff(IXIC$adjusted)/Lag(IXIC$adjusted)


### Get 30 major stocks' data (DJI)


stocks = c("AAPL",	"AMGN",	"AXP",	"BA",	"CAT",	"CRM",	"CSCO",	"CVX",	"DIS",	"DOW",	"GS",	"HD",	"HON",	"IBM",	"INTC",	"JNJ",	"JPM",	"KO",	"MCD",	"MMM",	"MRK",	"MSFT",	"NKE",	"PG",	"TRV",	"UNH",	"V",	"VZ",	"WBA",	"WMT")

stocksData <- tq_get(stocks,
                 from = "2020-01-01",
                 to = Sys.Date(),
                 get = "stock.prices")

### Get covid-19 data

#install.packages("COVID19")
library(COVID19)

### world covid-19 data

x <- covid19(verbose = FALSE)

worldCovid <- data.frame(x[,c("date", "confirmed", "recovered", "deaths", "government_response_index", "people_vaccinated")]) %>%
  group_by(date) %>%
  arrange(date) %>% 
  summarize(confirmed = sum(confirmed, na.rm=TRUE), recovered = sum(recovered, na.rm=TRUE), deaths = sum(deaths, na.rm=TRUE), govRespIndex = mean(government_response_index, na.rm=TRUE), peopleVac = sum(people_vaccinated, na.rm=TRUE))

### U.S. covid-19 data

y <- covid19("USA", verbose = FALSE) 

usCovid <- data.frame(y[,c("date", "confirmed", "recovered", "deaths", "government_response_index", "people_vaccinated")]) %>% 
  arrange(date)

### Add daily change in cases

usCovid$change = diff(usCovid$confirmed)/Lag(usCovid$confirmed)


### Cobining data ###

### Combining US covid-19 data with stock index data

us_covid_indexes <- full_join(usCovid, indexesData)

us_covid_stocks <- full_join(usCovid, stocksData)

### Combining world covid-19 data with stock index data

world_covid_indexes <- full_join(worldCovid, indexesData)

world_covid_stocks <- full_join(worldCovid, stocksData)

### Exporting data

write.csv(us_covid_indexes, file="us_covid_indexes.csv", quote=F)

write.csv(us_covid_stocks, file="us_covid_stocks.csv", quote=F)

write.csv(world_covid_indexes, file="world_covid_indexes.csv", quote=F)

write.csv(world_covid_stocks, file="world_covid_stocks.csv", quote=F)
