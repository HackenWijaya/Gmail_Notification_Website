@extends('layouts.app')

@section('title', 'Verifikasi OTP')

@section('content')
<div class="max-w-md mx-auto">
    <!-- OTP Verification Card -->
    <div class="bg-dark-800 rounded-xl p-8 shadow-2xl border border-dark-700">
        <!-- Header -->
        <div class="text-center mb-8">
            <div class="bg-gradient-to-r from-yellow-600 to-orange-600 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                </svg>
            </div>
            <h2 class="text-2xl font-bold text-gray-100">Verifikasi OTP</h2>
            <p class="text-gray-400 mt-2">Masukkan kode OTP yang dikirim ke email Anda</p>
        </div>

        @if(session('success'))
        <div class="mb-6 bg-green-900/50 border border-green-500 text-green-100 px-4 py-3 rounded-lg shadow-lg">
            <div class="flex items-center">
                <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                </svg>
                {{ session('success') }}
            </div>
        </div>
        @endif

        @if($errors->any())
        <div class="mb-6 bg-red-900/50 border border-red-500 text-red-100 px-4 py-3 rounded-lg shadow-lg">
            <div class="flex items-start">
                <svg class="w-5 h-5 mr-2 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
                </svg>
                <ul class="space-y-1">
                    @foreach($errors->all() as $err)
                    <li>{{ $err }}</li>
                    @endforeach
                </ul>
            </div>
        </div>
        @endif

        <!-- OTP Form -->
        <form action="{{ route('verify.otp') }}" method="POST" class="space-y-6">
            @csrf
            <input type="hidden" name="email" value="{{ old('email', request('email')) }}">

            <!-- OTP Field -->
            <div class="space-y-2">
                <label for="otp" class="block text-sm font-semibold text-gray-300">Kode OTP</label>
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                        </svg>
                    </div>
                    <input type="text" name="otp" id="otp"
                        class="w-full bg-dark-700 border border-dark-600 rounded-lg pl-10 pr-4 py-3 text-gray-100 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:border-transparent transition-all duration-200 text-center text-lg tracking-widest"
                        placeholder="000000"
                        maxlength="6"
                        pattern="[0-9]{6}"
                        required>
                </div>
                <p class="text-xs text-gray-500 mt-1">Masukkan 6 digit kode OTP yang dikirim ke email Anda</p>
            </div>

            <!-- Verify Button -->
            <button type="submit"
                class="w-full bg-gradient-to-r from-yellow-600 to-orange-600 hover:from-yellow-700 hover:to-orange-700 text-white font-semibold py-3 px-6 rounded-lg shadow-lg transform hover:scale-105 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:ring-offset-2 focus:ring-offset-dark-800">
                <span class="flex items-center justify-center">
                    <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                    Verifikasi OTP
                </span>
            </button>
        </form>

        <!-- Resend OTP Link -->
        <div class="mt-6 text-center">
            <p class="text-gray-400 text-sm">Tidak menerima kode?</p>
            <a href="{{ route('register') }}"
                class="text-yellow-400 hover:text-yellow-300 hover:underline font-semibold transition-colors duration-200">
                Kirim ulang OTP
            </a>
        </div>
    </div>
</div>
@endsection