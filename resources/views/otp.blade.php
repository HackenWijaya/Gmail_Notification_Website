@extends('layouts.app')

@section('title', 'Kode OTP')

@section('content')
<div class="max-w-md mx-auto">
    <!-- OTP Display Card -->
    <div class="bg-dark-800 rounded-xl p-8 shadow-2xl border border-dark-700 text-center">
        <!-- Header -->
        <div class="mb-8">
            <div class="bg-gradient-to-r from-indigo-600 to-purple-600 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6">
                <svg class="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                </svg>
            </div>
            <h2 class="text-2xl font-bold text-gray-100 mb-2">Kode OTP Anda</h2>
            <p class="text-gray-400">Gunakan kode ini untuk verifikasi</p>
        </div>

        <!-- OTP Code Display -->
        <div class="bg-gradient-to-r from-indigo-600 to-purple-600 rounded-xl p-6 mb-6">
            <div class="text-4xl font-bold text-white tracking-widest mb-2">{{ $otp }}</div>
            <div class="text-indigo-200 text-sm">Kode Verifikasi</div>
        </div>

        <!-- Warning Message -->
        <div class="bg-yellow-900/30 border border-yellow-500/50 rounded-lg p-4 mb-6">
            <div class="flex items-start">
                <svg class="w-5 h-5 text-yellow-400 mr-3 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path>
                </svg>
                <div class="text-left">
                    <p class="text-yellow-100 font-semibold text-sm">Penting!</p>
                    <p class="text-yellow-200 text-sm mt-1">Kode ini berlaku selama 5 menit. Jangan bagikan kode ini kepada siapapun.</p>
                </div>
            </div>
        </div>

        <!-- Security Tips -->
        <div class="text-left">
            <h3 class="text-gray-300 font-semibold mb-3">Tips Keamanan:</h3>
            <ul class="text-gray-400 text-sm space-y-2">
                <li class="flex items-start">
                    <svg class="w-4 h-4 text-green-400 mr-2 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                    </svg>
                    Jangan pernah membagikan kode OTP kepada orang lain
                </li>
                <li class="flex items-start">
                    <svg class="w-4 h-4 text-green-400 mr-2 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                    </svg>
                    Kode akan otomatis expired setelah 5 menit
                </li>
                <li class="flex items-start">
                    <svg class="w-4 h-4 text-green-400 mr-2 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                    </svg>
                    Jika tidak menerima kode, periksa folder spam
                </li>
            </ul>
        </div>
    </div>
</div>
@endsection