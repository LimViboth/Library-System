<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Book extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'author',
        'isbn',
        'description',
        'publication_year',
        'genre',
        'is_available',
        'user_id',
        'borrowed_at',
        'due_date',
    ];

    protected $casts = [
        'is_available' => 'boolean',
        'borrowed_at' => 'datetime',
        'due_date' => 'datetime',
        'publication_year' => 'integer',
    ];

   
    public function borrower()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
