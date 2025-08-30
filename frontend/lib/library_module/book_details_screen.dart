import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'library_model.dart';
import 'library_login_logic.dart';
import 'library_service.dart';
import 'library_borrow_form.dart';

class BookDetailsScreen extends StatelessWidget {
  final Datum book;

  const BookDetailsScreen({super.key, required this.book});

  String _getUniqueImageUrl() {
    final imageUrls = [
      'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1650033243i/41733839.jpg', //The great gatsby
      'https://m.media-amazon.com/images/I/81O7u0dGaWL._UF1000,1000_QL80_.jpg', // to kill a mockingbird
      'https://m.media-amazon.com/images/I/71wANojhEKL._UF1000,1000_QL80_.jpg', // 1984
      'https://almabooks.com/wp-content/uploads/2016/10/9781847493699.jpg', // pride and prejudice
      'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1398034300i/5107.jpg', // the catcher in the rye
      'https://m.media-amazon.com/images/I/81q77Q39nEL.jpg', // Harry Potter
      'https://m.media-amazon.com/images/I/913sMwNHsBL._UF894,1000_QL80_.jpg', // Lord of the Rings
      'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1555447414i/44767458.jpg', // Dune
    ];
    final imageIndex = (book.id - 1) % imageUrls.length;
    return imageUrls[imageIndex];
  }

  Future<void> _borrowBook(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => LibraryBorrowForm(book: book),
      ),
    );

    if (result == true) {
      Navigator.of(context).pop(true); // Return to previous screen and refresh
    }
  }

  Future<void> _returnBook(BuildContext context) async {
    final token = context.read<LibraryLoginLogic>().loggedUser.token;
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to return books')),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Book'),
        content: Text('Are you sure you want to return "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Return'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final ok = await LibraryService.returnBook(book.id, token);
      if (!context.mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Returned "${book.title}"'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return to previous screen and refresh
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Return failed: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = book.isAvailable;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover and basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book cover image
                Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _getUniqueImageUrl(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: 0.18),
                                theme.colorScheme.secondary.withValues(alpha: 0.18),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 46,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Book info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'by ${book.author}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: available
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: available ? Colors.green : Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          available ? 'Available' : 'Not Available',
                          style: TextStyle(
                            color: available ? Colors.green.shade700 : Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Book details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book Information',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(label: 'Genre', value: book.genre),
                    _DetailRow(label: 'Publication Year', value: book.publicationYear.toString()),
                    _DetailRow(label: 'ISBN', value: book.isbn),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      book.description.isNotEmpty
                        ? book.description
                        : 'No description available for this book.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: available
                ? FilledButton.icon(
                    onPressed: () => _borrowBook(context),
                    icon: const Icon(Icons.book),
                    label: const Text('Borrow Book'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  )
                : book.userId != null
                  ? FilledButton.icon(
                      onPressed: () => _returnBook(context),
                      icon: const Icon(Icons.assignment_return),
                      label: const Text('Return Book'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.lock_clock),
                      label: const Text('Not Available'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
