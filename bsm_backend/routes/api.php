<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\MemberController;
use App\Http\Controllers\MembershipTypeController;
use App\Http\Controllers\HomeServiceController;
use App\Http\Controllers\PromoController;
use App\Http\Controllers\InfoController;
use Illuminate\Container\Attributes\Auth;

/*
|--------------------------------------------------------------------------
| PUBLIC ROUTES (Tanpa Login)
|--------------------------------------------------------------------------
*/

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/promo', [PromoController::class, 'index']);
Route::get('/promo/{id}', [PromoController::class, 'show']);

/*
|--------------------------------------------------------------------------
| PUBLIC IMAGE (CORS SAFE)
|--------------------------------------------------------------------------
*/
Route::get('/image/{path}', function ($path) {
    $file = storage_path("app/public/$path");

    if (!file_exists($file)) {
        abort(404);
    }

    return response()->file($file, [
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, OPTIONS',
    ]);
})->where('path', '.*');

/*
|--------------------------------------------------------------------------
| PROTECTED ROUTES (BUTUH LOGIN)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {

    Route::post('/logout', [AuthController::class, 'logout']);

    // MEMBER
    Route::get('/member/check', [MemberController::class, 'checkMember']);
    Route::post('/member/register', [MemberController::class, 'registerMember']);
    Route::put('/member/update-profile', [MemberController::class, 'updateProfile']);

    // 📌 USER - VIEW MEMBERSHIP TYPES
    Route::get('/membership-types', [MemberController::class, 'getMembershipTypes']);
    Route::get('/membership/me', [MembershipTypeController::class, 'myMembership']);
    Route::post('/membership/upgrade', [MembershipTypeController::class, 'upgrade']);
    Route::get('/member/profile', [AuthController::class, 'profile']);
    Route::get('/member/profile-member', [HomeServiceController::class, 'profile']);

    // HOME SERVICE
    Route::get('/home-service', [HomeServiceController::class, 'index']);
    Route::post('/home-service/request', [HomeServiceController::class, 'store']);
    Route::get('/home-service/my', [HomeServiceController::class, 'myRequests']);
    Route::get('/home-service/{id}', [HomeServiceController::class, 'show']);
    Route::post('/home-service/{id}/cancel', [HomeServiceController::class, 'cancel']);
    Route::get('/home-services/active', [HomeServiceController::class, 'active']);

    // INFO
    Route::get('/infos', [InfoController::class, 'index']);

    /*
    |--------------------------------------------------------------------------
    | ADMIN ROUTES (Role: admin only)
    |--------------------------------------------------------------------------
    */
    Route::middleware('admin')->group(function () {

        // MEMBERSHIP TYPE CRUD
        Route::get('/admin/membership-types', [MembershipTypeController::class, 'index']);
        Route::post('/admin/membership-types', [MembershipTypeController::class, 'store']);
        Route::put('/admin/membership-types/{id}', [MembershipTypeController::class, 'update']);
        Route::delete('/admin/membership-types/{id}', [MembershipTypeController::class, 'destroy']);

        // EXPORT & MANAGEMENT MEMBER
        Route::get('/admin/members/export', [MemberController::class, 'exportExcel']);
        Route::get('/admin/members', [MemberController::class, 'index']);
        Route::get('/admin/members/{id}', [MemberController::class, 'show']);
        Route::put('/admin/members/{id}', [MemberController::class, 'update']);
        Route::delete('/admin/members/{id}', [MemberController::class, 'destroy']);

        // PROMO ADMIN
        Route::get('/admin/promo', [PromoController::class, 'index']);
        Route::post('/admin/promo', [PromoController::class, 'store']);
        Route::put('/admin/promo/{id}', [PromoController::class, 'update']);
        Route::delete('/admin/promo/{id}', [PromoController::class, 'destroy']);

        // HOME SERVICE - ADMIN UPDATE STATUS
        Route::get('/admin/home-services', [HomeServiceController::class, 'index']);
        Route::patch('/admin/home-services/{id}/status', [HomeServiceController::class, 'updateStatus']);
        Route::post('/admin/home-services/{id}/finish', [HomeServiceController::class, 'finishWork']);

        //INFO ADMIN
        Route::get('/admin/info', [InfoController::class, 'index']);
        Route::post('/admin/info', [InfoController::class, 'store']);
        Route::get('/admin/info/{id}', [InfoController::class, 'show']);
        Route::put('/admin/info/{id}', [InfoController::class, 'update']);
        Route::delete('/admin/info/{id}', [InfoController::class, 'destroy']);

        Route::get('/admin/profile', [AuthController::class, 'profile']);
        Route::put('/admin/profile', [AuthController::class, 'updateProfile']);
    });
});
