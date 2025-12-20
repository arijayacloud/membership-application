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
        Schema::table('infos', function (Blueprint $table) {
            $table->text('description')->nullable();
            $table->json('services')->nullable();
            $table->json('facilities')->nullable();
            $table->string('maps_url')->nullable();
            $table->string('instagram')->nullable();
            $table->string('website')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('infos', function (Blueprint $table) {
            $table->dropColumn([
                'description',
                'services',
                'facilities',
                'maps_url',
                'instagram',
                'website'
            ]);
        });
    }
};
