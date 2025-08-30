<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Book;
use Illuminate\Http\Request;
use Carbon\Carbon;

class BookController extends Controller
{
    
    public function index(Request $request)
    {
        $query = Book::with('borrower');
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('title', 'like', '%' . $search . '%')
                  ->orWhere('author', 'like', '%' . $search . '%')
                  ->orWhere('isbn', 'like', '%' . $search . '%')
                  ->orWhere('genre', 'like', '%' . $search . '%');
            });
        }
        if ($request->has('available')) {
            $query->where('is_available', $request->available);
        }
        if ($request->has('genre')) {
            $query->where('genre', $request->genre);
        }

        $books = $query->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $books
        ]);
    }
    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'author' => 'required|string|max:255',
            'isbn' => 'required|string|unique:books',
            'description' => 'nullable|string',
            'publication_year' => 'nullable|integer|min:1000|max:' . (date('Y') + 1),
            'genre' => 'nullable|string|max:255',
        ]);

        $book = Book::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Book created successfully',
            'data' => $book
        ], 201);
    }

    /**
     * Display the specified book
     */
    public function show(Book $book)
    {
        return response()->json([
            'success' => true,
            'data' => $book->load('borrower')
        ]);
    }

    /**
     * Update the specified book
     */
    public function update(Request $request, Book $book)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'author' => 'required|string|max:255',
            'isbn' => 'required|string|unique:books,isbn,' . $book->id,
            'description' => 'nullable|string',
            'publication_year' => 'nullable|integer|min:1000|max:' . (date('Y') + 1),
            'genre' => 'nullable|string|max:255',
        ]);

        $book->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Book updated successfully',
            'data' => $book
        ]);
    }

    /**
     * Remove the specified book
     */
    public function destroy(Book $book)
    {
        if (!$book->is_available) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete a borrowed book'
            ], 400);
        }

        $book->delete();

        return response()->json([
            'success' => true,
            'message' => 'Book deleted successfully'
        ]);
    }

    /**
     * Borrow a book
     */
    public function borrow(Request $request, Book $book)
    {
        if (!$book->is_available) {
            return response()->json([
                'success' => false,
                'message' => 'Book is not available for borrowing'
            ], 400);
        }

        $book->update([
            'is_available' => false,
            'user_id' => $request->user()->id,
            'borrowed_at' => Carbon::now(),
            'due_date' => Carbon::now()->addDays(14), // 2 weeks borrowing period
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Book borrowed successfully',
            'data' => $book->load('borrower')
        ]);
    }

    /**
     * Return a borrowed book
     */
    public function return(Request $request, Book $book)
    {
        if ($book->is_available) {
            return response()->json([
                'success' => false,
                'message' => 'Book is not currently borrowed'
            ], 400);
        }

        if ($book->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'You can only return books you have borrowed'
            ], 403);
        }

        $book->update([
            'is_available' => true,
            'user_id' => null,
            'borrowed_at' => null,
            'due_date' => null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Book returned successfully',
            'data' => $book
        ]);
    }

    /**
     * Get user's borrowed books
     */
    public function myBooks(Request $request)
    {
        $books = Book::where('user_id', $request->user()->id)
                    ->where('is_available', false)
                    ->get();

        return response()->json([
            'success' => true,
            'data' => $books
        ]);
    }
}
