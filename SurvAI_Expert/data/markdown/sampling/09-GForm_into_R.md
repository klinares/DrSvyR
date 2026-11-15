---
id: "sampling/09-GForm_into_R"
source: "sampling"
course: ""
course_title: ""
doc_type: "book"
title: "9  Form Survey into Dashboard"
original: "09-GForm_into_R.md"
pages: 
sha256: "0de7dd8c7f643251b27a07c05c316834a90dc05e2e2f50a457cbc407dcf0cf73"
converted_by: "01_convert.R (no model)"
converted_at: "2026-11-14T21:29:46"
---

<!-- source: https://bookdown.org/dsciencelabs/sampling_and_survey_techniques/09-GForm_into_R.html -->

# 9  Form Survey into Dashboard

Integrating survey results into dashboards offers key advantages in **analysis speed**, **dynamic visualization**, and **data-driven decision making**.

## 9.1 Key Dashboard Elements

An effective survey dashboard is made up of several interactive and visual components that help users explore and interpret data easily. Below is a list of common elements found in most survey dashboards, along with their core functions.

| Component | Function |
|----|----|
| **KPI/Value Boxes** | Show key metrics (e.g., total responses, average satisfaction) |
| **Interactive Charts** | Visualize distribution and trends using bar, pie, or line charts |
| **Filters/Dropdowns** | Allow data slicing by time, region, or user segment |
| **Table/Data Grid** | Display survey responses in detail, with export/download option |
| **Word Cloud** | Visualize keywords from open-ended responses |
| **Map (Optional)** | Show geographical distribution of respondents |

## 9.2 Dashboard Frameworks

Choosing the right tool depends on your team’s technical skills, data sources, and the complexity of your dashboard needs. Below is a comparison of popular platforms used to build survey dashboards, highlighting their key features and strengths.

[TABLE]

## 9.3 Conneting Google Form

### 9.3.1 Using R

1.  **Create Google Form** → Automatically saves responses to Google Sheets.
2.  **Use `googlesheets4` R package** to fetch survey data.
3.  **Clean and analyze the data**.
4.  **Build interactive dashboards** using `flexdashboard` or `shiny`.

```r
# Load the googlesheets4 package to interact with Google Sheets
library(googlesheets4)

# Disable authentication – this allows reading only public Google Sheets
gs4_deauth()

# Define the URL of the Google Sheet you want to read
sheet_url <- "https://docs.google.com/spreadsheets/d/1hNDRkTtvi7nO_SUW3JJtA4DOR7_wBOL_WG7f-xEi8-M/edit?usp=sharing"

# Read the data from the Google Sheet into R
survey_data <- read_sheet(sheet_url)

# Display the data that was read from the Google Sheet
survey_data
```

    # A tibble: 1 × 8
      Timestamp           Staff di program studi membantu m…¹ Dosen memperhatikan …²
      <dttm>              <chr>                               <chr>                 
    1 2025-05-19 11:44:58 Sangat memuaskan                    Sangat memuaskan      
    # ℹ abbreviated names:
    #   ¹​`Staff di program studi membantu mahasiswa dalam layanan akademik`,
    #   ²​`Dosen memperhatikan kehadiran mahasiswa di dalam perkuliahan`
    # ℹ 5 more variables:
    #   `Proses perkuliahan mengutamakan pendekatan ilmiah seperti (PBL, Studi kasus, proyek dll) sehingga tercipta suasana akademik yang positip` <chr>,
    #   `Proses pembelajaran relevan dengan karakteristik keilmuan program studi dan memberi kompeensi yang unggul pada mahasiswa` <chr>,
    #   `Fasilitas, sarana dan prasarana (gedung-gedung, ruangan kelas, laboratorium, taman, dll) sehat, bersih selalu dirawat dengan baik` <chr>, …

### 9.3.2 Using Python

1.  Create Your Google Form

- Go to Google Forms.
- Create a new form and add questions.
- Click on “Responses” tab → click the Google Sheets icon to link responses to a spreadsheet.

2.  Get the Public CSV Link from Google Sheets

- Open the linked Google Sheet.
- Click Share → set the sharing to:
- Anyone with the link can view
- Copy the sheet URL.

3.  Read the Data in Python using pandas

For example:

    import pandas as pd

    # Use Google Sheet CSV export link
    sheet_url = "https://docs.google.com/spreadsheets/d/1hNDRkTtvi7nO_SUW3JJtA4DOR7_wBOL_WG7f-xEi8-M/export?format=csv"
    survey_data = pd.read_csv(sheet_url)

    # Show the data
    survey_data

                 Timestamp  ...           Email address
    0  19/05/2025 11:44:58  ...  [email]

    [1 rows x 8 columns]

## 9.4 Shiny App

Survei Sensus Penduduk

[Toggle navigation](_w_761a2721a34648b6a9e46e4e9f283fe9/#)

- [ Isi Survei](_w_761a2721a34648b6a9e46e4e9f283fe9/#shiny-tab-survey)
- [ Data Terkumpul](_w_761a2721a34648b6a9e46e4e9f283fe9/#shiny-tab-data)

### Formulir Survei

Nama Lengkap

Usia

Jenis Kelamin

Laki-laki Perempuan

Status Pernikahan

Belum Kawin Kawin Cerai

Pendidikan Terakhir

SD SMP SMA Diploma S1 S2 S3

Pekerjaan

Jumlah Anggota Keluarga

Status Kepemilikan Rumah

Milik Sendiri Kontrak Menumpang

Jenis Tempat Tinggal

Rumah Apartemen Kos Lainnya

Apakah Anda Merokok?

Apakah Anda Memiliki Asuransi?

Apakah Anda Pernah Pindah Domisili?

Apakah Anda Punya Akses Internet?

Berapa Kali ke Fasilitas Kesehatan Tahun Lalu?

Jenis Transportasi Utama

Motor Mobil Angkutan Umum Sepeda Jalan Kaki

Apakah Anda Mengikuti Program Pemerintah?

Bahasa yang Digunakan di Rumah

Apakah Anda Bisa Membaca & Menulis?

Sumber Air Utama

PAM Sumur Air Hujan Sungai

Apakah Anda Memiliki Ponsel?

Kirim

Reset

### Data Survei Terkumpul
