# TaskiFlow

TaskiFlow merupakan aplikasi manajemen tugas berbasis Flutter yang terintegrasi dengan REST API berbasis Node.js dan SQLite. Aplikasi ini dilengkapi dengan autentikasi JSON Web Token (JWT), state management menggunakan Provider, serta menerapkan arsitektur berlapis (Layered Architecture) untuk menghasilkan kode yang modular dan mudah dikembangkan.

Tugas 2 Individu  
Pengembangan Aplikasi Berbasis Platform  
Topik: Implementasi Teknik Pengembangan Aplikasi Mobile Berbasis Flutter dengan Integrasi REST API

---

# Arsitektur Proyek

UTS-PABP/  
backend/ → REST API (Node.js + Express + SQLite)  
taskiflow/ → Aplikasi mobile Flutter  

Aplikasi mobile berfungsi sebagai client yang berkomunikasi dengan backend melalui REST API.

---

# Backend REST API

Backend dikembangkan menggunakan Node.js, Express.js, dan SQLite sebagai database. Sistem menggunakan JSON Web Token (JWT) untuk autentikasi dan otorisasi pengguna.

Fitur utama backend meliputi:

- Autentikasi berbasis JWT (register dan login)  
- Operasi CRUD untuk manajemen task  
- Middleware otorisasi untuk melindungi endpoint  
- Dukungan CORS untuk integrasi dengan aplikasi mobile  
- Endpoint health-check untuk memastikan server berjalan  

Endpoint API yang tersedia:

- POST /auth/register → Registrasi pengguna (tanpa autentikasi)  
- POST /auth/login → Login dan mendapatkan token (tanpa autentikasi)  
- GET /tasks → Mengambil seluruh task user (butuh autentikasi)  
- POST /tasks → Menambahkan task baru (butuh autentikasi)  
- GET /tasks/:id → Detail task (butuh autentikasi)  
- PUT /tasks/:id → Memperbarui task (butuh autentikasi)  
- DELETE /tasks/:id → Menghapus task (butuh autentikasi)  

Cara menjalankan backend:

cd backend  
npm install  
cp .env.example .env  
npm start  

Server akan berjalan pada http://localhost:5000

---

# Aplikasi Mobile (Flutter)

Aplikasi mobile dikembangkan menggunakan Flutter sebagai framework utama. Aplikasi ini terhubung dengan backend melalui HTTP request dan menggunakan Provider untuk pengelolaan state.

Teknologi yang digunakan:

- provider untuk state management  
- http untuk komunikasi REST API  
- flutter_secure_storage untuk penyimpanan token secara aman  
- google_fonts untuk tipografi  
- shimmer untuk tampilan loading  
- intl untuk format tanggal dan waktu  
- gap untuk pengaturan spasi layout  

---

# Arsitektur Layered

Struktur proyek Flutter menggunakan pendekatan layered architecture:

taskiflow/lib/  
├── main.dart  
├── app.dart  
├── core/  
├── features/  
│   ├── auth/  
│   └── tasks/  
└── shared/  

Pendekatan ini memisahkan antara data, logic, dan tampilan sehingga kode lebih mudah dikembangkan dan dipelihara.

---

# Fitur Aplikasi

Fitur utama:

- Autentikasi JWT dengan penyimpanan token yang aman  
- Three-state UI (loading, error, dan data)  
- Manajemen state menggunakan Provider  
- Navigasi antar halaman menggunakan named routes  

Fitur tambahan:

- Operasi CRUD lengkap untuk task sebagai pengembangan dari requirement utama (read data)  
- Animasi transisi antar halaman  
- Fitur pencarian dan filter task  
- Mode gelap (dark mode)  
- Splash screen dengan mekanisme auto-login  

---

# Alur Autentikasi JWT

User melakukan login  
Server mengembalikan token  
Token disimpan menggunakan secure storage  
Token dikirim pada setiap request melalui header Authorization  
User dapat mengakses fitur yang membutuhkan autentikasi  

---

# Author

Nanda Raissa  
Pengembangan Aplikasi Berbasis Platform  
GitHub: https://github.com/nandaRssa  
