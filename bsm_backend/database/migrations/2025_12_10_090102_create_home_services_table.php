<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('home_services', function (Blueprint $table) {
            $table->id();

            // USER & MEMBER
            $table->unsignedBigInteger('user_id')->nullable();
            $table->unsignedBigInteger('member_id')->nullable();

            // INFORMASI KENDARAAN
            $table->string('vehicle_type')->nullable();
            $table->string('vehicle_brand')->nullable();
            $table->string('vehicle_model')->nullable();
            $table->string('vehicle_serial_number')->nullable();

            // JENIS PERBAIKAN
            $table->string('service_type');

            // JADWAL
            $table->date('schedule_date');
            $table->time('schedule_time');

            // LOKASI
            $table->text('address');
            $table->string('city')->nullable();

            // DETAIL KELUHAN
            $table->text('problem_description')->nullable();
            $table->string('problem_photo')->nullable();

            // STATUS PERBAIKAN
            $table->enum('status', [
                'pending',
                'approved',
                'on_progress',
                'waiting_parts',
                'done',
                'canceled'
            ])->default('pending');

            // HASIL PENGERJAAN
            $table->text('work_notes')->nullable();
            $table->string('completion_photo')->nullable();

            $table->timestamps();

            // RELASI
            $table->foreign('user_id')->references('id')->on('users')->onDelete('set null');
            $table->foreign('member_id')->references('id')->on('members')->onDelete('set null');
        });
    }

    public function down()
    {
        Schema::dropIfExists('home_services');
    }
};
