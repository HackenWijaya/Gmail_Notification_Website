## JobApplier – Dokumentasi Backend

Aplikasi Laravel untuk autentikasi dengan OTP, reset password, dan pengiriman email antrian (queue) untuk notifikasi lamaran kerja.

### Cara Menjalankan

1. Salin env dan set kredensial dasar
```bash
cp .env.example .env
php artisan key:generate
```
2. Konfigurasi database dan mailer di `.env` (lihat bagian Konfigurasi).
3. Jalankan migrasi
```bash
php artisan migrate
```
4. Jalankan server
```bash
php artisan serve
```
5. (Opsional) Jalankan worker queue untuk email
```bash
php artisan queue:work
```

---

## Arsitektur & Alur Utama

- Login/Register → Dashboard
- Lupa password: input email → kirim OTP (queue) → verifikasi OTP → reset password
- Apply job di Dashboard → kirim email notifikasi (queue)

---

## Direktori Backend dan Penjelasan File

### 1) Controllers (`app/Http/Controllers`)

- `Controller.php`
  - Base controller Laravel, tempat mewarisi middleware/trait umum.

- `AuthController.php`
  - `showLoginForm()`/`login()`
    - Render form login dan proses autentikasi via `Auth::attempt()`; regenerate session, redirect ke `dashboard`.
  - `showRegisterForm()`/`register()`
    - Render form register, validasi, buat `User`, langsung login dan redirect ke `dashboard`.
  - `showForgotForm()`
    - Tampilkan form input email (`resources/views/auth/forgot.blade.php`) untuk meminta OTP.
  - `sendOtp(Request)`
    - Validasi email, generate OTP 6 digit dengan masa berlaku 5 menit, simpan ke kolom `otp` dan `otp_expires_at` di `users`.
    - Dispatch `SendDemoMail` untuk mengirim email OTP secara async (queue).
  - `showVerifyOtpForm(Request)` / `verifyOtp(Request)`
    - Tampilkan form OTP dan verifikasi OTP+expire. Jika valid, simpan `reset_email` di session dan redirect ke halaman reset password.
  - `resetPassword(Request)`
    - Validasi password+konfirmasi, update password user berdasarkan `reset_email` session, redirect ke login.
  - `logout(Request)`
    - Logout, invalidate session, regenerate token, redirect ke `login.form`.
  - `showDashboard()`
    - Render `resources/views/dashboard.blade.php` (butuh auth middleware).

- `JobController.php`
  - `store(Request)`
    - Validasi data lamaran dari dashboard, simpan ke tabel `mail` melalui model `App\Models\Mail`.
    - Dispatch `SendJobMail` untuk mengirim email notifikasi lamaran kepada user.

### 2) Models (`app/Models`)

- `User.php`
  - Model autentikasi standar Laravel.
  - Cast `otp_expires_at` ke `datetime` dan `password` ke `hashed`.

- `Mail.php`
  - Menyimpan data lamaran kerja (tabel: `mail`).
  - `fillable`: `user_id`, `name`, `email`, `experience`, `education`.

### 3) Jobs (`app/Jobs`)

- `SendDemoMail`
  - Implements `ShouldQueue`. Menerima `$email` dan `$otp` dari controller.
  - `handle()` mengirim `App\Mail\OtpMail` ke alamat email target.

- `SendJobMail`
  - Implements `ShouldQueue`. Menerima `$mailData` (record lamaran).
  - `handle()` mengirim `App\Mail\JobAppliedMail` ke email pelamar.

### 4) Mailables (`app/Mail`)

- `OtpMail`
  - Subject: "Kode OTP Anda".
  - View: `resources/views/otp.blade.php` (menampilkan kode OTP).

- `JobAppliedMail`
  - Subject: "Notifikasi Lamaran Kerja".
  - Markdown view: `resources/views/emails/job_applied.blade.php` dengan variabel `name`, `experience`, `education`.

- `DemoMail`
  - Contoh mailable sederhana yang merender `resources/views/emails/demo.blade.php`.

### 5) Routes (`routes/web.php`)

- Auth
  - `GET /login` → `AuthController@showLoginForm` (name: `login.form`)
  - `POST /login` → `AuthController@login` (name: `login`)
  - `GET /register` → `AuthController@showRegisterForm` (name: `register.form`)
  - `POST /register` → `AuthController@register` (name: `register`)
  - `POST /logout` → `AuthController@logout` (name: `logout`)

