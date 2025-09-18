@extends('layouts.app')

@section('title', 'Forgot Password')

@section('content')
<div class="max-w-md mx-auto">
    <!-- Forgot Password Card -->
    <div class="bg-dark-800 rounded-xl p-8 shadow-2xl border border-dark-700">
        <!-- Header -->
        <div class="text-center mb-8">
            <div class="bg-gradient-to-r from-orange-600 to-red-600 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"></path>
                </svg>
            </div>
            <h2 class="text-2xl font-bold text-gray-100">Forgot Password</h2>
            <p class="text-gray-400 mt-2">Masukkan email Anda untuk menerima kode OTP</p>
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
                    @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        </div>
        @endif

        <!-- Forgot Password Form -->
        <form method="POST" action="{{ route('send.otp') }}" class="space-y-6">
            @csrf

            <!-- Email Field -->
            <div class="space-y-2">
                <label for="email" class="block text-sm font-semibold text-gray-300">Email Address</label>
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207"></path>
                        </svg>
                    </div>
                    <input type="email" name="email" id="email"
                        class="w-full bg-dark-700 border border-dark-600 rounded-lg pl-10 pr-4 py-3 text-gray-100 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent transition-all duration-200"
                        placeholder="Enter your email address"
                        value="{{ old('email') }}" required>
                </div>
                <p class="text-xs text-gray-500 mt-1">Kami akan mengirim kode OTP ke email ini</p>
            </div>

            <!-- Send OTP Button -->
            <button type="submit"
                class="w-full bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700 text-white font-semibold py-3 px-6 rounded-lg shadow-lg transform hover:scale-105 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-2 focus:ring-offset-dark-800">
                <span class="flex items-center justify-center">
                    <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                    </svg>
                    Kirim Kode OTP
                </span>
            </button>
        </form>

        <!-- Back to Login Link -->
        <div class="mt-8 text-center">
            <p class="text-gray-400">Ingat password Anda?</p>
            <a href="{{ route('login.form') }}"
                class="text-orange-400 hover:text-orange-300 hover:underline font-semibold transition-colors duration-200">
                ← Kembali ke Login
            </a>
        </div>

        <!-- Info Section -->
        <div class="mt-6 bg-blue-900/30 border border-blue-500/50 rounded-lg p-4">
            <div class="flex items-start">
                <svg class="w-5 h-5 text-blue-400 mr-3 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path>
                </svg>
                <div class="text-left">
                    <p class="text-blue-100 font-semibold text-sm">Info:</p>
                    <p class="text-blue-200 text-sm mt-1">Kode OTP akan dikirim ke email Anda dan berlaku selama 5 menit.</p>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection