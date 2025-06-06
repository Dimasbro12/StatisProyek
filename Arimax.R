# Pemuatan Paket
library(fpp3)    # Untuk peramalan deret waktu
library(urca)    # Untuk uji stasioneritas
library(readxl)  # Untuk membaca file Excel
library(dplyr)   # Untuk manipulasi data
library(ggplot2) # Untuk visualisasi

## 1. Persiapan Data ----
# Membaca data dari file Excel
data <- read_excel("C:/Users/LENOVO/Downloads/STA.xlsx") 

# Membersihkan dan memformat data
data_ts <- data %>%
  mutate(
    TANGGAL = as.Date(TANGGAL, format = "%d-%m-%Y"),
    PM25 = as.numeric(`PM2.5`)
  ) %>%
  as_tsibble(index = TANGGAL) %>%
  select(TANGGAL, PM25, TAVG, RH_AVG, FF_AVG) %>%
  filter(complete.cases(.))  # Hapus data yang tidak lengkap

## 2. Uji Stasioneritas ----
uji_stasioneritas <- function(data, variabel) {
  hasil <- ur.kpss(data[[variabel]])
  cat("Hasil Uji KPSS untuk", variabel, ":\n")
  print(summary(hasil))
}

# Melakukan uji untuk semua variabel
variabel_uji <- c("PM25", "TAVG", "RH_AVG", "FF_AVG")
walk(variabel_uji, ~uji_stasioneritas(data_ts, .x))

## Tambahan: Stasionerkan PM25 jika tidak stasioner ----
hasil_kpss_pm25 <- ur.kpss(data_ts$PM25)
summary_pm25 <- summary(hasil_kpss_pm25)

# Ambil nilai statistik uji dan critical value 5%
statistik_pm25 <- as.numeric(gsub(" ", "", strsplit(capture.output(summary_pm25)[4], ":")[[1]][2]))
kritikal_pm25 <- as.numeric(gsub(" ", "", strsplit(capture.output(summary_pm25)[6], " ")[[1]][3]))

# Periksa dan lakukan differencing jika perlu
if (!is.na(statistik_pm25) && !is.na(kritikal_pm25) && statistik_pm25 > kritikal_pm25) {
  cat("\nPM25 tidak stasioner (KPSS > nilai kritis). Melakukan differencing...\n")
  data_ts <- data_ts %>%
    mutate(PM25 = difference(PM25)) %>%
    filter(!is.na(PM25))
} else {
  cat("\nPM25 sudah stasioner. Tidak perlu transformasi.\n")
}


## 3. Pemodelan ARIMAX ----
# Membuat model ARIMAX
model <- data_ts %>%
  model(arima = ARIMA(PM25 ~ TAVG + RH_AVG + FF_AVG))

# Menampilkan ringkasan model
summary_model <- report(model)
print(summary_model)

## 4. Diagnostik Model ----
# Plot diagnostik residual
diagnostik_plot <- model %>% 
  gg_tsresiduals() +
  labs(title = "Diagnostik Residual Model ARIMAX")
print(diagnostik_plot)

# Uji Ljung-Box
ljung_box_test <- model %>% 
  residuals() %>% 
  features(.resid, ljung_box, lag = 10)
cat("\nHasil Uji Ljung-Box:\n")
print(ljung_box_test)

## 5. Peramalan ----
# Membuat data prediksi 14 hari ke depan
data_prediksi <- new_data(data_ts, n = 14) %>%
  mutate(
    TAVG = mean(data_ts$TAVG, na.rm = TRUE),
    RH_AVG = mean(data_ts$RH_AVG, na.rm = TRUE),
    FF_AVG = mean(data_ts$FF_AVG, na.rm = TRUE)
  )

# Membuat prediksi
ramalan <- model %>% forecast(new_data = data_prediksi)

# Visualisasi hasil
plot_ramalan <- autoplot(ramalan, data_ts) +
  labs(
    title = "Peramalan Tingkat PM2.5 14 Hari ke Depan",
    subtitle = "Menggunakan Model ARIMAX",
    y = "Konsentrasi PM2.5 (μg/m³)",
    x = "Tanggal"
  ) +
  theme_minimal()

print(plot_ramalan)

## 6. Evaluasi Model ----
# Membagi data menjadi training (80%) dan testing (20%)
train_test_split <- round(nrow(data_ts) * 0.8)
train <- data_ts %>% slice(1:train_test_split)
test <- data_ts %>% slice((train_test_split + 1):nrow(data_ts))

# Melatih model pada data training
model_train <- train %>%
  model(ARIMA(PM25 ~ TAVG + RH_AVG + FF_AVG))

# Melakukan prediksi pada data testing
ramalan_test <- forecast(model_train, new_data = test)

# Menghitung akurasi
akurasi <- accuracy(ramalan_test, test)
cat("\nHasil Evaluasi Akurasi Model:\n")
print(akurasi)

## 7. Perbandingan Nilai Aktual, Prediksi, dan Residual ----
# Menggabungkan nilai aktual, prediksi, dan residual
hasil_augment <- augment(model)

# Menampilkan beberapa baris pertama
print(head(hasil_augment %>% select(TANGGAL, PM25, .fitted, .resid)))

# (Opsional) Menyimpan ke file Excel
# library(writexl)
# write_xlsx(hasil_augment, "Hasil_Prediksi_dan_Residual.xlsx")

# (Opsional) Visualisasi perbandingan aktual vs prediksi
library(ggplot2)
ggplot(hasil_augment, aes(x = TANGGAL)) +
  geom_line(aes(y = PM25), color = "black", size = 1, linetype = "solid") +     # Aktual
  geom_line(aes(y = .fitted), color = "blue", size = 1, linetype = "dashed") +  # Prediksi
  labs(title = "Perbandingan Nilai Aktual vs Prediksi",
       y = "PM2.5", x = "Tanggal") +
  theme_minimal()

## 8. Simpan Hasil ke Excel ----
# Memuat paket untuk ekspor Excel
library(writexl)

# Simpan hasil augment ke file Excel
write_xlsx(hasil_augment, path = "C:/Users/LENOVO/Downloads/Hasil_Prediksi_Residual.xlsx")

