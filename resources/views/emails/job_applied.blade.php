@component('mail::message')
# Halo {{ $name }},

Lamaran kerja Anda sudah berhasil dikirim.

**Detail:**
- Experience: {{ $experience }}
- Education: {{ $education }}

Kami akan segera memproses lamaran Anda.

Terima kasih,<br>
{{ config('app.name') }}
@endcomponent