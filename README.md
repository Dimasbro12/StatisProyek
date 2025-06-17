# Projek Akhir Statistika Kelompok 6

## Deskripsi Singkat
Projek ini membahas analisis komparatif antara model ARIMA dan ARIMAX untuk memprediksi konsentrasi polutan udara PM2.5 harian di Makassar, Indonesia. Data kualitas udara diperoleh dari AQICN, sedangkan data meteorologi (suhu, kelembaban, kecepatan angin) diambil dari BMKG.

## Metodologi
1. **Pra-pemrosesan Data**  
   - Data dibersihkan dari nilai hilang menggunakan interpolasi rata-rata hibrid.
   - Data diubah ke format deret waktu (time series).

2. **Modeling**
   - **ARIMA (0,1,2):** Model univariat untuk PM2.5, dipilih berdasarkan evaluasi RMSE, MAPE, dan uji Ljung-Box.
   - **ARIMAX (1,1,0):** Model multivariat dengan variabel eksogen (TAVG, RH_AVG, FF_AVG), menunjukkan performa lebih baik.

3. **Evaluasi**
   - Perbandingan hasil prediksi dan residual.
   - Visualisasi hasil aktual vs prediksi.
   - Evaluasi akurasi menggunakan metrik statistik.

## Struktur Folder & Penjelasan File

| File                        | Deskripsi                                                                 |
|-----------------------------|--------------------------------------------------------------------------|
| `Arima.R`                   | Script analisis dan pemodelan ARIMA pada data PM2.5.                     |
| `Arimax.R`                  | Script analisis dan pemodelan ARIMAX dengan variabel meteorologi.        |
| `ARIMA.sav`                 | File model ARIMA yang telah disimpan (format SPSS/SAS).                  |
| `HasilArima.spv`            | Output hasil analisis ARIMA (format SPSS Viewer).                        |
| `Kelompok 6_TIJ23_Akhir.pdf`| Laporan akhir lengkap dalam format PDF.                                  |
| `Kelompok 6_TIJ23_Akhir4Hal.pdf` | Ringkasan laporan akhir (4 halaman).                              |
| `LinkResources_StatisAkhir.txt` | Daftar sumber data dan referensi.                                 |
| `Pengerjaan ARIMA.docx`     | Draft pengerjaan dan catatan analisis ARIMA.                             |
| `README.md`                 | Dokumentasi dan petunjuk penggunaan projek ini.                          |
| `.Rhistory`                 | Riwayat perintah R yang pernah dijalankan.                               |

## Cara Menjalankan Analisis

1. **Persiapan**
   - Pastikan R dan paket berikut terinstal: `fpp3`, `urca`, `readxl`, `dplyr`, `ggplot2`, `writexl`.
   - Letakkan file data (`STA.xlsx` atau `DatasetTugasAkh.xlsx`) sesuai path di script.

2. **Menjalankan Script**
   - Jalankan `Arima.R` untuk analisis ARIMA.
   - Jalankan `Arimax.R` untuk analisis ARIMAX dan evaluasi variabel eksogen.

3. **Output**
   - Hasil prediksi dan residual dapat diekspor ke Excel.
   - Visualisasi dan evaluasi model tersedia di output script.

## Hasil Utama
- Model ARIMAX yang mengintegrasikan faktor meteorologi memberikan hasil prediksi PM2.5 yang lebih akurat dibandingkan ARIMA univariat.
- Faktor suhu, kelembaban, dan kecepatan angin terbukti berkontribusi signifikan terhadap fluktuasi PM2.5 di Makassar.
