<?php

namespace Database\Seeders;

use App\Models\Book;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class BookSeeder extends Seeder
{
    public function run(): void
    {
        $books = [
            [
                'title' => 'The Great Gatsby',
                'author' => 'F. Scott Fitzgerald',
                'isbn' => '9780743273565',
                'description' => 'A classic American novel set in the Jazz Age.',
                'publication_year' => 1925,
                'genre' => 'Classic Literature',
                'is_available' => true,
            ],
            [
                'title' => 'To Kill a Mockingbird',
                'author' => 'Harper Lee',
                'isbn' => '9780061120084',
                'description' => 'A gripping tale of racial injustice and childhood innocence.',
                'publication_year' => 1960,
                'genre' => 'Classic Literature',
                'is_available' => true,
            ],
            [
                'title' => '1984',
                'author' => 'George Orwell',
                'isbn' => '9780451524935',
                'description' => 'A dystopian social science fiction novel.',
                'publication_year' => 1949,
                'genre' => 'Science Fiction',
                'is_available' => true,
            ],
            [
                'title' => 'Pride and Prejudice',
                'author' => 'Jane Austen',
                'isbn' => '9780141439518',
                'description' => 'A romantic novel of manners.',
                'publication_year' => 1813,
                'genre' => 'Romance',
                'is_available' => true,
            ],
            [
                'title' => 'The Catcher in the Rye',
                'author' => 'J.D. Salinger',
                'isbn' => '9780316769174',
                'description' => 'A novel about teenage rebellion and alienation.',
                'publication_year' => 1951,
                'genre' => 'Classic Literature',
                'is_available' => true,
            ],
            [
                'title' => 'Harry Potter and the Philosopher\'s Stone',
                'author' => 'J.K. Rowling',
                'isbn' => '9780747532699',
                'description' => 'The first book in the Harry Potter series.',
                'publication_year' => 1997,
                'genre' => 'Fantasy',
                'is_available' => true,
            ],
            [
                'title' => 'The Lord of the Rings',
                'author' => 'J.R.R. Tolkien',
                'isbn' => '9780544003415',
                'description' => 'An epic high fantasy novel.',
                'publication_year' => 1954,
                'genre' => 'Fantasy',
                'is_available' => true,
            ],
            [
                'title' => 'Dune',
                'author' => 'Frank Herbert',
                'isbn' => '9780441172719',
                'description' => 'A science fiction novel set in the distant future.',
                'publication_year' => 1965,
                'genre' => 'Science Fiction',
                'is_available' => true,
            ]
        ];

        foreach ($books as $book) {
            Book::create($book);
        }
    }
}
