import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'library_model.dart';
import 'library_service.dart';
import 'library_login_logic.dart';

class LibraryBorrowForm extends StatefulWidget {
  final Datum book;

  const LibraryBorrowForm({super.key, required this.book});

  @override
  State<LibraryBorrowForm> createState() => _LibraryBorrowFormState();
}

class _LibraryBorrowFormState extends State<LibraryBorrowForm> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _returnDate;
  bool _isSubmitting = false;

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
    final imageIndex = (widget.book.id - 1) % imageUrls.length;
    return imageUrls[imageIndex];
  }

  @override
  void initState() {
    super.initState();
    // Set default return date to 2 weeks from now
    _returnDate = DateTime.now().add(const Duration(days: 14));
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectReturnDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      helpText: 'Select return date',
    );
    if (picked != null && picked != _returnDate) {
      setState(() {
        _returnDate = picked;
      });
    }
  }

  Future<void> _submitBorrowRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final token = context.read<LibraryLoginLogic>().loggedUser.token;
      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to borrow books')),
        );
        return;
      }

      final success = await LibraryService.borrowBook(widget.book.id, token);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully borrowed "${widget.book.title}"'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Borrow failed: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrow Book'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Book info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
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
                                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                      Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                                    ],
                                  ),
                                ),
                                child: const Icon(Icons.menu_book, size: 30),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                      Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.book.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.book.author,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.book.genre} • ${widget.book.publicationYear}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Borrow reason
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for borrowing',
                  hintText: 'e.g., Research, Personal reading, Assignment',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a reason for borrowing';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Expected return date
              InkWell(
                onTap: _selectReturnDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expected return date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _returnDate != null
                        ? '${_returnDate!.day}/${_returnDate!.month}/${_returnDate!.year}'
                        : 'Select return date',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Additional notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional notes (optional)',
                  hintText: 'Any special requirements or notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 24),

              // Terms and conditions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Borrowing Terms:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Maximum borrowing period: 30 days'),
                    const Text('• Late return may result in penalties'),
                    const Text('• Book must be returned in good condition'),
                    const Text('• Report any damage immediately'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submitBorrowRequest,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.book),
                label: Text(_isSubmitting ? 'Processing...' : 'Confirm Borrow'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
