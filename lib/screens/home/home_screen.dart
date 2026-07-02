import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../widgets/book_card.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  bool _isSearchFocused = false;
  bool _isScrolled = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _books = BookService.getDummyBooks();
    _filteredBooks = _books;

    // Fade animation for list items
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Slide animation for header
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();

    _searchFocus.addListener(() {
      setState(() => _isSearchFocused = _searchFocus.hasFocus);
    });

    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 20;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    });
  }

  void _filterBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = _books;
      } else {
        _filteredBooks = _books
            .where((book) =>
                book.title.toLowerCase().contains(query.toLowerCase()) ||
                book.author.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });

    // Re-trigger list animation on new results
    _fadeController.reset();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = themeProvider.isDarkMode;
    final size = MediaQuery.of(context).size;

    // Premium color palette
    final Color bgColor = isDark ? const Color(0xFF0D0D14) : const Color(0xFFF5F3EF);
    final Color surfaceColor = isDark ? const Color(0xFF16161F) : const Color(0xFFFFFFFF);
    final Color accentGold = const Color(0xFFD4AF7A);
    final Color accentDeep = isDark ? const Color(0xFF7B68EE) : const Color(0xFF5B4FCF);
    final Color textPrimary = isDark ? const Color(0xFFF0EEE8) : const Color(0xFF1A1714);
    final Color textSecondary = isDark ? const Color(0xFF8A8478) : const Color(0xFF6B6560);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: bgColor,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: bgColor,
            ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            // ── Decorative background orbs ──────────────────────────
            Positioned(
              top: -80,
              right: -60,
              child: _GlowOrb(
                size: 260,
                color: accentDeep.withValues(alpha: isDark ? 0.18 : 0.10),
              ),
            ),
            Positioned(
              top: size.height * 0.35,
              left: -90,
              child: _GlowOrb(
                size: 200,
                color: accentGold.withValues(alpha: isDark ? 0.10 : 0.08),
              ),
            ),

            // ── Main Content ─────────────────────────────────────────
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── TOP BAR ───────────────────────────────────────
                  SlideTransition(
                    position: _slideAnimation,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
                      decoration: BoxDecoration(
                        color: _isScrolled
                            ? surfaceColor.withValues(alpha: 0.85)
                            : Colors.transparent,
                        boxShadow: _isScrolled
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          // App Icon and App Name integration
                          Row(
                            children: [
                              // মূল ইমেজ এবং ব্যাকআপ উভয়কেই সম্পূর্ণ Round Shape করা হয়েছে
                              ClipOval(
                                child: Image.asset(
                                  'assets/icon/app_icon.png',
                                  height: 34,
                                  width: 34,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // ইমেজ লোড না হলে এই ব্যাকআপ কন্টেইনারটি একদম গোলাকার দেখাবে
                                    return Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [accentGold, accentDeep],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle, // এখানে বক্স শেপ থেকে সার্কেল শেপ করা হয়েছে
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'B',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BookVerse',
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  Text(
                                    'Your literary universe',
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 10,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          _PremiumIconButton(
                            icon: isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              themeProvider.toggleTheme();
                            },
                            isDark: isDark,
                            surfaceColor: surfaceColor,
                            iconColor: textSecondary,
                          ),
                          const SizedBox(width: 6),
                          _PremiumIconButton(
                            icon: Icons.tune_rounded,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, a1, a2) => const SettingsScreen(),
                                  transitionsBuilder: (_, anim, _, child) =>
                                      SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                        parent: anim,
                                        curve: Curves.easeOutCubic)),
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            isDark: isDark,
                            surfaceColor: surfaceColor,
                            iconColor: textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── HERO GREETING ─────────────────────────────────
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Discover\n',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                letterSpacing: -1.2,
                              ),
                            ),
                            TextSpan(
                              text: 'your next story.',
                              style: TextStyle(
                                color: accentGold,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                letterSpacing: -1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── SEARCH BAR ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _isSearchFocused
                              ? accentGold.withValues(alpha: 0.7)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isSearchFocused
                                ? accentGold.withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: isDark ? 0.25 : 0.07),
                            blurRadius: _isSearchFocused ? 20 : 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        onChanged: _filterBooks,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search titles, authors...',
                          hintStyle: TextStyle(
                            color: textSecondary.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 14, right: 10),
                            child: Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: _isSearchFocused ? accentGold : textSecondary,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    _searchController.clear();
                                    _filterBooks('');
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: textSecondary.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: textSecondary,
                                    ),
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 4,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ── SECTION HEADER ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 3.5,
                          height: 18,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accentGold, accentDeep],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Trending Now',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_filteredBooks.length} books',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── BOOK LIST ─────────────────────────────────────
                  Expanded(
                    child: _filteredBooks.isEmpty
                        ? _EmptyState(
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            accentGold: accentGold,
                          )
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _filteredBooks.length,
                              itemBuilder: (context, index) {
                                return _AnimatedBookItem(
                                  index: index,
                                  child: BookCard(book: _filteredBooks[index]),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocus.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}

// ── Supporting Widgets ─────────────────────────────────────────────────────────

class _AnimatedBookItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedBookItem({required this.index, required this.child});

  @override
  State<_AnimatedBookItem> createState() => _AnimatedBookItemState();
}

class _AnimatedBookItemState extends State<_AnimatedBookItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

class _PremiumIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final Color surfaceColor;
  final Color iconColor;

  const _PremiumIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    required this.surfaceColor,
    required this.iconColor,
  });

  @override
  State<_PremiumIconButton> createState() => _PremiumIconButtonState();
}

class _PremiumIconButtonState extends State<_PremiumIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: widget.surfaceColor.withValues(alpha: widget.isDark ? 0.6 : 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(widget.icon, size: 18, color: widget.iconColor),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

class _EmptyState extends StatelessWidget {
  final Color textPrimary;
  final Color textSecondary;
  final Color accentGold;

  const _EmptyState({
    required this.textPrimary,
    required this.textSecondary,
    required this.accentGold,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: accentGold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 36,
              color: accentGold.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No books found',
            style: TextStyle(
              color: textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different title or author name',
            style: TextStyle(
              color: textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}