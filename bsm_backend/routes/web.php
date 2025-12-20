<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Response;

// routes/web.php
Route::match(['GET', 'OPTIONS'], '/media/{path}', function ($path) {
    $file = storage_path('app/public/' . $path);

    if (!File::exists($file)) {
        abort(404);
    }

    return Response::make(File::get($file), 200, [
        'Content-Type' => File::mimeType($file),
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, OPTIONS',
        'Access-Control-Allow-Headers' => '*',
        'Cache-Control' => 'public, max-age=86400',
    ]);
})->where('path', '.*');
