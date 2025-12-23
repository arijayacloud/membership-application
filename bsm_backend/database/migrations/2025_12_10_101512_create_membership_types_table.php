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
        Schema::create('membership_types', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique(); // blue, gold, platinum
            $table->string('display_name'); // BSM CARD BLUE, GOLD, PLATINUM
            $table->integer('duration_months')->default(6); // sesuai benefit
            $table->json('benefits')->nullable(); // simpan semua benefit
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('membership_types');
    }
};
