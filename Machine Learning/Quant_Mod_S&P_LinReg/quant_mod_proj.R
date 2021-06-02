# SPY VS. VOO - Linear Regression Predicting S & P 500 Index Performance in 1 Quarter 

library(quantmod)
library(zoo)
library(xts)

# SPY (Partial holdings)
getSymbols(c('AAPL', 'MSFT', 'AMZN', 'FB', 'GOOGL', 'GOOG', 'TSLA', 'V',
             'DIS', 'NVDA', 'UNH', 'MA', 'PG', 'PYPL', 'HD', 'BAC', 'INTC',
             'CMCSA', 'NFLX', 'XOM', 'VZ', 'ADBE'),
             src='yahoo',
             from = as.Date('2021-1-4'), to = as.Date('2021-4-22'),
             periodicity = 'daily')

spi_close <- merge(SPY$SPY.Close, AAPL$AAPL.Close, MSFT$MSFT.Close, 
             AMZN$AMZN.Close, FB$FB.Close, GOOGL$GOOGL.Close,
             GOOG$GOOG.Close, TSLA$TSLA.Close, V$V.Close, DIS$DIS.Close, NVDA$NVDA.Close,
             UNH$UNH.Close, MA$MA.Close, PG$PG.Close, PYPL$PPYPL.Close, HD$HD.Close, BAC$BAC.Close,
             INTC$INTC.Close, CMCSA$CMCSA.Close, NFLX$NFLX.Close, XOM$XOM.Close, VZ$VZ.Close, 
             ADBE$ADBE.Close)

missmap(spi_close)

spi_close <- na.omit(spi_close)

# Examining performance of SPY closing price over past quarter. 
chart_Series(spi_close$SPY.Close)
barChart(spi_close$SPY.Close, bar.type='hlc')
plot(spi_close$SPY.Close)
candleChart(SPY)

# Converting individual time series rows to index column. 

spi_close <- fortify(spi_close)

# Variable conversion/EDA 

spi_close_num <- dplyr::select_if(spi_close, is.numeric)
spi_close_cor <- cor(spi_close_num)
heatmap(spi_close_cor)

FB_MS.Close <- ggplot(spi_close_num, aes(FB.Close, MSFT.Close)) + geom_point(color='orange') + stat_smooth() + 
  labs(title='Facebook vs. Microsoft Closing Prices', subtitle = 'Q1 2021', caption='Data from Yahoo! Finance', x='Facebook', y='Microsoft') +
  theme(plot.title=element_text(face='bold', hjust=0.5), plot.subtitle=element_text(hjust=0.5), plot.caption=element_text(face='italic'))

TSLA_APP.Close <- ggplot(spi_close_num, aes(TSLA.Close, AAPL.Close)) + geom_point(color='red') + stat_smooth() +
  labs(title='Tesla vs. Apple Close', subtitle='Q1 2021', caption='Data from Yahoo! Finance', x = 'Tesla',y = 'Apple') +
  theme(plot.title=element_text(face='bold', hjust=0.5), plot.subtitle=element_text(hjust=0.5), plot.caption=element_text(face='italic'))

TSLA_AMZN.Close <- ggplot(spi_close_num, aes(TSLA.Close, AMZN.Close)) + geom_point(color='purple') + stat_smooth() +
  labs(title='Tesla vs. Amazon Close', subtitle='Q1 2021', caption = 'Data from Yahoo! Finance', x = Tesla, y = Amazon) +
  theme(plot.title=element_text(face='bold', hjust=0.5), plot.subtitle=element_text(hjust=0.5), plot.caption=element_text(face='italic'))
  
TSLA_NFLX.Close <- ggplot(spi_close_num, aes(TSLA.Close, NFLX.Close)) + geom_point(color='orange') + stat_smooth() +
  labs(title='Tesla vs. Netflix Close', subtitle='Q1 2021', caption='Data from Yahoo! Finance', x = 'Tesla', y = 'Netflix') +
  theme(plot.title=element_text(face='bold', hjust=0.5), plot.subtitle=element_text(hjust=0.5), plot.caption=element_text(face='italic'))

