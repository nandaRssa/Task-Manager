# TaskiFlow 📋

Aplikasi manajemen tugas berbasis Flutter yang terhubung dengan REST API Node.js + SQLite, dilengkapi autentikasi JWT, state management Provider, dan arsitektur berlapis (Layered Architecture).

> **Tugas 2 Individu — Pengembangan Aplikasi Berbasis Platform**  
> Topik: Implementasi Teknik Pengembangan pada Platform Web & Mobile

---

## 🏗️ Arsitektur Proyek

```
UTS-PABP/
├── backend/          # REST API (Node.js + Express + SQLite)
├── frontend/         # Web frontend (HTML/JS) — hasil UTS
└── taskiflow/        # Aplikasi mobile Flutter
```

---

## 🔧 Backend — REST API

Stack: **Node.js**, **Express.js**, **SQLite (better-sqlite3)**, **JWT**

### Fitur
- Autentikasi dengan JWT (Register, Login, Auto-refresh token via `flutter_secure_storage`)
- CRUD Task lengkap (Create, Read, Update, Delete)
- Middleware otorisasi — setiap endpoint task dilindungi token
- CORS support untuk akses dari Flutter/Web
- Health-check endpoint `/health`

### Endpoint Utama

| Method | Endpoint           | Deskripsi                  | Auth |
|--------|--------------------|----------------------------|------|
| POST   | `/auth/register`   | Daftar akun baru           | ❌   |
| POST   | `/auth/login`      | Login, dapat JWT token     | ❌   |
| GET    | `/tasks`           | Ambil semua task milik user | ✅  |
| POST   | `/tasks`           | Buat task baru             | ✅   |
| GET    | `/tasks/:id`       | Detail satu task           | ✅   |
| PUT    | `/tasks/:id`       | Edit task                  | ✅   |
| DELETE | `/tasks/:id`       | Hapus task                 | ✅   |

### Cara Menjalankan Backend

```bash
cd backend
npm install
cp .env.example .env   # sesuaikan JWT_SECRET dan PORT
npm start
```

Server berjalan di `http://localhost:5000` (default).

---

## 📱 TaskiFlow — Aplikasi Flutter

### Tech Stack
| Dependency              | Fungsi                              |
|-------------------------|-------------------------------------|
| `provider ^6.1.2`       | State management reaktif            |
| `http ^1.2.1`           | HTTP client untuk REST API          |
| `flutter_secure_storage`| Penyimpanan JWT token yang aman     |
| `google_fonts`          | Tipografi modern (Inter)            |
| `shimmer`               | Loading skeleton UI                 |
| `intl`                  | Format tanggal & waktu              |
| `gap`                   | Spacing utility                     |

### Struktur Layered Architecture

```
taskiflow/lib/
├── main.dart                   # Entry point, setup MultiProvider
├── app.dart                    # MaterialApp, ThemeData, routing
│
├── core/                       # Utility & konfigurasi global
│   ├── constants/              # AppConstants (base URL, dll)
│   ├── errors/                 # Exception classes
│   ├── network/                # HTTP client wrapper
│   ├── storage/                # SecureStorage wrapper
│   └── utils/                  # Validators, helpers
│
├── features/
│   ├── auth/                   # Fitur autentikasi
│   │   ├── models/             # UserModel (fromJson/toJson)
│   │   ├── services/           # AuthService (HTTP calls)
│   │   ├── providers/          # AuthProvider (state management)
│   │   └── screens/           # LoginScreen, RegisterScreen
│   │
│   └── tasks/                  # Fitur manajemen tugas
│       ├── models/             # TaskModel
│       ├── services/           # TaskService (HTTP + auth header)
│       ├── providers/          # TaskProvider (three-state UI)
│       └── screens/           # TaskList, Detail, Create, Edit
│
└── shared/
    └── widgets/                # AppButton, AppTextField, AppSnackbar
```

### Fitur Aplikasi

#### Wajib ✅
- **JWT Authentication** — Login/Register, token disimpan di `SecureStorage`, dikirim di setiap request (`Authorization: Bearer <token>`)
- **Three-state UI** — Loading (Shimmer skeleton), Error (pesan + retry button), Data berhasil ditampilkan
- **Provider State Management** — `AuthProvider` + `TaskProvider` reaktif
- **Navigasi antar halaman** — Named routes dengan slide transition animasi

#### Tambahan ✅
- **CRUD Lengkap** — Tambah, edit, hapus task langsung via API
- **Animasi** — Fade + slide pada login screen, slide transition antar halaman
- **Filter & Search** — Filter task berdasarkan status (All/Pending/Completed)
- **Dark Mode** — Otomatis mengikuti tema sistem
- **Splash Screen** — Auto-login saat app dibuka, tidak ada flash ke login jika sudah punya sesi

### Cara Menjalankan Flutter App

```bash
cd taskiflow
flutter pub get
flutter run
```

> Pastikan backend sudah berjalan dan `base_url` di `core/constants/` sudah disesuaikan dengan IP LAN atau localhost.

---

## 🔐 Alur JWT Authentication

```
User ──► LoginScreen ──► AuthService.login() ──► POST /auth/login
                                                       │
                                              ◄── { token, user }
                                                       │
                                        SecureStorage.write(token)
                                                       │
                                        AuthProvider → status: authenticated
                                                       │
                                              Navigator → /home (TaskListScreen)
                                                       │
                    setiap request Task ──► header: Authorization: Bearer <token>
```

---

## 📸 Screenshots

> Jalankan aplikasi dan lihat tampilan modern dengan dark mode support, shimmer loading, dan animasi halus.

---

## 👤 Author

**Nanda Raissa** — Pengembangan Aplikasi Berbasis Platform  
GitHub: [@nandaRssa](https://github.com/nandaRssa)
