import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ItineraryView — Parses and beautifully renders Gemini markdown itinerary.
// Handles: ## Day headers, ### sub-headers, - bullets, **bold**, time labels
// ─────────────────────────────────────────────────────────────────────────────

class ItineraryView extends StatelessWidget {
  final String itinerary;
  const ItineraryView({super.key, required this.itinerary});

  @override
  Widget build(BuildContext context) {
    if (itinerary.trim().isEmpty) {
      return _EmptyItinerary();
    }

    final days = _parseItinerary(itinerary);

    if (days.isEmpty) {
      // Fallback: render as plain readable text
      return _PlainTextView(text: itinerary);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < days.length; i++)
          _DayCard(day: days[i], index: i),
      ],
    );
  }

  List<_ItineraryDay> _parseItinerary(String raw) {
    final lines = raw.trim().split('\n');
    final List<_ItineraryDay> days = [];
    _ItineraryDay? current;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // ## Day X — main day header
      if (trimmed.startsWith('## ')) {
        if (current != null) days.add(current);
        current = _ItineraryDay(
          title: _stripMarkdown(trimmed.substring(3).trim()),
          blocks: [],
        );
      }
      // ### Sub-section header
      else if (trimmed.startsWith('### ')) {
        current ??= _ItineraryDay(title: '', blocks: []);
        current.blocks.add(_Block(
          type: _BlockType.subHeader,
          text: _stripMarkdown(trimmed.substring(4).trim()),
        ));
      }
      // Bullet item
      else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        current ??= _ItineraryDay(title: '', blocks: []);
        final content = trimmed.substring(2).trim();
        current.blocks.add(_Block(
          type: _BlockType.bullet,
          text: content,
        ));
      }
      // Numbered list
      else if (RegExp(r'^\d+\.\s').hasMatch(trimmed)) {
        current ??= _ItineraryDay(title: '', blocks: []);
        final content = trimmed.replaceFirst(RegExp(r'^\d+\.\s'), '');
        current.blocks.add(_Block(type: _BlockType.bullet, text: content));
      }
      // Bold-only line (like **Morning**)
      else if (trimmed.startsWith('**') && trimmed.endsWith('**') && trimmed.length > 4) {
        current ??= _ItineraryDay(title: '', blocks: []);
        current.blocks.add(_Block(
          type: _BlockType.subHeader,
          text: trimmed.replaceAll('**', '').trim(),
        ));
      }
      // Regular paragraph text
      else if (trimmed.isNotEmpty) {
        current ??= _ItineraryDay(title: '', blocks: []);
        current.blocks.add(_Block(type: _BlockType.paragraph, text: trimmed));
      }
    }

    if (current != null) days.add(current);
    return days;
  }

  String _stripMarkdown(String s) =>
      s.replaceAll('**', '').replaceAll('__', '').replaceAll('*', '').trim();
}

// ── Data models ───────────────────────────────────────────────────────────────

enum _BlockType { subHeader, bullet, paragraph }

class _Block {
  final _BlockType type;
  final String text;
  _Block({required this.type, required this.text});
}

class _ItineraryDay {
  final String title;
  final List<_Block> blocks;
  _ItineraryDay({required this.title, required this.blocks});
}

// ── Accent colour cycling ─────────────────────────────────────────────────────

const _kAccents = [
  [Color(0xFF0057FF), Color(0xFF338BFF)],  // blue
  [Color(0xFF00C9A7), Color(0xFF00E5BF)],  // teal
  [Color(0xFF8B5CF6), Color(0xFFAB7BFF)],  // purple
  [Color(0xFFF59E0B), Color(0xFFFFBD42)],  // amber
  [Color(0xFFEF4444), Color(0xFFFF7070)],  // coral
];

// ── Day Card ──────────────────────────────────────────────────────────────────

class _DayCard extends StatefulWidget {
  final _ItineraryDay day;
  final int index;
  const _DayCard({required this.day, required this.index});

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  bool _expanded = true; // first few expanded by default

