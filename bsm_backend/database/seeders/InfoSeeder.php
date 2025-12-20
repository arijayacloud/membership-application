<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Info;
use Illuminate\Support\Facades\DB;

class InfoSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('infos')->truncate(); // kosongkan dulu (opsional)

        DB::table('infos')->insert([
            'clinic_name' => 'BSM Clinic Center',
            'address' => 'Jl. Sudirman No. 45, Jakarta',
            'operational_hours' => 'Senin - Sabtu: 08.00 - 20.00',
            'phone' => '0812-3456-7890',

            'description' => 'BSM Clinic Center menyediakan layanan kesehatan terbaik dengan dokter profesional dan fasilitas lengkap.',
            
            'services' => json_encode([
                'Cek Kesehatan Umum',
                'Konsultasi Dokter',
                'Fisioterapi',
                'Home Service',
            ]),

            'facilities' => json_encode([
                'Ruang Tunggu Nyaman',
                'WiFi Gratis',
                'Parkir Luas',
                'Ruang Periksa Modern',
            ]),

            'maps_url' => 'https://maps.google.com/123456',
            'instagram' => 'https://instagram.com/bsmclinic',
            'website' => 'https://bsmclinic.id',

            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
