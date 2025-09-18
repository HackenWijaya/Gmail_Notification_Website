@extends('layouts.app')

@section('title', 'Dashboard')

@section('content')
<div class="max-w-4xl mx-auto">
    <!-- Header Section -->
    <div class="bg-gradient-to-r from-blue-600 to-purple-600 rounded-xl p-8 mb-8 shadow-2xl">
        <div class="flex flex-col lg:flex-row lg:justify-between lg:items-center space-y-4 lg:space-y-0">
            <div>
                <h1 class="text-3xl font-bold text-white mb-2">Halo, {{ Auth::user()->name }}! 👋</h1>
                <p class="text-blue-100 text-lg">Selamat datang di dashboard Job Applier Anda</p>
            </div>
            <!-- Logout Button -->
            <div class="flex items-center justify-between lg:justify-end space-x-4">
                <div class="text-right">
                    <p class="text-blue-100 text-sm">{{ Auth::user()->email }}</p>
                    <p class="text-blue-200 text-xs">Logged in</p>
                </div>
                <form action="{{ route('logout') }}" method="POST" class="inline">
                    @csrf
                    <button type="submit"
                        class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg shadow-lg transform hover:scale-105 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 focus:ring-offset-blue-600 flex items-center"
                        onclick="return confirm('Apakah Anda yakin ingin logout?')">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                        </svg>
                        Logout
                    </button>
                </form>
            </div>
        </div>
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

    <!-- Job Application Form -->
    <div class="bg-dark-800 rounded-xl p-8 shadow-2xl border border-dark-700">
        <div class="flex items-center mb-6">
            <div class="bg-blue-600 p-3 rounded-lg mr-4">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2-2v2m8 0V6a2 2 0 012 2v6a2 2 0 01-2 2H6a2 2 0 01-2-2V8a2 2 0 012-2V6"></path>
                </svg>
            </div>
            <h2 class="text-2xl font-bold text-gray-100">Apply Job</h2>
        </div>

        <form action="{{ route('job.apply') }}" method="POST" class="space-y-6">
            @csrf

            <!-- Nama Field -->
            <div class="space-y-2">
                <label class="block text-sm font-semibold text-gray-300">Nama Lengkap</label>
                <input type="text" name="name" value="{{ Auth::user()->name }}"
                    class="w-full bg-dark-700 border border-dark-600 rounded-lg px-4 py-3 text-gray-100 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                    required>
            </div>

            <!-- Hidden Email Field -->
            <input type="hidden" name="email" value="{{ Auth::user()->email }}">

            <!-- Experience Field -->
            <div class="space-y-2">
                <label class="block text-sm font-semibold text-gray-300">Pengalaman Kerja</label>
                <textarea name="experience" rows="4"
                    class="w-full bg-dark-700 border border-dark-600 rounded-lg px-4 py-3 text-gray-100 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 resize-none"
                    placeholder="Ceritakan pengalaman kerja Anda..." required></textarea>
            </div>

            <!-- Education Field -->
            <div class="space-y-2">
                <label class="block text-sm font-semibold text-gray-300">Pendidikan</label>
                <input type="text" name="education"
                    class="w-full bg-dark-700 border border-dark-600 rounded-lg px-4 py-3 text-gray-100 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                    placeholder="Contoh: S1 Teknik Informatika, Universitas ABC" required>
            </div>

            <!-- Submit Button -->
            <div class="pt-4">
                <button type="submit"
                    class="w-full bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white font-semibold py-3 px-6 rounded-lg shadow-lg transform hover:scale-105 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 focus:ring-offset-dark-800">
                    <span class="flex items-center justify-center">
                        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"></path>
                        </svg>
                        Submit Application
                    </span>
                </button>
            </div>
        </form>
    </div>
</div>
@endsection