PG_VZ.Close <- ggplot(spi_close_num, aes(PG.Close, VZ.Close)) + geom_point(color='red') + stat_smooth() +
  labs(title = 'Proctor and Gamble and Verizon Close', subtitle='Q1 2021', caption='Data from Yahoo! Finance', x = 'Proctor & Gamble', y = 'Verizon') +
  theme(plot.title=element_text(face='bold', hjust=0.5), plot.subtitle=element_text(hjust=0.5), plot.caption=element_text(face='italic'))

NVDA_ADBE.Close <- ggplot(spi_close_num, aes(NVDA.Close, ADBE.Close)) + geom_point(color='green') + stat_smooth() +
  labs(title='Nvida vs. Adobe Close', subtitle='Q1 2021', caption='Data from Yahoo! Finance', x = 'Nvida', y = 'Adobe') +
  theme(plot.title=element_text(hjust=0.5, face='bold'), plot.subtitle=element_text(hjust=0.5), plot.caption=element_text(face='italic'))

# Train/test split 

set.seed(101)
spi.sample <- sample.split(spi_close_num$SPY.Close, SplitRatio = 0.8)
spi.train <- subset(spi_close_num, spi.sample == TRUE)
spi.test <- subset(spi_close_num, spi.sample == FALSE)

# Constructing Linear Regression Model with Spy Closing Price as outcome variable. 

spi_mod <- lm(SPY.Close ~ ., data = spi.train)
summary(spi_mod)
spi_mod <- lm(SPY.Close ~ AAPL.Close + MSFT.Close + TSLA.Close + V.Close + NVDA.Close +
                 HD.Close + BAC.Close + INTC.Close + XOM.Close, data = spi.train)

spi_pred <- predict(spi_mod, spi.test)
summary(spi_pred)

spi_mod.results <- cbind(spi_pred, spi.test)
colnames(spi_mod.results) <- c('Predicted', 'Actual')
spi_mod.results <- as.data.frame(spi_mod.results)
 
spi_mod_close_graph <- ggplot(spi_mod.results, aes(Predicted, Actual)) + geom_point() + stat_smooth() +
  labs(title='SPY Closing Price Model Predictions', caption='Data from Yahoo! Finance', x = 'Predicted', y = 'Actual') +
  theme(plot.title=element_text(face='bold', hjust=0.5), plot.caption=element_text(face='italic'))

spi_open <- merge(SPY$SPY.Open, AAPL$AAPL.Open, MSFT$MSFT.Open, 
                  AMZN$AMZN.Open, FB$FB.Open, GOOGL$GOOGL.Open,
                  GOOG$GOOG.Open, TSLA$TSLA.Open, V$V.Open, DIS$DIS.Open, NVDA$NVDA.Open,
                  UNH$UNH.Open, MA$MA.Open, PG$PG.Open, PYPL$PPYPL.Open, HD$HD.Open, BAC$BAC.Open,
                  INTC$INTC.Open, CMCSA$CMCSA.Open, NFLX$NFLX.Open, XOM$XOM.Open, VZ$VZ.Open, 
                  ADBE$ADBE.Open)

spi.open <- fortify(spi_open)

spi.open <- na.omit(spi.open)

# EDA

spi.open.num <- dplyr::select_if(spi.open, is.numeric)
spi.open.cor <- cor(spi.open.num)
heatmap(spi.open.cor)

# Univariate
chart_Series(AMZN$AMZN.Open)
chart_Series(PG$PG.Open)

# Multivariate
candleChart(NFLX)
candleChart(GOOGL)

DIS_TSLA_open <- ggplot(spi.open, aes(DIS.Open, TSLA.Open)) + geom_point() + stat_smooth() +
  labs(title='Disney vs. Tesla Open', subtitle='Q1 2021', caption='Data from Yahoo! Finance') +
  theme(plot.title=element_text(hjust=0.5, face='bold'), plot.subtitle=element_text(hjust=0.5), plot.caption=element_text(face='italic'))

