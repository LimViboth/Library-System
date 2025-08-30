<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/books', [BookController::class, 'index']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);
    
    Route::apiResource('books', BookController::class)->except(['index']);
    Route::post('/books/{book}/borrow', [BookController::class, 'borrow']);
    Route::post('/books/{book}/return', [BookController::class, 'return']);
    Route::get('/my-books', [BookController::class, 'myBooks']);
});

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');