<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\MemberController;
use App\Http\Controllers\HomeServiceController;
use App\Http\Controllers\PromoController;

/*
|--------------------------------------------------------------------------
| PUBLIC ROUTES
|--------------------------------------------------------------------------
*/

// 🔐 AUTH
Route::post('/register', [AuthController::class, 'register']); // user / admin (dengan secret)
Route::post('/login', [AuthController::class, 'login']);

// 📢 PROMO (user non login boleh lihat)
Route::get('/promo', [PromoController::class, 'index']);
Route::get('/promo/{id}', [PromoController::class, 'show']);



/*
|--------------------------------------------------------------------------
| PROTECTED ROUTES (BUTUH LOGIN)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {

    // 🔐 LOGOUT
    Route::post('/logout', [AuthController::class, 'logout']);

    /*
    |--------------------------------------------------------------------------
    | USER MENU
    |--------------------------------------------------------------------------
    */

    // 🆔 CEK & DAFTAR MEMBER
    Route::get('/member/check', [MemberController::class, 'checkMember']);
    Route::post('/member/register', [MemberController::class, 'registerMember']);

    // 🏥 HOME SERVICE (Hanya Member Bisa Request)
    Route::get('/home-service', [HomeServiceController::class, 'index']);
    Route::post('/home-service/request', [HomeServiceController::class, 'requestService']);
    Route::get('/home-service/{id}', [HomeServiceController::class, 'show']);
    Route::post('/home-service/{id}/cancel', [HomeServiceController::class, 'cancel']);

    /*
    |--------------------------------------------------------------------------
    | ADMIN ROUTES
    |--------------------------------------------------------------------------
    */
    Route::middleware('admin')->group(function () {

        // 🧾 EXPORT MEMBER EXCEL
        Route::get('/admin/member/export', [MemberController::class, 'exportExcel']);

        // 🛠 ADMIN UPDATE STATUS HOME SERVICE
        Route::post('/admin/home-service/{id}/status', [HomeServiceController::class, 'updateStatus']);

        // 📰 ADMIN CRUD PROMO
        Route::post('/admin/promo', [PromoController::class, 'store']);
        Route::post('/admin/promo/{id}', [PromoController::class, 'update']);
        Route::delete('/admin/promo/{id}', [PromoController::class, 'destroy']);
    });
});
