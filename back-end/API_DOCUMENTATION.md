# Library System API Documentation

## Base URL
```
http://127.0.0.1:8000/api
```

## Authentication
This API uses Laravel Sanctum for authentication. After successful login/registration, you'll receive a token that should be included in the Authorization header for protected routes.

**Header Format:**
```
Authorization: Bearer YOUR_TOKEN_HERE
```

---

## Authentication Endpoints

### 1. Register User
**POST** `/register`

**Body:**
```json
{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123"
}
```

**Response (201):**
```json
{
    "success": true,
    "message": "User registered successfully",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "email_verified_at": null,
            "created_at": "2025-08-24T09:53:25.000000Z",
            "updated_at": "2025-08-24T09:53:25.000000Z"
        },
        "token": "1|abcdef123456...",
        "token_type": "Bearer"
    }
}
```

### 2. Login User
**POST** `/login`

**Body:**
```json
{
    "email": "john@example.com",
    "password": "password123"
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Login successful",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "email_verified_at": null,
            "created_at": "2025-08-24T09:53:25.000000Z",
            "updated_at": "2025-08-24T09:53:25.000000Z"
        },
        "token": "2|abcdef123456...",
        "token_type": "Bearer"
    }
}
```

### 3. Logout User (Protected)
**POST** `/logout`

**Headers:**
```
Authorization: Bearer YOUR_TOKEN_HERE
```

**Response (200):**
```json
{
    "success": true,
    "message": "Logged out successfully"
}
```

### 4. Get User Profile (Protected)
**GET** `/profile`

**Headers:**
```
Authorization: Bearer YOUR_TOKEN_HERE
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "email_verified_at": null,
            "created_at": "2025-08-24T09:53:25.000000Z",
            "updated_at": "2025-08-24T09:53:25.000000Z",
            "borrowed_books": [
                {
                    "id": 1,
                    "title": "Sample Book",
                    "author": "Author Name",
                    "isbn": "1234567890",
                    "borrowed_at": "2025-08-24T10:00:00.000000Z",
                    "due_date": "2025-09-07T10:00:00.000000Z"
                }
            ]
        }
    }
}
```

---

## Book Management Endpoints (All Protected)

### 1. Get All Books
**GET** `/books`

**Query Parameters:**
- `search` (optional): Search in title, author, ISBN, or genre
- `available` (optional): Filter by availability (true/false)
- `genre` (optional): Filter by genre
- `page` (optional): Page number for pagination

**Example:**
```
GET /books?search=harry&available=true&page=1
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "title": "The Great Gatsby",
                "author": "F. Scott Fitzgerald",
                "isbn": "9780743273565",
                "description": "A classic American novel set in the Jazz Age.",
                "publication_year": 1925,
                "genre": "Classic Literature",
                "is_available": true,
                "user_id": null,
                "borrowed_at": null,
                "due_date": null,
                "created_at": "2025-08-24T09:53:25.000000Z",
                "updated_at": "2025-08-24T09:53:25.000000Z",
                "borrower": null
            }
        ],
        "first_page_url": "http://127.0.0.1:8000/api/books?page=1",
        "from": 1,
        "last_page": 1,
        "last_page_url": "http://127.0.0.1:8000/api/books?page=1",
        "links": [...],
        "next_page_url": null,
        "path": "http://127.0.0.1:8000/api/books",
        "per_page": 10,
        "prev_page_url": null,
        "to": 8,
        "total": 8
    }
}
```

### 2. Get Single Book
**GET** `/books/{id}`

