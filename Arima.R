# Import Library
library(readxl)
dataPM <- read_excel("D:/23051204329_DIMASDWIPRAMONONUGROHO_TIJ23/Statistika/DatasetTugasAkh.xlsx")
View(dataPM)
# Menghapus kolom nomor 1
dataPM = dataPM[,c(-1)]

# Membuat time series
dataPM = ts(dataPM, start = (2025), frequency=365)

# Melakukan plotting
plot(dataPM, main="PM 2.5 Makassar")

# Melakukan Augmented Dickey-Fuller Test
adf.test(dataPM)

# Melakukan Augmented Dickey-Fuller Test first Difference
adf.test(diff(dataPM))

# Membagi canvas menjadi dua (atas dan bawah)
par(mfrow=c(2,1))

# Menguji auto correlation function dan partial auto correlation function
acf(diff(dataPM))
pacf(diff(dataPM))

# Melihat list model ARIMA yang cocok dengan data
auto.arima(dataPM, trace = TRUE)

# Merancang model ARIMA
model1 = Arima(dataPM, order = c(0,1,2))

#Melakukan coefficient test
coeftest(model1)

#Melakukan pengukuran AIC
AIC(model1)

# Melakukan peramalan forecast 15 hari ke depan
forecast(model1, h=16)

# Melakukan plotting untuk peramalan forecast 15 hari ke depan
par(mfrow=c(1,1))
plot(forecast(model1, h=16))

# --- Evaluasi Model ---
accuracy(model1$residuals, dataPM)
