<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('members', function (Blueprint $table) {
            $table->id();

            // Identitas Member
            $table->string('member_code')->unique();
            $table->string('name');
            $table->string('phone')->unique();
            $table->string('email')->nullable();

            // Membership Type (Blue, Gold, Platinum)
            $table->enum('membership_type', ['blue', 'gold', 'platinum'])
                  ->default('blue');

            // Masa aktif membership
            $table->date('join_date')->nullable();
            $table->date('expired_at')->nullable();

            // Informasi Kendaraan
            $table->string('vehicle_type')->nullable(); // sepeda listrik / motor listrik
            $table->string('vehicle_brand')->nullable();
            $table->string('vehicle_model')->nullable();
            $table->string('vehicle_serial_number')->nullable();

            // Untuk kebutuhan Home Service
            $table->text('address')->nullable();
            $table->string('city')->nullable();

            // Status Member
            $table->enum('status', ['active', 'non_active', 'expired', 'pending'])
                  ->default('active');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('members');
    }
};
