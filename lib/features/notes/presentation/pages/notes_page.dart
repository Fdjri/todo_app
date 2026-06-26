import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/bow_divider.dart';
import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';

/// Coquette Diary & Journal Dashboard
class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String? _selectedMoodFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Map<String, Map<String, dynamic>> _moodMeta = {
    'dreamy': {
      'icon': '🎀',
      'label': 'Dreamy',
      'color': const Color(0xFFF5D5E0),
      'textColor': const Color(0xFF8A4F6E),
    },
    'happy': {
      'icon': '🌸',
      'label': 'Happy',
      'color': const Color(0xFFFFE4E1),
      'textColor': const Color(0xFF9E4B4B),
    },
    'peaceful': {
      'icon': '🧸',
      'label': 'Peaceful',
      'color': const Color(0xFFFDF5E6),
      'textColor': const Color(0xFF8B7355),
    },
    'tired': {
      'icon': '☁️',
      'label': 'Tired',
      'color': const Color(0xFFECEFF1),
      'textColor': const Color(0xFF455A64),
    },
    'sparkly': {
      'icon': '✨',
      'label': 'Sparkly',
      'color': const Color(0xFFE8E5F5),
      'textColor': const Color(0xFF5C5494),
    },
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final textPrimary = theme.colorScheme.onSurface;
    final textHint = theme.hintColor;
    final surface = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
              child: Column(
                children: [
                  Text(
                    'Sweet Diary',
                    style: AppTypography.h1(color: textPrimary).copyWith(
                      fontFamily: GoogleFonts.dancingScript().fontFamily,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Write down your thoughts and sweet moments 🌸',
                    style: AppTypography.caption(color: textHint),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: BowDivider(),
                  ),
                ],
              ),
            ),

