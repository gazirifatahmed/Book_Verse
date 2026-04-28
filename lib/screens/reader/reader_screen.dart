import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/book_model.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;
  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  String _content = '';
  bool _isLoading = true;
  double _fontSize = 18.0;
  bool _isDarkReader = false;
  Color _readerBgColor = const Color(0xFFFDF6EC); // Warm sepia tone
  final ScrollController _scrollController = ScrollController();
  double _scrollPercent = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBookContent();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll > 0) {
        setState(() {
          _scrollPercent = currentScroll / maxScroll;
        });
      }
    }
  }

  Future<void> _loadBookContent() async {
    try {
      final data = await rootBundle.loadString(widget.book.contentPath);
      setState(() {
        _content = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _content = 'বই লোড করতে সমস্যা হচ্ছে। অনুগ্রহ করে আবার চেষ্টা করুন।';
        _isLoading = false;
      });
    }
  }

  void _toggleReaderTheme() {
    setState(() {
      _isDarkReader = !_isDarkReader;
      _readerBgColor = _isDarkReader ? const Color(0xFF1A1A2E) : const Color(0xFFFDF6EC);
    });
  }

  void _showReadingSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Reading Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Font Size Slider
                  Row(
                    children: [
                      const Icon(Icons.text_fields, size: 20),
                      const SizedBox(width: 12),
                      const Text('Font Size'),
                      const Spacer(),
                      Text(
                        '${_fontSize.toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: _fontSize,
                    min: 12,
                    max: 30,
                    divisions: 9,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (value) {
                      setModalState(() {
                        _fontSize = value;
                      });
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Theme Toggle
                  Row(
                    children: [
                      const Icon(Icons.palette_outlined, size: 20),
                      const SizedBox(width: 12),
                      const Text('Reading Theme'),
                      const Spacer(),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('Light'), icon: Icon(Icons.light_mode, size: 18)),
                          ButtonSegment(value: true, label: Text('Dark'), icon: Icon(Icons.dark_mode, size: 18)),
                        ],
                        selected: {_isDarkReader},
                        onSelectionChanged: (value) {
                          setModalState(() {
                            _isDarkReader = value.first;
                            _readerBgColor = _isDarkReader ? const Color(0xFF1A1A2E) : const Color(0xFFFDF6EC);
                          });
                          setState(() {
                            _isDarkReader = value.first;
                            _readerBgColor = _isDarkReader ? const Color(0xFF1A1A2E) : const Color(0xFFFDF6EC);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = _isDarkReader ? const Color(0xFFE0E0E0) : const Color(0xFF3D2C2C);

    return Scaffold(
      backgroundColor: _readerBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _isDarkReader ? Colors.white70 : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.book.title,
          style: TextStyle(
            color: _isDarkReader ? Colors.white70 : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Reading Progress
          Center(
            child: Text(
              '${(_scrollPercent * 100).toInt()}%',
              style: TextStyle(
                color: _isDarkReader ? Colors.white54 : Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.text_decrease, color: _isDarkReader ? Colors.white70 : Colors.black87),
            onPressed: () => setState(() { if (_fontSize > 12) _fontSize -= 2; }),
          ),
          Text(
            '${_fontSize.toInt()}',
            style: TextStyle(color: _isDarkReader ? Colors.white70 : Colors.black87, fontSize: 12),
          ),
          IconButton(
            icon: Icon(Icons.text_increase, color: _isDarkReader ? Colors.white70 : Colors.black87),
            onPressed: () => setState(() { if (_fontSize < 30) _fontSize += 2; }),
          ),
          // Settings Button
          IconButton(
            icon: Icon(Icons.tune_rounded, color: _isDarkReader ? Colors.white70 : Colors.black87),
            onPressed: _showReadingSettings,
          ),
        ],
      ),

      // Progress Bar at Top
      bottomSheet: Container(
        height: 3,
        color: _isDarkReader ? Colors.white12 : Colors.black12,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: _scrollPercent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
          ),
        ),
      ),

      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 20),
                  Text(
                    'বই লোড হচ্ছে...',
                    style: TextStyle(color: _isDarkReader ? Colors.white54 : Colors.black54),
                  ),
                ],
              ),
            )
          : GestureDetector(
              onTapUp: (details) {
                // Show/hide AppBar on tap (optional)
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Title Header
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 40,
                            color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.book.title,
                            style: TextStyle(
                              fontSize: _fontSize + 6,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '— ${widget.book.author} —',
                            style: TextStyle(
                              fontSize: _fontSize - 2,
                              color: textColor.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Divider(
                            color: textColor.withValues(alpha: 0.2),
                            thickness: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Main Content
                    Text(
                      _content,
                      style: TextStyle(
                        fontSize: _fontSize,
                        height: 1.9,
                        letterSpacing: 0.3,
                        wordSpacing: 1.5,
                        color: textColor,
                      ),
                      textAlign: TextAlign.justify,
                    ),

                    const SizedBox(height: 60),

                    // End of Book
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.auto_stories_rounded,
                            size: 32,
                            color: textColor.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '— সমাপ্ত —',
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.4),
                              fontSize: _fontSize - 2,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'আপনি বইটি সম্পূর্ণ পড়েছেন',
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.3),
                              fontSize: _fontSize - 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}