- Forgot Password (OTP Flow)
  - `GET /forgot-password` → Form input email (name: `forgot.form`)
  - `POST /forgot-password` → Kirim OTP (name: `send.otp`)
  - `GET /verify-otp` → Form OTP (name: `verify.otp.form`)
  - `POST /verify-otp` → Verifikasi OTP (name: `verify.otp`)
  - `GET /password/reset` → View reset password `auth.reset-password` (name: `password.reset.form`)
  - `POST /password/reset` → Simpan password baru (name: `password.reset.submit`)

- Dashboard & Jobs
  - `GET /dashboard` → `AuthController@showDashboard` (middleware: `auth`, name: `dashboard`)
  - `POST /job/apply` → `JobController@store` (name: `job.apply`)

- Root Redirect
  - `GET /` → redirect ke `dashboard` jika sudah login, selain itu ke `login.form`.

### 6) Migrations (`database/migrations`)

- `0001_01_01_000000_create_users_table.php`
  - Tabel `users` standar (name, email, password, dll.).

- `0001_01_01_000001_create_cache_table.php`
  - Tabel cache bawaan Laravel.

- `0001_01_01_000002_create_jobs_table.php`
  - Tabel untuk menyimpan antrian jobs (queues) jika memakai driver database.

- `2025_09_16_012444_add_otp_to_users_table.php`
  - Menambah kolom `otp` dan `otp_expires_at` pada tabel `users` untuk verifikasi OTP.

### 7) Konfigurasi Mail (`config/mail.php`)

- Default mailer: `MAIL_MAILER` (default `log`).
- Konfigurasi `smtp`/`log`/lainnya dapat diatur melalui `.env`.
- Alamat pengirim global: `MAIL_FROM_ADDRESS`, `MAIL_FROM_NAME`.

Contoh `.env` minimal untuk smtp (sesuaikan):
```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your@gmail.com
MAIL_PASSWORD=your-app-password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=your@gmail.com
MAIL_FROM_NAME="JobApplier"
```

### 8) Views (Ringkas Backend-Relevant)

- `resources/views/otp.blade.php`
  - Digunakan oleh `OtpMail` untuk menampilkan kode OTP di email.

- `resources/views/emails/job_applied.blade.php`
  - Template markdown email notifikasi lamaran.

---

## Alur Lupa Password (Detail)

1. `GET /forgot-password` → View `auth/forgot` (input email)
2. `POST /forgot-password` → `sendOtp()`
   - Generate OTP, simpan ke user, dispatch `SendDemoMail` (email OTP)
3. `GET /verify-otp` → View `auth/verify-otp`
4. `POST /verify-otp` → `verifyOtp()`
   - Validasi OTP & kadaluarsa, set `reset_email` di session
5. `GET /password/reset` → View `auth/reset-password`
6. `POST /password/reset` → `resetPassword()`

---

## Menjalankan Queue

- Pastikan driver queue sesuai (mis. database) dan migrasi `jobs` sudah jalan.
- Jalankan worker:
```bash
php artisan queue:work
```

---

## Catatan Keamanan

- OTP berlaku 5 menit (`otp_expires_at`).
- Session direset saat logout.
- Password di-hash oleh Laravel.

---

## Supervisor (Opsional – Untuk Queue Otomatis)

Jika Anda tidak ingin selalu menjalankan `php artisan queue:work` manual, gunakan **Supervisor**. Supervisor akan otomatis menjalankan worker Laravel dan dapat mengelola beberapa queue sekaligus.

### Konfigurasi Supervisor

File konfigurasi biasanya di:
docker/supervisor/queue.conf
Contoh konfigurasi:
```ini
[program:laravel-queue]
process_name=%(program_name)s_%(process_num)02d
command=php /mnt/d/jobapplier/artisan queue:work --sleep=3 --tries=3
autostart=true
autorestart=true
numprocs=1
user=www-data
redirect_stderr=true
stdout_logfile=/mnt/d/jobapplier/storage/logs/queue.log
stopwaitsecs=3600
```

### Menjalankan Supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start laravel-queue:*

## Lisensi

Proyek ini berada di atas kerangka kerja Laravel (MIT). Konten aplikasi spesifik lisensinya mengikuti preferensi pemilik repositori.
