import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'library_model.dart';
import 'library_service.dart';
import 'library_login_logic.dart';
import 'library_borrow_form.dart';
import 'book_details_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Datum> _allBooks = [];
  List<Datum> _filtered = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applyFilter);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await LibraryService.getBooks();
      final model = LibraryModel.fromJson(data);
      _allBooks = model.data.data;
      _applyFilter();
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtered = List.of(_allBooks));
      return;
    }
    setState(() {
      _filtered = _allBooks.where((b) {
        return b.title.toLowerCase().contains(q) ||
            b.author.toLowerCase().contains(q) ||
            b.genre.toLowerCase().contains(q) ||
            b.isbn.toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _borrowBook(Datum book) async {
    // Navigate to borrow form instead of direct API call
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => LibraryBorrowForm(book: book),
      ),
    );

    // If borrow was successful, refresh the book list
    if (result == true) {
      await _loadBooks();
    }
  }

  Future<void> _returnBook(Datum book) async {
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
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Returned "${book.title}"'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadBooks();
      }
    } catch (e) {
      if (!mounted) return;
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search by title, author, ISBN, or genre',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        _applyFilter();
                      },
                    ),
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: MaterialBanner(
              backgroundColor: Colors.red.shade700,
              content: Text(_error!, style: const TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                  onPressed: _loadBooks,
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadBooks,
            child: _filtered.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: const [
                      Center(child: Text('No books found')),
                    ],
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width < 440 ? 1 : 2;
                      final aspect = crossAxisCount == 1 ? 0.85 : 0.48;
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: aspect,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final b = _filtered[index];
                          return _BookCard(
                            book: b,
                            onBorrow: b.isAvailable ? () => _borrowBook(b) : null,
                            onReturn: !b.isAvailable ? () => _returnBook(b) : null,
                            onTap: () {
                              // Navigate to book details screen
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BookDetailsScreen(book: b),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  final Datum book;
  final VoidCallback? onBorrow;
  final VoidCallback? onReturn;
  final VoidCallback? onTap;
  const _BookCard({required this.book, this.onBorrow, this.onReturn, this.onTap});

  String _getUniqueImageUrl(){

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = book.isAvailable;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Static image area (book cover)
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Unique book cover image for each book
                  Image.network(
                    _getUniqueImageUrl(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to gradient background if image fails
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
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
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
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                  if (!available)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Unavailable',
                          style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                // Slightly tighter paddings
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.genre} • ${book.publicationYear}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 28,
                      child: Row(
                        children: [
                          if (available)
                            Expanded(
                              child: FilledButton.tonal(
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                                  minimumSize: const Size.fromHeight(28),
                                ),
                                onPressed: onBorrow,
                                child: const Text('Borrow'),
                              ),
                            )
                          else if (onReturn != null)
                            Expanded(
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                                  minimumSize: const Size.fromHeight(28),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: onReturn,
                                icon: const Icon(Icons.assignment_return, size: 14),
                                label: const Text('Return'),
                              ),
                            )
                          else
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                                  minimumSize: const Size.fromHeight(26),
                                ),
                                onPressed: null,
                                icon: const Icon(Icons.lock_clock, size: 12),
                                label: const Text('Not available'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
