<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Mail; // pastikan model Mail ada
use Illuminate\Support\Facades\Auth;
use App\Jobs\SendJobMail;

class JobController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'experience' => 'required|string',
            'education' => 'required|string',
        ]);

        $mail = Mail::create([
            'user_id' => Auth::id(),
            'name' => $request->name,
            'email' => Auth::user()->email,
            'experience' => $request->experience,
            'education' => $request->education,
        ]);

        // Dispatch ke queue, kirim email notifikasi
        SendJobMail::dispatch($mail);

        return redirect()->back()->with('success', 'Lamaran berhasil diajukan! Cek email Anda untuk notifikasi.');
    }
}
