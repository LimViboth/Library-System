# 📚 Library Management System

A full-stack library management application built with **Laravel** (backend) and **Flutter** (frontend). This system allows users to browse, borrow, and return books with a modern, intuitive interface.

## 🌟 Features

### Frontend (Flutter)
- **Modern UI/UX**: Beautiful card-based book display with unique cover images
- **Book Browsing**: Grid layout with search functionality by title, author, genre, or ISBN
- **Book Details**: Detailed view with complete book information and descriptions
- **User Authentication**: Secure login and registration system
- **Book Borrowing**: Streamlined borrowing process with form validation
- **Book Returns**: Easy return functionality with confirmation dialogs
- **Responsive Design**: Works on mobile, tablet, and desktop
- **Real-time Updates**: Automatic refresh after borrowing/returning books

### Backend (Laravel)
- **RESTful API**: Well-structured API endpoints with comprehensive documentation
- **Authentication**: Laravel Sanctum for secure token-based authentication
- **Book Management**: CRUD operations for books with availability tracking
- **User Management**: User registration, login, and profile management
- **Borrow System**: Track book borrowing with due dates and return functionality
- **Database**: SQLite database with proper migrations and seeders

## 🛠️ Technology Stack

### Frontend
- **Flutter** 3.7.2+
- **Dart** 
- **Provider** (State Management)
- **HTTP** (API Communication)
- **Cached Network Image** (Image Caching)
- **Flutter Secure Storage** (Secure Token Storage)
- **Skeletonizer** (Loading States)

### Backend
- **Laravel** 12.0
- **PHP** 8.2+
- **Laravel Sanctum** (Authentication)
- **PostGreSQL** (Database)
- **Laravel Tinker** (Development)

## 📁 Project Structure

```
Library-System/
├── backend/                 # Laravel API
│   ├── app/
│   │   ├── Http/           # Controllers & Middleware
│   │   └── Models/         # Eloquent Models
│   ├── database/
│   │   ├── migrations/     # Database Migrations
│   │   ├── seeders/        # Database Seeders
│   │   └── database.sqlite # SQLite Database
│   ├── routes/
│   │   └── api.php        # API Routes
│   └── API_DOCUMENTATION.md
│
├── frontend/               # Flutter Application
│   ├── lib/
│   │   ├── main.dart      # App Entry Point
│   │   └── library_module/
│   │       ├── library_app.dart         # Main App Widget
│   │       ├── library_screen.dart      # Books Grid Screen
│   │       ├── book_details_screen.dart # Book Details Page
│   │       ├── library_borrow_form.dart # Borrowing Form
│   │       ├── library_login_screen.dart # Authentication
│   │       ├── library_service.dart     # API Service
│   │       ├── library_model.dart       # Data Models
│   │       └── library_login_logic.dart # Auth Logic
│   └── pubspec.yaml       # Flutter Dependencies
│
└── README.md             # This file
```

## 🚀 Getting Started

### Prerequisites
- **PHP** 8.2 or higher
- **Composer**
- **Flutter** 3.7.2 or higher
- **Android Studio** or **VS Code** (for Flutter development)

### Backend Setup

1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Install PHP dependencies:**
   ```bash
   composer install
   ```

3. **Copy environment file:**
   ```bash
   cp .env.example .env
   ```

4. **Generate application key:**
   ```bash
   php artisan key:generate
   ```

5. **Run database migrations:**
   ```bash
   php artisan migrate
   ```

6. **Seed the database (optional):**
   ```bash
   php artisan db:seed
   ```

7. **Start the Laravel server:**
   ```bash
   php artisan serve
   ```

The API will be available at `http://127.0.0.1:8000`

### Frontend Setup

1. **Navigate to the frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the Flutter application:**
   ```bash
   flutter run
   ```

## 📖 API Documentation

The backend includes comprehensive API documentation. Key endpoints include:

### Authentication
- `POST /api/register` - User registration
- `POST /api/login` - User login
- `POST /api/logout` - User logout

### Books
- `GET /api/books` - Get all books with pagination
- `GET /api/books/{id}` - Get specific book details

### Borrowing
- `POST /api/books/{id}/borrow` - Borrow a book
- `POST /api/books/{id}/return` - Return a book

For complete API documentation, see `backend/API_DOCUMENTATION.md`

## 🎨 App Features

### Book Display
- **Card Layout**: Books displayed in responsive grid cards
- **Unique Images**: Each book has a unique cover image from curated URLs
- **Status Indicators**: Visual indicators for book availability
- **Search**: Real-time search across title, author, genre, and ISBN

### Book Details
- **Comprehensive View**: Full book information including description
- **Visual Design**: Large cover image with organized information cards
- **Actions**: Direct borrowing/returning from details page

### Borrowing System
- **Form Validation**: Required reason for borrowing
- **Date Selection**: Expected return date picker
- **Terms Display**: Clear borrowing terms and conditions
- **Confirmation**: Success/error messaging with visual feedback

### User Experience
- **Responsive**: Works across different screen sizes
- **Loading States**: Skeleton loading and progress indicators
- **Error Handling**: Graceful error handling with retry options
- **Navigation**: Intuitive navigation between screens

## 🔧 Configuration

### Backend Configuration
Update `.env` file for database and application settings:
```env
DB_CONNECTION=sqlite
DB_DATABASE=/absolute/path/to/database.sqlite
API_URL=http://127.0.0.1:8000
```

### Frontend Configuration
Update API endpoints in `lib/library_module/library_service.dart` if needed:
```dart
static const String baseUrl = 'http://127.0.0.1:8000/api';
```

## 🧪 Testing

### Backend Testing
```bash
cd backend
php artisan test
```

### Frontend Testing
```bash
cd frontend
flutter test
```

## 📱 Supported Platforms

- **Android** (Primary)
- **iOS**
- **Web**
- **Desktop** (Windows, macOS, Linux)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request


## 🔗 Links

- **Backend API Documentation**: `backend/API_DOCUMENTATION.md`
- **Flutter Documentation**: [https://flutter.dev/docs](https://flutter.dev/docs)
- **Laravel Documentation**: [https://laravel.com/docs](https://laravel.com/docs)

## 📞 Support

For support and questions, please create an issue in the repository or contact the development team.

---

**Built with ❤️ using Flutter and Laravel**
