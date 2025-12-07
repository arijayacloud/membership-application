<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::create('home_services', function (Blueprint $table) {
            $table->id();

            $table->unsignedBigInteger('user_id')->nullable();
            $table->unsignedBigInteger('member_id')->nullable(); // jika wajib member

            $table->string('service_type');

            $table->date('schedule_date');
            $table->time('schedule_time');

            $table->text('address'); // agar bisa detail
            $table->text('note')->nullable();

            $table->enum('status', [
                'pending',        // request masuk
                'approved',       // sudah disetujui admin
                'on_progress',    // tenaga medis OTW / proses
                'done',           // selesai
                'canceled'        // dibatalkan (lebih baku)
            ])->default('pending');

            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('set null');
            $table->foreign('member_id')->references('id')->on('members')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('home_services');
    }
};
