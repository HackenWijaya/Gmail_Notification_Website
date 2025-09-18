@extends('layouts.app')

@section('title', 'Send Email Demo')

@section('content')
<div class="max-w-md mx-auto">
    <!-- Send Email Card -->
    <div class="bg-dark-800 rounded-xl p-8 shadow-2xl border border-dark-700">
        <!-- Header -->
        <div class="text-center mb-8">
            <div class="bg-gradient-to-r from-teal-600 to-cyan-600 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                </svg>
            </div>
            <h2 class="text-2xl font-bold text-gray-100">Email Demo</h2>
            <p class="text-gray-400 mt-2">Kirim email demo untuk testing</p>
        </div>

        <!-- Send Email Form -->
        <form method="POST" action="/send-email" class="space-y-6">
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
                        class="w-full bg-dark-700 border border-dark-600 rounded-lg pl-10 pr-4 py-3 text-gray-100 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent transition-all duration-200"
                        placeholder="Enter recipient email" required>
                </div>
            </div>

            <!-- Send Button -->
            <button type="submit"
                class="w-full bg-gradient-to-r from-teal-600 to-cyan-600 hover:from-teal-700 hover:to-cyan-700 text-white font-semibold py-3 px-6 rounded-lg shadow-lg transform hover:scale-105 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2 focus:ring-offset-dark-800">
                <span class="flex items-center justify-center">
                    <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"></path>
                    </svg>
                    Send Email
                </span>
            </button>
        </form>

        <!-- Info Section -->
        <div class="mt-8 bg-blue-900/30 border border-blue-500/50 rounded-lg p-4">
            <div class="flex items-start">
                <svg class="w-5 h-5 text-blue-400 mr-3 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path>
                </svg>
                <div class="text-left">
                    <p class="text-blue-100 font-semibold text-sm">Info:</p>
                    <p class="text-blue-200 text-sm mt-1">Email ini akan dikirim menggunakan Laravel Queue untuk testing sistem email.</p>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection