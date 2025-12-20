<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MembershipTypeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('membership_types')->insert([
    [
        'name' => 'blue',
        'display_name' => 'BSM CARD BLUE',
        'duration_months' => 6,
        'benefits' => json_encode([
            'Free service 6 bulan di bengkel BSM / toko partner'
        ])
    ],
    [
        'name' => 'gold',
        'display_name' => 'BSM CARD GOLD',
        'duration_months' => 6,
        'benefits' => json_encode([
            'Free service 6 bulan di bengkel BSM / toko partner',
            'Free ongkos home service 6 bulan',
            'Diskon sparepart 10% selama 6 bulan'
        ])
    ],
    [
        'name' => 'platinum',
        'display_name' => 'BSM CARD PLATINUM',
        'duration_months' => 12,
        'benefits' => json_encode([
            'Free service 6 bulan di bengkel BSM / toko partner',
            'Free ongkos home service 6 bulan',
            'Diskon sparepart 10% selama 12 bulan',
            'Rusak ganti baru selama 3 bulan karena bencana alam'
        ])
    ],
]);
    }
}