MA_V_open <- ggplot(spi.open, aes(MA.Open, V.Open)) + geom_point() + stat_smooth() +
  labs(title='Mastercard vs. Verizon', subtitle='Q1 2021', caption = 'Data from Yahoo! Finance') +
  theme(plot.title=element_text(face='bold', hjust=0.5), plot.subtitle=element_text(hjust=0.5), plot.caption=element_text(face='italic'))
  
NVDA_ADBE_open <- ggplot(spi.open, aes(NVDA.Open, ADBE.Open)) + geom_point() + stat_smooth() +
  labs(title='Nvida vs. Adobe', subtitle='Q1 2021', caption='Data from Yahoo! Finance') +
  theme(plot.title=element_text(face='bold', hjust=0.5), plot.subtitle=element_text(hjust=0.5), plot.caption=element_text(face='italic'))

# Train/Test Split

set.seed(101)
spi.open.sample <- sample.split(spi.open.num, SplitRatio = 0.7)
spi.open.train <- subset(spi.open.num, spi.open.sample == TRUE)
spi.open.test <- subset(spi.open.num, spi.open.sample == FALSE)

spi.open.mod <- lm(SPY.Open ~ ., data = spi.open.train)
summary(spi.open.mod)

spi.open.pred <- predict(spi.open.mod, spi.open.test)

spi.open.results <- cbind(spi.open.pred, spi.open.test)
colnames(spi.open.results) <- c('Predicted', 'Actual')
spi.open.results <- as.data.frame(spi.open.results)

spi.open.graph <- ggplot(spi.open.results, aes(Predicted, Actual)) + geom_point() + stat_smooth() +
  labs(title='SPY Open Model Results', caption='Data from Yahoo! Finance') +
  theme(plot.title=element_text(face='bold', hjust=0.5), plot.subtitle=element_text(hjust=0.5), plot.caption=element_text(face='italic'))


# VOO (Partial holdings)

getSymbols(c('CHTR', 'SBAC', 'LIN', 'MNST', 'WEC', 'HPQ', 'HLT', 'KHC', 'NLSN',
             'CCI', 'KEYS', 'QRVO', 'ANTM', 'ETSY', 'IRM', 'EQIX', 'XRAY', 'FTV',
             'WRK', 'WBA', 'MDT', 'SPGI', 'HPE'), src='yahoo',
           from=as.Date('2021-1-4'), to = as.Date('2021-4-22'), periodicity ='daily') 

# VOO holding performances (time series)

chart_Series(HLT)
chart_Series(NLSN)
chart_Series(ETSY)

# VOO holding performances (candlestick)
candleChart(HPE)
candleChart(FTV)

voo.close <- data.frame(as.xts(merge(VOO$VOO.Close, CHTR$CHTR.Close, SBAC$SBAC.Close, MNST$MNST.Close,
                   LIN$LIN.Close, WEC$WEC.Close, HPQ$HPQ.Close, HLT$HLT.Close, KHC$KHC.Close,
                   NLSN$NLSN.Close, CCI$CCI.Close, KEYS$KEYS.Close, QRVO$QRVO.Close, ANTM$ANTM.Close,
                   ETSY$ETSY.Close, IRM$IRM.Close, EQIX$EQIX.Close, XRAY$XRAY.Close, FTV$FTV.Close,
                   WRK$WRK.Close, WBA$WBA.Close, MDT$MDT.Close, SPGI$SPGI.Close, HPE$HPE.Close)))

voo.close <- na.omit(voo.close)

voo.close.num <- dplyr::select_if(voo.close, is.numeric)
voo.cor <- cor(voo.close.num)
heatmap(voo.cor)

SBAC_QRVO <- ggplot(voo.close.num, aes(SBAC.Close, QRVO.Close)) + geom_point() + stat_smooth() +
  labs(title='SBA Communications vs. Qorvo', subtitle='Q1 2021', caption='Data from Yahoo! Finance', x = 'SBAC', y = 'QRVO') +
  theme(plot.title=element_text(face='bold', hjust=0.5), plot.subtitle=element_text(hjust=0.5), plot.caption=element_text(face='italic'))

