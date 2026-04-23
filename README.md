# TaskiFlow

TaskiFlow merupakan aplikasi manajemen tugas berbasis Flutter yang terintegrasi dengan REST API berbasis Node.js dan SQLite. Aplikasi ini dilengkapi dengan autentikasi JWT, state management menggunakan Provider, serta menerapkan arsitektur berlapis (Layered Architecture).

Tugas 2 Individu - Pengembangan Aplikasi Berbasis Platform  
Topik: Implementasi Teknik Pengembangan pada Platform Web dan Mobile

## Arsitektur Proyek

UTS-PABP/
├── backend/          # REST API (Node.js + Express + SQLite)
├── frontend/         # Web frontend (HTML/JS)
└── taskiflow/        # Aplikasi mobile Flutter

---

## Backend - REST API

Teknologi yang digunakan meliputi Node.js, Express.js, SQLite (better-sqlite3), serta JSON Web Token (JWT) untuk autentikasi.

### Fitur Utama
- Autentikasi berbasis JWT (register dan login)
- Operasi CRUD untuk manajemen task
- Middleware otorisasi untuk melindungi endpoint
- Dukungan CORS untuk integrasi frontend dan mobile
- Endpoint health-check

### Endpoint API

Method | Endpoint        | Deskripsi                     | Auth  
POST   | /auth/register  | Registrasi pengguna           | Tidak  
POST   | /auth/login     | Login dan mendapatkan token   | Tidak  
GET    | /tasks          | Mengambil seluruh task user   | Ya  
POST   | /tasks          | Menambahkan task baru         | Ya  
GET    | /tasks/:id      | Detail task                   | Ya  
PUT    | /tasks/:id      | Memperbarui task              | Ya  
DELETE | /tasks/:id      | Menghapus task                | Ya  

### Menjalankan Backend

cd backend  
npm install  
cp .env.example .env  
npm start  

Server berjalan pada http://localhost:5000 secara default.


## Aplikasi Mobile - TaskiFlow (Flutter)

### Teknologi yang Digunakan

- provider - manajemen state  
- http - komunikasi dengan REST API  
- flutter_secure_storage - penyimpanan token secara aman  
- google_fonts - tipografi  
- shimmer - tampilan loading  
- intl - format tanggal dan waktu  
- gap - pengaturan spasi layout  

## Arsitektur Layered

taskiflow/lib/
├── main.dart  
├── app.dart  
├── core/  
├── features/  
│   ├── auth/  
│   └── tasks/  
└── shared/  

## Fitur Aplikasi

### Fitur Utama
- Autentikasi JWT dengan penyimpanan token yang aman  
- Three-state UI (loading, error, dan data)  
- Manajemen state menggunakan Provider  
- Navigasi antar halaman berbasis named routes  

### Fitur Tambahan
- Operasi CRUD lengkap untuk task  
- Animasi transisi antar halaman  
- Fitur filter dan pencarian task  
- Dukungan mode gelap (dark mode)  
- Splash screen dengan mekanisme auto-login  

## Alur Autentikasi JWT

User - Login - API - Token - Secure Storage - State Management - Akses Fitur  

Setiap permintaan ke endpoint task menyertakan token pada header Authorization.

## Author

Nanda Raissa  
Pengembangan Aplikasi Berbasis Platform  
GitHub: https://github.com/nandaRssa
