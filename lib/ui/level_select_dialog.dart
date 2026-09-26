import 'package:flutter/material.dart';
import '../core/puzzle/levels/level_definitions.dart';
import '../core/storage/player_progress.dart';

class LevelSelectDialog extends StatefulWidget {
  final int currentLevelId;
  final PlayerProgress progress;
  final ValueChanged<int> onSelectLevel;

  const LevelSelectDialog({
    super.key,
    required this.currentLevelId,
    required this.progress,
    required this.onSelectLevel,
  });

  @override
  State<LevelSelectDialog> createState() => _LevelSelectDialogState();
}

class _LevelSelectDialogState extends State<LevelSelectDialog> {
  late int _selectedChapter;

  static const List<Map<String, dynamic>> _chapters = [
    {
      'id': 1,
      'roman': 'I',
      'tag': 'Foundations',
      'fullTitle': 'Chapter I: The Foundations',
      'range': 'Levels 1–10',
      'startLevel': 1,
      'endLevel': 10,
    },
    {
      'id': 2,
      'roman': 'II',
      'tag': 'Temporal',
      'fullTitle': 'Chapter II: Temporal Awakening',
      'range': 'Levels 11–20',
      'startLevel': 11,
      'endLevel': 20,
    },
    {
      'id': 3,
      'roman': 'III',
      'tag': 'Spatial',
      'fullTitle': 'Chapter III: Spatial Matrices',
      'range': 'Levels 21–30',
      'startLevel': 21,
      'endLevel': 30,
    },
    {
      'id': 4,
      'roman': 'IV',
      'tag': 'Machines',
      'fullTitle': 'Chapter IV: Complex Machines',
      'range': 'Levels 31–40',
      'startLevel': 31,
      'endLevel': 40,
    },
    {
      'id': 5,
      'roman': 'V',
      'tag': 'Grandmaster',
      'fullTitle': 'Chapter V: Grandmaster',
      'range': 'Levels 41–50',
      'startLevel': 41,
      'endLevel': 50,
    },
    {
      'id': 6,
      'roman': 'VI',
      'tag': 'Adv. Echo',
      'fullTitle': 'Chapter VI: Advanced Echo',
      'range': 'Levels 51–60',
      'startLevel': 51,
      'endLevel': 60,
    },
    {
      'id': 7,
      'roman': 'VII',
      'tag': 'Paradox',
      'fullTitle': 'Chapter VII: Spatial Paradoxes',
      'range': 'Levels 61–70',
      'startLevel': 61,
      'endLevel': 70,
    },
    {
      'id': 8,
      'roman': 'VIII',
      'tag': 'Engines',
      'fullTitle': 'Chapter VIII: Temporal Machines',
      'range': 'Levels 71–80',
      'startLevel': 71,
      'endLevel': 80,
    },
    {
      'id': 9,
      'roman': 'IX',
      'tag': 'Mastery',
      'fullTitle': 'Chapter IX: Mastery',
      'range': 'Levels 81–90',
      'startLevel': 81,
      'endLevel': 90,
    },
    {
      'id': 10,
      'roman': 'X',
      'tag': 'The Finale',
      'fullTitle': 'Chapter X: The Final Shift',
      'range': 'Levels 91–100',
      'startLevel': 91,
      'endLevel': 100,
    },
    {
      'id': 11,
      'roman': 'XI',
      'tag': 'Harmonic',
      'fullTitle': 'Chapter XI: Harmonic Resonance',
      'range': 'Levels 101–110',
      'startLevel': 101,
      'endLevel': 110,
    },
    {
      'id': 12,
      'roman': 'XII',
      'tag': 'Quantum',
      'fullTitle': 'Chapter XII: Quantum Entanglement',
      'range': 'Levels 111–120',
      'startLevel': 111,
      'endLevel': 120,
    },
    {
      'id': 13,
      'roman': 'XIII',
      'tag': 'Nexus',
      'fullTitle': 'Chapter XIII: The Echo Nexus',
      'range': 'Levels 121–130',
      'startLevel': 121,
      'endLevel': 130,
    },
    {
      'id': 14,
      'roman': 'XIV',
      'tag': 'Chrono',
      'fullTitle': 'Chapter XIV: Chrono Dynamics',
      'range': 'Levels 131–140',
      'startLevel': 131,
      'endLevel': 140,
    },
    {
      'id': 15,
      'roman': 'XV',
      'tag': 'Singularity',
      'fullTitle': 'Chapter XV: The Singularity',
      'range': 'Levels 141–150',
      'startLevel': 141,
      'endLevel': 150,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedChapter = ((widget.currentLevelId - 1) ~/ 10) + 1;
    if (_selectedChapter < 1) _selectedChapter = 1;
    if (_selectedChapter > 15) _selectedChapter = 15;
  }

  Widget _buildChapterTab(Map<String, dynamic> ch, bool isLastInRow) {
    final chId = ch['id'] as int;
    final isSelected = chId == _selectedChapter;
    final chStart = ch['startLevel'] as int;
    final isChapterUnlocked = widget.progress.isLevelUnlocked(chStart);

    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: isLastInRow ? 0 : 5),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedChapter = chId;
              });
            },
            borderRadius: BorderRadius.circular(9),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF38BDF8).withValues(alpha: 0.18)
                    : const Color(0xFF1E293B).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFF334155),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isChapterUnlocked) ...[
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 10,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 2),
                      ],
                      Text(
                        ch['roman'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF38BDF8)
                              : (isChapterUnlocked
                                  ? Colors.white
                                  : const Color(0xFF64748B)),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    ch['tag'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFE0F2FE)
                          : (isChapterUnlocked
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF475569)),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.progress.completedLevels.length;
    int totalStars = 0;
    for (int i = 1; i <= LevelDefinitions.totalLevels; i++) {
      totalStars += widget.progress.getStars(i);
    }

    final chapterData = _chapters[_selectedChapter - 1];
    final startLevel = chapterData['startLevel'] as int;
    final endLevel = chapterData['endLevel'] as int;

    // Calculate chapter stats
    int chapterCompleted = 0;
    int chapterStars = 0;
    for (int i = startLevel; i <= endLevel; i++) {
      if (widget.progress.isLevelCompleted(i)) chapterCompleted++;
      chapterStars += widget.progress.getStars(i);
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 680),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                blurRadius: 28,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Color(0x90000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 14, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: Color(0xFF38BDF8),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CAMPAIGN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$completedCount/${LevelDefinitions.totalLevels} Solved  ·  ★ $totalStars/${LevelDefinitions.totalLevels * 3}',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: const Color(0xFF94A3B8),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),

              // 15-Chapter 3-Row Segmented Selector
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: Chapters I to V
                    Row(
                      children: List.generate(5, (index) {
                        return _buildChapterTab(_chapters[index], index == 4);
                      }),
                    ),
                    const SizedBox(height: 4),
                    // Row 2: Chapters VI to X
                    Row(
                      children: List.generate(5, (index) {
                        return _buildChapterTab(_chapters[index + 5], index == 4);
                      }),
                    ),
                    const SizedBox(height: 4),
                    // Row 3: Chapters XI to XV
                    Row(
                      children: List.generate(5, (index) {
                        return _buildChapterTab(_chapters[index + 10], index == 4);
                      }),
                    ),
                  ],
                ),
              ),

              // Chapter Sub-Header Banner
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        chapterData['fullTitle'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      '${chapterData['range']}  ·  $chapterCompleted/10  ★ $chapterStars/30',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Color(0xFF1E293B), height: 1),

              // Level Cards List for Active Chapter
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  itemCount: endLevel - startLevel + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final levelId = startLevel + index;
                    final level = LevelDefinitions.getLevel(levelId);
                    final isUnlocked = widget.progress.isLevelUnlocked(levelId);
                    final isCompleted = widget.progress.isLevelCompleted(levelId);
                    final isCurrent = levelId == widget.currentLevelId;
                    final bestMoves = widget.progress.getBestMoves(levelId);
                    final stars = widget.progress.getStars(levelId);

                    return _buildLevelTile(
                      context: context,
                      levelId: levelId,
                      title: level.title,
                      optimalMoves: level.optimalMoves,
                      hasEcho: level.hasMemoryEcho,
                      isUnlocked: isUnlocked,
                      isCompleted: isCompleted,
                      isCurrent: isCurrent,
                      bestMoves: bestMoves,
                      stars: stars,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelTile({
    required BuildContext context,
    required int levelId,
    required String title,
    required int optimalMoves,
    required bool hasEcho,
    required bool isUnlocked,
    required bool isCompleted,
    required bool isCurrent,
    required int? bestMoves,
    required int stars,
  }) {
    Color borderColor;
    Color bgColor;

    if (!isUnlocked) {
      borderColor = const Color(0xFF1E293B);
      bgColor = const Color(0xFF0B101D);
    } else if (isCurrent) {
      borderColor = const Color(0xFF38BDF8);
      bgColor = const Color(0xFF1E293B);
    } else if (isCompleted) {
      borderColor = const Color(0xFF334155);
      bgColor = const Color(0xFF131D2E);
    } else {
      borderColor = const Color(0xFF334155);
      bgColor = const Color(0xFF1E293B);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isUnlocked
            ? () {
                Navigator.of(context).pop();
                widget.onSelectLevel(levelId);
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: isCurrent ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Level number indicator
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? (isCurrent
                          ? const Color(0xFF38BDF8).withValues(alpha: 0.2)
                          : const Color(0xFF334155).withValues(alpha: 0.5))
                      : const Color(0xFF1E293B).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: isUnlocked
                      ? Text(
                          '$levelId',
                          style: TextStyle(
                            color: isCurrent
                                ? const Color(0xFF38BDF8)
                                : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : const Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and tags
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isUnlocked ? Colors.white : const Color(0xFF64748B),
                              fontSize: 13,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (hasEcho) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7E22CE).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: const Color(0xFFA855F7).withValues(alpha: 0.5),
                                width: 0.8,
                              ),
                            ),
                            child: const Text(
                              'ECHO',
                              style: TextStyle(
                                color: Color(0xFFE9D5FF),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (isCompleted && bestMoves != null)
                      Text(
                        'Best: $bestMoves moves (Par: $optimalMoves)',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else if (isUnlocked)
                      Text(
                        isCurrent ? 'Playing Now' : 'Par: $optimalMoves moves',
                        style: TextStyle(
                          color: isCurrent ? const Color(0xFF38BDF8) : const Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      const Text(
                        'Locked',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),

              // Stars rating badge
              if (isCompleted)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final earned = i < stars;
                    return Icon(
                      earned ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 16,
                      color: earned ? const Color(0xFFFBBF24) : const Color(0xFF334155),
                    );
                  }),
                )
              else if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PLAY',
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