IRM_HLT <- ggplot(voo.close.num, aes(IRM.Close, HLT.Close)) + geom_point() + stat_smooth() +
  labs(title='Iron Mountain vs. Hilton', subtitle='Q1 2021', caption='Data from Yahoo! Finance', x = 'Iron Mountain', y = 'Hilton') +
  theme(plot.title=element_text(face='bold', hjust=0.5), plot.subtitle=element_text(hjust=0.5), plot.caption=element_text(face='italic'))

LIN_WBA <- ggplot(voo.close.num, aes(LIN.Close, WBA.Close)) + geom_point() + stat_smooth() +
  labs(title='Linde PLC vs. WBA', subtitle='Q1 2021', caption='Data from Yahoo! Finance', x = 'Linde PLC', y = 'Walgreens Boots Alliance') +
  theme(plot.title=element_text(face='bold', hjust=0.5), plot.subtitle=element_text(hjust=0.5), plot.caption=element_text(face='italic'))

set.seed(101)

voo.close.sample <- sample.split(voo.close.num$VOO.Close, SplitRatio = 0.8)
voo.close.train <- subset(voo.close.num, voo.close.sample == TRUE)
voo.close.test <- subset(voo.close.num, voo.close.sample == FALSE)

voo.mod <- lm(VOO.Close ~., data = voo.close.train)
summary(voo.mod)

voo.pred <- predict(voo.mod, voo.close.test)

voo.mod.results <- cbind(voo.pred, voo.close.test)
colnames(voo.mod.results) <- c('Predicted', 'Actual')
voo.mod.results <- as.data.frame(voo.mod.results)

voo.close.graph <- ggplot(voo.mod.results, aes(Predicted, Actual)) + geom_point() + geom_smooth() +
  labs(title='VOO Close Model Results', caption='Data from Yahoo! Finance') + 
  theme(plot.title=element_text(face='bold', hjust=0.5), plot.caption=element_text(face='italic'))

voo.open <- data.frame(as.xts(merge(VOO$VOO.Open, CHTR$CHTR.Open, SBAC$SBAC.Open, MNST$MNST.Open,
                                    LIN$LIN.Open, WEC$WEC.Open, HPQ$HPQ.Open, HLT$HLT.Open, KHC$KHC.Open,
                                    NLSN$NLSN.Open, CCI$CCI.Open, KEYS$KEYS.Open, QRVO$QRVO.Open, ANTM$ANTM.Open,
                                    ETSY$ETSY.Open, IRM$IRM.Open, EQIX$EQIX.Open, XRAY$XRAY.Open, FTV$FTV.Open,
                                    WRK$WRK.Open, WBA$WBA.Open, MDT$MDT.Open, SPGI$SPGI.Open, HPE$HPE.Open)))

voo.open.num <- dplyr::select_if(voo.open, is.numeric)
voo.open.cor <- cor(voo.open.num)
heatmap(voo.open.cor)

set.seed(101)

voo.open.sample <- sample.split(voo.open.num$VOO.Open, SplitRatio = 0.7)
voo.open.train <- subset(voo.open.num, voo.open.sample == TRUE)
voo.open.test <- subset(voo.open.num, voo.open.sample == FALSE)

voo.open.mod <- lm(VOO.Open ~., data = voo.open.train)
summary(voo.open.mod)

voo.open.pred <- predict(voo.open.mod, voo.open.test)

voo.open.results <- cbind(voo.open.pred, voo.open.test)
colnames(voo.open.results) <- c('Predicted', 'Actual')
voo.open.results <- as.data.frame(voo.open.results)

voo.open.graph <- ggplot(voo.open.results, aes(Predicted, Actual)) + geom_point() + stat_smooth() +
  labs(title='VOO Open Model Results', caption='Data from Yahoo! Finance') +
  theme(plot.title=element_text(face='bold', hjust=0.5), plot.caption=element_text(face='italic'))