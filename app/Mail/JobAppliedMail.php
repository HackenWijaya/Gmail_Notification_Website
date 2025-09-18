<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class JobAppliedMail extends Mailable
{
    use Queueable, SerializesModels;

    public $mailData;

    public function __construct($mailData)
    {
        $this->mailData = $mailData;
    }

    public function build()
    {
        return $this->subject('Notifikasi Lamaran Kerja')
            ->markdown('emails.job_applied')
            ->with([
                'name' => $this->mailData->name,
                'experience' => $this->mailData->experience,
                'education' => $this->mailData->education,
            ]);
    }
}
