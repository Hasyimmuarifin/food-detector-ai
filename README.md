# 🍽️ Food Detector – AI-Powered Food Recognition App

**Food Detector** adalah aplikasi Android berbasis **Flutter dan Artificial Intelligence** yang mampu mendeteksi jenis makanan dari gambar, serta menampilkan **informasi tambahan seperti negara asal dan komposisi bahan makanan**.  
Model AI dilatih menggunakan dataset **[Food-101](https://www.kaggle.com/datasets/dansbecker/food-101)** yang telah difilter menjadi 20 kategori makanan populer.

<p align="center">
  <img src="https://github.com/user-attachments/assets/a85491b8-a2db-440a-88a9-75e972818e21" width="200"/>
  <img src="https://github.com/user-attachments/assets/b7251e76-f680-45c7-baee-ca4958b98bea" width="200"/>
  <img src="https://github.com/user-attachments/assets/2f011e73-c3f4-4bfa-9eaa-0b1dd558be8f" width="200"/>
  <img src="https://github.com/user-attachments/assets/a56ec326-3d68-40a6-a4d8-9bec041e533b" width="200"/>
</p>

---

## 🚀 Fitur Utama

- 🔍 **Deteksi Makanan Otomatis** menggunakan model AI berbasis *Convolutional Neural Network (CNN)*
- 📷 **Dua Metode Input**:
  - **Kamera Langsung** – Ambil gambar makanan secara real-time.
  - **Upload Gambar** – Pilih gambar dari galeri.
- 🌍 **Informasi Tambahan**:
  - **Negara asal** dari makanan yang terdeteksi.
  - **Komposisi/bahan utama** dari makanan tersebut.
- ⚡ Performa ringan dan cepat, cocok untuk perangkat Android.

---

## 🍱 20 Jenis Makanan yang Didukung

Berikut adalah daftar makanan yang dapat dikenali oleh aplikasi:

| No. | Makanan               | No. | Makanan               |
|-----|------------------------|-----|------------------------|
| 1   | Beignets              | 11  | Pizza                 |
| 2   | Dumplings             | 12  | Seaweed Salad         |
| 3   | Edamame               | 13  | Spaghetti Bolognese   |
| 4   | French Fries          | 14  | Spaghetti Carbonara   |
| 5   | Hamburger             | 15  | Strawberry Shortcake  |
| 6   | Hot Dog               | 16  | Sushi                 |
| 7   | Ice Cream             | 17  | Tacos                 |
| 8   | Macarons              | 18  | Takoyaki              |
| 9   | Oysters               | 19  | Tiramisu              |
| 10  | Pho                   | 20  | Waffles               |

---

## 🛠️ Teknologi yang Digunakan

- **Flutter** – Framework UI untuk aplikasi Android
- **TensorFlow Lite** – Untuk menjalankan model AI di perangkat mobile
- **Python (Jupyter)** – Proses pelatihan dan konversi model Food101
- **Kaggle Dataset** – [Food-101 dataset](https://www.kaggle.com/datasets/dansbecker/food-101)

---

## 📸 Contoh Penggunaan

**Metode Deteksi:**
- Ambil gambar makanan menggunakan kamera.
- Atau, upload gambar dari galeri.
- Hasil: Nama makanan, negara asal, dan bahan utama ditampilkan dengan akurasi tinggi.

---

## 📦 Instalasi & Menjalankan Aplikasi

1. Clone repositori ini:
   ```bash
   git clone https://github.com/username/food-detector.git
2. Masuk ke direktori:
   ```bash
   cd food-detector
3. Jalankan aplikasi di emulator atau device:
   ```bash
   flutter pub get
   flutter run

---

## 📚 Lisensi

Proyek ini bersifat open-source di bawah lisensi MIT.
Silakan gunakan dan modifikasi sesuai kebutuhan.

## 👨‍💻 Kontribusi

Pull request dan saran sangat terbuka. Jangan ragu untuk fork project ini dan kembangkan fitur baru!

## 💡 Catatan

   - Aplikasi ini bersifat demo untuk edukasi dan penelitian.
   - Informasi negara asal dan bahan makanan bersifat general dan bisa disesuaikan.

**📧 Hubungi jika ada pertanyaan atau ide: hasyimmuarifin22@gmail.com**

---