  @override
  void initState() {
    super.initState();
    _expanded = widget.index < 3; // expand first 3 days
  }

  @override
  Widget build(BuildContext context) {
    final colors = _kAccents[widget.index % _kAccents.length];
    final baseColor = colors[0];
    final lightColor = colors[1];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Gradient header (tappable to expand/collapse) ──
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [baseColor, lightColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  // Day number badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.day.title.isEmpty
                          ? 'Day ${widget.index + 1}'
                          : widget.day.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable body ──
          AnimatedCrossFade(
            firstChild: _DayBody(blocks: widget.day.blocks, accentColor: baseColor),
            secondChild: const SizedBox.shrink(),
            crossFadeState:
                _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

// ── Day body (blocks list) ────────────────────────────────────────────────────

class _DayBody extends StatelessWidget {
  final List<_Block> blocks;
  final Color accentColor;
  const _DayBody({required this.blocks, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: blocks.map((b) => _buildBlock(b)).toList(),
      ),
    );
  }

  Widget _buildBlock(_Block block) {
    switch (block.type) {
      case _BlockType.subHeader:
        return _SubHeader(text: block.text, color: accentColor);
      case _BlockType.bullet:
        return _BulletItem(text: block.text, color: accentColor);
      case _BlockType.paragraph:
        return _ParagraphItem(text: block.text);
    }
  }
}

// ── Sub-header (### or **Morning**) ──────────────────────────────────────────

class _SubHeader extends StatelessWidget {
  final String text;
  final Color color;
  const _SubHeader({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bullet item ───────────────────────────────────────────────────────────────

class _BulletItem extends StatelessWidget {
  final String text;
  final Color color;
  const _BulletItem({required this.text, required this.color});

  // Detects time prefix like "9:00 AM –" or "Morning –"
  static final _timeRegex = RegExp(
    r'^(\d{1,2}:\d{2}\s?(?:AM|PM|am|pm)?|Morning|Afternoon|Evening|Night)\s*[:\-–]\s*',
    caseSensitive: false,
  );

  @override
  Widget build(BuildContext context) {
    final timeMatch = _timeRegex.firstMatch(text);
    final hasTime = timeMatch != null;
    final timeLabel = hasTime ? timeMatch.group(0)!.replaceAll(RegExp(r'[\-–:]\s*$'), '').trim() : '';
    final body = hasTime ? text.substring(timeMatch.end).trim() : text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent dot
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTime)
                  Container(
                    margin: const EdgeInsets.only(bottom: 3),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      timeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                _RichText(text: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Paragraph item ────────────────────────────────────────────────────────────

class _ParagraphItem extends StatelessWidget {
  final String text;
  const _ParagraphItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _RichText(text: text),
    );
  }
}

// ── Rich text (handles **bold** inline) ──────────────────────────────────────

class _RichText extends StatelessWidget {
  final String text;
  const _RichText({required this.text});

  @override
  Widget build(BuildContext context) {
    final spans = _parseInline(text);
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  List<TextSpan> _parseInline(String raw) {
    final List<TextSpan> spans = [];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int last = 0;

    for (final match in regex.allMatches(raw)) {
      if (match.start > last) {
        spans.add(TextSpan(
          text: raw.substring(last, match.start),
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary,
            height: 1.55,
          ),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.55,
        ),
      ));
      last = match.end;
    }

    if (last < raw.length) {
      spans.add(TextSpan(
        text: raw.substring(last),
        style: const TextStyle(
          fontSize: 13.5,
          color: AppColors.textSecondary,
          height: 1.55,
        ),
      ));
    }

    return spans;
  }
}

// ── Plain text fallback ───────────────────────────────────────────────────────

class _PlainTextView extends StatelessWidget {
  final String text;
  const _PlainTextView({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyItinerary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.map_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text(
            'No itinerary generated yet.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
