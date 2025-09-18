<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Mail;
use App\Models\User;
use App\Jobs\SendDemoMail; // job untuk kirim OTP via email
use App\Mail\OtpMail;

class AuthController extends Controller
{
    public function showLoginForm()
    {
        return view('auth.login');
    }

    public function showRegisterForm()
    {
        return view('auth.register');
    }

    public function showForgotForm()
    {
        return view('auth.forgot');
    }

    public function showVerifyOtpForm(Request $request)
    {
        // bisa bawa data email via query string atau session
        return view('auth.verify-otp', ['email' => $request->email ?? null]);
    }

    public function register(Request $request)
    {
        $request->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|email|unique:users,email',
            'password' => 'required|string|min:6|confirmed',
        ]);

        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => bcrypt($request->password),
        ]);

        // bisa langsung login setelah register atau redirect ke login
        Auth::login($user);

        return redirect()->route('dashboard')->with('success', 'Registrasi berhasil!');
    }

    public function login(Request $request)
    {
        $credentials = $request->only('email', 'password');

        if (Auth::attempt($credentials)) {
            $request->session()->regenerate();
            return redirect()->route('dashboard')->with('success', 'Login berhasil!');
        }

        return back()->withErrors(['email' => 'Email atau password salah']);
    }

    public function sendOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:users,email',
        ]);

        $user = User::where('email', $request->email)->first();
        $otp = rand(100000, 999999);  // OTP angka
        $user->otp = $otp;
        $user->otp_expires_at = now()->addMinutes(5);
        $user->save();

        // dispatch job dengan email + otp
        SendDemoMail::dispatch($user->email, $otp);

        return redirect()->route('verify.otp.form', ['email' => $user->email])
            ->with('success', 'OTP telah dikirim ke email!');
    }

    public function verifyOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:users,email',
            'otp'   => 'required|numeric',
        ]);

        $user = User::where([
            ['email', $request->email],
            ['otp', $request->otp],
        ])->first();

        if (!$user) {
            return redirect()->back()->withErrors(['otp' => 'OTP salah']);
        }

        if ($user->otp_expires_at->isPast()) {
            return redirect()->back()->withErrors(['otp' => 'OTP sudah kadaluarsa']);
        }

        // clear otp
        $user->otp = null;
        $user->otp_expires_at = null;
        $user->save();

        // simpan email user di session agar bisa dipakai di form reset password
        session(['reset_email' => $user->email]);

        // arahkan ke halaman reset password
        return redirect()->route('password.reset.form')
            ->with('success', 'OTP berhasil diverifikasi, silakan atur ulang password Anda.');
    }
    public function resetPassword(Request $request)
    {
        $request->validate([
            'password' => 'required|min:6|confirmed',
            'email' => 'required|email|exists:users,email',
        ]);

        $user = User::where('email', $request->email)->first();
        $user->password = bcrypt($request->password);
        $user->save();

        return redirect()->route('login')
            ->with('success', 'Password berhasil direset, silakan login.');
    }


    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('login.form');
    }

    public function showDashboard()
    {
        return view('dashboard');
    }
}
