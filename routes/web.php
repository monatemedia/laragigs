<?php

use App\Models\Listing;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ListingController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

// Common Resource Routes: https:
// index - Show all listings
// show - Show a single listing
// create - Show form to create a new listing
// store - Store new listing
// edit - Show form to edit an existing listing
// update - Update an existing listing
// destroy - Destroy/delete an existing listing

//All Listings
Route::get('/', [ListingController::class, 'index']);

// Show Create Form
Route::get('/listings/create', [ListingController::class, 'create']);

// Store Listing Data
Route::post('/listings', [ListingController::class, 'store']);

//Single Listing
Route:: get('/listings/{listing}', [ListingController::class, 'show']);