**Response (200):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "title": "The Great Gatsby",
        "author": "F. Scott Fitzgerald",
        "isbn": "9780743273565",
        "description": "A classic American novel set in the Jazz Age.",
        "publication_year": 1925,
        "genre": "Classic Literature",
        "is_available": true,
        "user_id": null,
        "borrowed_at": null,
        "due_date": null,
        "created_at": "2025-08-24T09:53:25.000000Z",
        "updated_at": "2025-08-24T09:53:25.000000Z",
        "borrower": null
    }
}
```

### 3. Create New Book (Admin only)
**POST** `/books`

**Body:**
```json
{
    "title": "New Book Title",
    "author": "Author Name",
    "isbn": "9781234567890",
    "description": "Book description here",
    "publication_year": 2023,
    "genre": "Fiction"
}
```

**Response (201):**
```json
{
    "success": true,
    "message": "Book created successfully",
    "data": {
        "id": 9,
        "title": "New Book Title",
        "author": "Author Name",
        "isbn": "9781234567890",
        "description": "Book description here",
        "publication_year": 2023,
        "genre": "Fiction",
        "is_available": true,
        "user_id": null,
        "borrowed_at": null,
        "due_date": null,
        "created_at": "2025-08-24T10:00:00.000000Z",
        "updated_at": "2025-08-24T10:00:00.000000Z"
    }
}
```

### 4. Update Book (Admin only)
**PUT** `/books/{id}`

**Body:**
```json
{
    "title": "Updated Book Title",
    "author": "Updated Author Name",
    "isbn": "9781234567890",
    "description": "Updated description",
    "publication_year": 2023,
    "genre": "Updated Genre"
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Book updated successfully",
    "data": {
        "id": 9,
        "title": "Updated Book Title",
        "author": "Updated Author Name",
        "isbn": "9781234567890",
        "description": "Updated description",
        "publication_year": 2023,
        "genre": "Updated Genre",
        "is_available": true,
        "user_id": null,
        "borrowed_at": null,
        "due_date": null,
        "created_at": "2025-08-24T10:00:00.000000Z",
        "updated_at": "2025-08-24T10:00:00.000000Z"
    }
}
```

### 5. Delete Book (Admin only)
**DELETE** `/books/{id}`

**Response (200):**
```json
{
    "success": true,
    "message": "Book deleted successfully"
}
```

### 6. Borrow Book
**POST** `/books/{id}/borrow`

**Response (200):**
```json
{
    "success": true,
    "message": "Book borrowed successfully",
    "data": {
        "id": 1,
        "title": "The Great Gatsby",
        "author": "F. Scott Fitzgerald",
        "isbn": "9780743273565",
        "description": "A classic American novel set in the Jazz Age.",
        "publication_year": 1925,
        "genre": "Classic Literature",
        "is_available": false,
        "user_id": 1,
        "borrowed_at": "2025-08-24T10:00:00.000000Z",
        "due_date": "2025-09-07T10:00:00.000000Z",
        "created_at": "2025-08-24T09:53:25.000000Z",
        "updated_at": "2025-08-24T10:00:00.000000Z",
        "borrower": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com"
        }
    }
}
```

### 7. Return Book
**POST** `/books/{id}/return`

**Response (200):**
```json
{
    "success": true,
    "message": "Book returned successfully",
    "data": {
        "id": 1,
        "title": "The Great Gatsby",
        "author": "F. Scott Fitzgerald",
        "isbn": "9780743273565",
        "description": "A classic American novel set in the Jazz Age.",
        "publication_year": 1925,
        "genre": "Classic Literature",
        "is_available": true,
        "user_id": null,
        "borrowed_at": null,
        "due_date": null,
        "created_at": "2025-08-24T09:53:25.000000Z",
        "updated_at": "2025-08-24T10:05:00.000000Z"
    }
}
```

### 8. Get My Borrowed Books
**GET** `/my-books`

**Response (200):**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "title": "The Great Gatsby",
            "author": "F. Scott Fitzgerald",
            "isbn": "9780743273565",
            "description": "A classic American novel set in the Jazz Age.",
            "publication_year": 1925,
            "genre": "Classic Literature",
            "is_available": false,
            "user_id": 1,
            "borrowed_at": "2025-08-24T10:00:00.000000Z",
            "due_date": "2025-09-07T10:00:00.000000Z",
            "created_at": "2025-08-24T09:53:25.000000Z",
            "updated_at": "2025-08-24T10:00:00.000000Z"
        }
    ]
}
```

---

## Error Responses

### Validation Error (422)
```json
{
    "message": "The given data was invalid.",
    "errors": {
        "email": [
            "The email field is required."
        ],
        "password": [
            "The password field is required."
        ]
    }
}
```

### Authentication Error (401)
```json
{
    "success": false,
    "message": "Invalid credentials"
}
```

### Unauthorized (401)
```json
{
    "message": "Unauthenticated."
}
```

### Not Found (404)
```json
{
    "message": "No query results for model [App\\Models\\Book] 999"
}
```

### Business Logic Error (400)
```json
{
    "success": false,
    "message": "Book is not available for borrowing"
}
```

---

## Flutter Integration Tips

### 1. HTTP Client Setup
Use the `http` package and create a service class:

```dart
class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  String? token;

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}
```

### 2. Data Models
Create Dart models for User and Book:

```dart
class User {
  final int id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class Book {
  final int id;
  final String title;
  final String author;
  final String isbn;
  final String? description;
  final int? publicationYear;
  final String? genre;
  final bool isAvailable;
  
  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    this.description,
    this.publicationYear,
    this.genre,
    required this.isAvailable,
  });
  
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      isbn: json['isbn'],
      description: json['description'],
      publicationYear: json['publication_year'],
      genre: json['genre'],
      isAvailable: json['is_available'],
    );
  }
}
```

### 3. State Management
Consider using Provider, Riverpod, or Bloc for state management to handle user authentication state and book data.

### 4. Secure Token Storage
Use `flutter_secure_storage` package to securely store the authentication token.

---

## Test Credentials

A test user has been created:
- **Email:** test@example.com
- **Password:** password

You can use these credentials to test the login functionality, or register a new user.

## Sample Books Available

The database has been seeded with 8 sample books including:
- The Great Gatsby
- To Kill a Mockingbird
- 1984
- Pride and Prejudice
- The Catcher in the Rye
- Harry Potter and the Philosopher's Stone
- The Lord of the Rings
- Dune

All books are initially available for borrowing.