            // ─── Search & Filters ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: isDark ? 0.05 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.body(color: textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search your diaries...',
                        prefixIcon: Icon(Icons.search_rounded, color: primary.withValues(alpha: 0.7)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, color: textHint),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mood Filters Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _moodMeta.entries.map((entry) {
                        final moodKey = entry.key;
                        final meta = entry.value;
                        final isSelected = _selectedMoodFilter == moodKey;
                        final activeColor = meta['color'] as Color;
                        final activeTextColor = meta['textColor'] as Color;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_selectedMoodFilter == moodKey) {
                                  _selectedMoodFilter = null; // Toggle off
                                } else {
                                  _selectedMoodFilter = moodKey;
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? activeColor
                                    : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? primary
                                      : (isDark ? Colors.white.withValues(alpha: 0.1) : primary.withValues(alpha: 0.15)),
                                  width: 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: primary.withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    meta['icon'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    meta['label'],
                                    style: AppTypography.small(
                                      color: isSelected ? activeTextColor : textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Notes List ───
            Expanded(
              child: BlocBuilder<NotesBloc, NotesState>(
                builder: (context, state) {
                  if (state is NotesLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: primary),
                    );
                  }

                  if (state is NotesLoaded) {
                    // Filter notes
                    final filteredNotes = state.notes.where((note) {
                      final matchesMood = _selectedMoodFilter == null || note.mood == _selectedMoodFilter;
                      final matchesSearch = note.title.toLowerCase().contains(_searchQuery) ||
                          note.content.toLowerCase().contains(_searchQuery);
                      return matchesMood && matchesSearch;
                    }).toList();

                    if (filteredNotes.isEmpty) {
                      return _buildEmptyState(primary, textPrimary, textHint);
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.88,
                      ),
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];
                        return _buildNoteCard(context, note, isDark, primary, textPrimary, textHint, surface);
                      },
                    );
                  }

                  if (state is NotesError) {
                    return Center(
                      child: Text(
                        'Failed to load diary entries 🎀\n${state.message}',
                        style: AppTypography.body(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'notes_fab',
        onPressed: () => _openNoteDetail(context, null),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                primary,
                primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.favorite_rounded, size: 28, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color primary, Color textPrimary, Color textHint) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              builder: (context, val, child) {
                return Transform.scale(
                  scale: val,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '🎀',
                      style: TextStyle(fontSize: 48, color: primary),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Your Sweet Journal is Empty',
              style: AppTypography.h2(color: textPrimary).copyWith(
                fontFamily: GoogleFonts.dancingScript().fontFamily,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Capture your lovely thoughts, daily reflections, or sweet moments. Tap the heart below to start writing! ✨',
              style: AppTypography.body(color: textHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    NoteEntity note,
    bool isDark,
    Color primary,
    Color textPrimary,
    Color textHint,
    Color surface,
  ) {
    final meta = _moodMeta[note.mood] ?? _moodMeta['happy']!;
    final moodColor = meta['color'] as Color;
    final moodTextColor = meta['textColor'] as Color;
    final formattedDate = _formatNoteDate(note.createdAt);

    return GestureDetector(
      onTap: () => _openNoteDetail(context, note),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? surface : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: primary.withValues(alpha: isDark ? 0.25 : 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: isDark ? 0.04 : 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Delicate lined background pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(
                  painter: _CardLinesPainter(lineColor: primary),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mood chip & Top Bow emblem
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: moodColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(meta['icon'], style: const TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              meta['label'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: moodTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Cute bow character or tiny decorative bow icon
                      Text(
                        '🎀',
                        style: TextStyle(
                          fontSize: 12,
                          color: primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    note.title.isNotEmpty ? note.title : 'Untitled',
                    style: AppTypography.h3(color: textPrimary).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Date
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded, size: 10, color: primary.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: AppTypography.small(color: textHint).copyWith(
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Content Preview
                  Expanded(
                    child: Text(
                      note.content,
                      style: AppTypography.body(color: textPrimary.withValues(alpha: 0.8)).copyWith(
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
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

  String _formatNoteDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$month $day, $year • $hour:$minute';
  }

  void _openNoteDetail(BuildContext ctx, NoteEntity? note) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => NoteDetailPage(note: note),
      ),
    );
  }
}

/// Simple pattern of faint lines for note cards
class _CardLinesPainter extends CustomPainter {
  final Color lineColor;

  _CardLinesPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5;

    double y = 45;
    while (y < size.height) {
      canvas.drawLine(
        Offset(12, y),
        Offset(size.width - 12, y),
        paint,
      );
      y += 18;
    }
  }

  @override
  bool shouldRepaint(covariant _CardLinesPainter oldDelegate) => false;
}

/// Notebook Stationery Lined Writing Screen
class NoteDetailPage extends StatefulWidget {
  final NoteEntity? note;

  const NoteDetailPage({super.key, this.note});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late String _selectedMood;

  final Map<String, String> _moodMap = {
    'dreamy': '🎀 Dreamy',
    'happy': '🌸 Happy',
    'peaceful': '🧸 Peaceful',
    'tired': '☁️ Tired',
    'sparkly': '✨ Sparkly',
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedMood = widget.note?.mood ?? 'happy';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save(BuildContext ctx) {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      shadcn.showToast(
        context: ctx,
        builder: (context, overlay) => shadcn.SurfaceCard(
          child: shadcn.Basic(
            title: Text(
              'Please write some thoughts first! 🌸',
              style: AppTypography.bodyBold(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ),
        location: shadcn.ToastLocation.bottomCenter,
      );
      return;
    }

    if (widget.note == null) {
      // Create new
      final newNote = NoteEntity(
        id: IdGenerator.generate(),
        title: title.isEmpty ? 'Untitled Diary' : title,
        content: content,
        mood: _selectedMood,
        createdAt: DateTime.now(),
      );
      ctx.read<NotesBloc>().add(AddNoteEvent(newNote));
    } else {
      // Edit existing
      final updatedNote = widget.note!.copyWith(
        title: title.isEmpty ? 'Untitled Diary' : title,
        content: content,
        mood: _selectedMood,
      );
      ctx.read<NotesBloc>().add(UpdateNoteEvent(updatedNote));
    }

    Navigator.of(ctx).pop();
  }

  void _delete(BuildContext ctx) {
    shadcn.showDialog(
      context: ctx,
      builder: (dialogCtx) => shadcn.AlertDialog(
        title: const Text('Delete Entry? 🎀'),
        content: const Text('Are you sure you want to erase this sweet memory? This cannot be undone.'),
        actions: [
          shadcn.Button(
            style: const shadcn.ButtonStyle.ghost(),
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          shadcn.Button(
            style: const shadcn.ButtonStyle.destructive(),
            onPressed: () {
              ctx.read<NotesBloc>().add(DeleteNoteEvent(widget.note!.id));
              Navigator.of(dialogCtx).pop(); // pop dialog
              Navigator.of(ctx).pop(); // pop detail page
            },
            child: const Text('Erase'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final textPrimary = theme.colorScheme.onSurface;
    final surface = theme.colorScheme.surface;
    final isEdit = widget.note != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Diary' : 'New Diary Entry',
          style: AppTypography.h2(color: textPrimary).copyWith(
            fontFamily: GoogleFonts.dancingScript().fontFamily,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
              onPressed: () => _delete(context),
            ),
          IconButton(
            icon: Icon(Icons.check_rounded, color: primary, size: 28),
            onPressed: () => _save(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Decorative Divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: BowDivider(),
            ),
            const SizedBox(height: 12),

            // Mood selection row in writing page
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How is your mood today? 💕',
                    style: AppTypography.small(color: textPrimary).copyWith(
                      fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _moodMap.entries.map((entry) {
                      final isSelected = _selectedMood == entry.key;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMood = entry.key;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primary.withValues(alpha: 0.15)
                                    : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? primary : primary.withValues(alpha: 0.12),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  entry.value.split(' ')[0], // only show emoji icon for spacing
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Feeling ${_moodMap[_selectedMood]!.split(' ')[1]} ✨',
                      style: AppTypography.small(color: primary).copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Lined Notebook Paper Editor
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? surface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primary.withValues(alpha: isDark ? 0.25 : 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Paper lines background
                      Positioned.fill(
                        child: CustomPaint(
                          painter: LinedPaperPainter(
                            lineColor: primary.withValues(alpha: isDark ? 0.15 : 0.08),
                            lineHeight: 28.0,
                            horizontalPadding: 20.0,
                          ),
                        ),
                      ),

                      // Text Field Container
                      Padding(
                        padding: const EdgeInsets.only(left: 46, right: 20, top: 8, bottom: 8),
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            // Title input
                            TextField(
                              controller: _titleController,
                              style: AppTypography.h2(color: textPrimary).copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Dear Diary...',
                                hintStyle: AppTypography.h2(color: theme.hintColor).copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                filled: false,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Content input
                            TextField(
                              controller: _contentController,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              style: AppTypography.body(color: textPrimary).copyWith(
                                fontSize: 15,
                                height: 28.0 / 15.0, // Match line height of painter!
                              ),
                              decoration: InputDecoration(
                                hintText: 'Write down your beautiful secrets here...',
                                hintStyle: AppTypography.body(color: theme.hintColor).copyWith(
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                filled: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Painter to draw lines resembling a physical school notebook paper
class LinedPaperPainter extends CustomPainter {
  final Color lineColor;
  final double lineHeight;
  final double horizontalPadding;

  LinedPaperPainter({
    required this.lineColor,
    required this.lineHeight,
    required this.horizontalPadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    // Draw notebook red vertical margin line on the left
    final marginPaint = Paint()
      ..color = const Color(0xFFE8A0BF).withValues(alpha: 0.3)
      ..strokeWidth = 1.5;
    
    // Draw vertical margin line
    canvas.drawLine(
      Offset(horizontalPadding + 16, 0),
      Offset(horizontalPadding + 16, size.height),
      marginPaint,
    );

    // Draw horizontal writing lines starting after the title
    double y = 48; // Offset down so title looks clean
    while (y < size.height) {
      canvas.drawLine(
        Offset(horizontalPadding, y),
        Offset(size.width - horizontalPadding, y),
        paint,
      );
      y += lineHeight;
    }
  }

  @override
  bool shouldRepaint(covariant LinedPaperPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.lineHeight != lineHeight ||
        oldDelegate.horizontalPadding != horizontalPadding;
  }
}
