import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../core/analytics/analytics_service.dart';
import '../core/feedback/game_feedback.dart';
import '../core/monetization/ad_service.dart';
import '../core/puzzle/levels/level_definitions.dart';
import '../core/puzzle/logic/puzzle_engine.dart';
import '../core/puzzle/logic/puzzle_solver.dart';
import '../core/puzzle/models/shift_direction.dart';
import '../core/storage/player_progress.dart';
import '../game/scenes/shift_puzzle_game.dart';
import 'game_controls.dart';
import 'game_header.dart';
import 'level_select_dialog.dart';
import 'optimal_drift_nudge_dialog.dart';
import 'win_dialog.dart';
import 'widgets/tutorial_overlay.dart';

class GameScreen extends StatefulWidget {
  final PlayerProgress? progress;
  final AdService adService;
  final AnalyticsService analytics;

  GameScreen({
    super.key,
    this.progress,
    AdService? adService,
    AnalyticsService? analytics,
  })  : adService = adService ?? NoOpAdService(),
        analytics = analytics ?? const DebugAnalyticsService();

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentLevelId = 1;
  late PuzzleEngine _engine;
  late ShiftPuzzleGame _game;
  PlayerProgress? _progress;
  GameFeedback? _feedback;

  Offset _panStart = Offset.zero;
  Offset _panCurrent = Offset.zero;
  bool _isWinDialogShowing = false;
  bool _isModalShowing = false;
  bool _isTutorialDismissed = false;

  bool get _showTutorialOverlay {
    final isCompleted = _progress?.isTutorialCompleted ?? false;
    return !isCompleted &&
        (_currentLevelId == 1 || _currentLevelId == 2) &&
        !_isTutorialDismissed;
  }

  int _currentLevelRestartCount = 0;
  int _currentLevelUndoCount = 0;
  int _failedEchoAttempts = 0;
  bool _usedHintOnCurrentLevel = false;
  bool _optimalDriftNudgeShown = false;
  bool _optimalDriftDetected = false;

  bool get _isStruggling {
    final level = LevelDefinitions.getLevel(_currentLevelId);
    return _currentLevelRestartCount >= 2 ||
        _currentLevelUndoCount >= 3 ||
        _failedEchoAttempts >= 2 ||
        (_engine.moveCount >= level.optimalMoves + 3);
  }

  void _dismissTutorial() {
    if (!_isTutorialDismissed) {
      setState(() {
        _isTutorialDismissed = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.progress != null) {
      _progress = widget.progress;
      _feedback = GameFeedback(_progress!);
      _currentLevelId = _progress!.lastPlayedLevel.clamp(1, LevelDefinitions.totalLevels);
    } else {
      PlayerProgress.initialize().then((p) {
        if (mounted) {
          setState(() {
            _progress = p;
            _feedback = GameFeedback(_progress!);
            final target = p.lastPlayedLevel.clamp(1, LevelDefinitions.totalLevels);
            if (target != _currentLevelId && p.isLevelUnlocked(target)) {
              _switchLevel(target);
            }
          });
        }
      });
    }

    widget.analytics.logGameStarted(
      highestUnlockedLevel: _progress?.highestUnlockedLevel ?? 1,
    );

    _loadLevel(_currentLevelId);
  }

  void _loadLevel(int levelId) {
    _currentLevelId = levelId;
    _isTutorialDismissed = false;
    _currentLevelRestartCount = 0;
    _currentLevelUndoCount = 0;
    _failedEchoAttempts = 0;
    _usedHintOnCurrentLevel = false;
    _optimalDriftNudgeShown = false;
    _optimalDriftDetected = false;
    _isModalShowing = false;
    final level = LevelDefinitions.getLevel(_currentLevelId);
    _engine = PuzzleEngine(level);

    if (!(_progress?.isTutorialCompleted ?? false) && (levelId == 1 || levelId == 2)) {
      widget.analytics.logTutorialStarted(levelId);
    }

    widget.analytics.logLevelStarted(levelId);

    _game = ShiftPuzzleGame(
      engine: _engine,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
      onLevelSolved: _handleLevelSolved,
      onShiftComplete: (isEcho, justSeated) {
        if (isEcho) {
          _feedback?.playEchoShift();
        } else {
          _feedback?.playShift();
        }
        if (justSeated) {
          _feedback?.playPieceSeated();
        }
        _checkOptimalDriftNudge();
      },
    );
  }

  void _switchLevel(int levelId) {
    if (levelId < 1 || levelId > LevelDefinitions.totalLevels) return;

    final prevChapter = LevelDefinitions.getLevel(_currentLevelId).chapter;
    final newChapter = LevelDefinitions.getLevel(levelId).chapter;
    if (newChapter > prevChapter) {
      widget.analytics.logChapterUnlocked(newChapter);
    }

    _isTutorialDismissed = false;
    _currentLevelRestartCount = 0;
    _currentLevelUndoCount = 0;
    _failedEchoAttempts = 0;
    _usedHintOnCurrentLevel = false;
    _optimalDriftNudgeShown = false;
    _optimalDriftDetected = false;
    _isModalShowing = false;
    if (levelId > 2 && !(_progress?.isTutorialCompleted ?? false)) {
      _progress?.setTutorialCompleted();
      widget.analytics.logTutorialCompleted(_currentLevelId);
    } else if (!(_progress?.isTutorialCompleted ?? false) && (levelId == 1 || levelId == 2)) {
      widget.analytics.logTutorialStarted(levelId);
    }

    setState(() {
      _currentLevelId = levelId;
      _progress?.setLastPlayedLevel(levelId);
      final level = LevelDefinitions.getLevel(_currentLevelId);
      _engine = PuzzleEngine(level);
      _game.updateEngine(_engine);
    });

    widget.analytics.logLevelStarted(levelId);
  }

  void _restartCurrentLevel() {
    _currentLevelRestartCount++;
    _optimalDriftNudgeShown = false;
    _optimalDriftDetected = false;
    _failedEchoAttempts = 0;
    _usedHintOnCurrentLevel = false;
    _isModalShowing = false;
    widget.analytics.logLevelRestarted(_currentLevelId);
    setState(() {
      _engine.reset();
      _game.updateEngine(_engine);
    });
  }

  void _handleUndo() {
    if (_game.isAnimating ||
        _game.isEchoReplaying ||
        !_engine.canUndo ||
        _isWinDialogShowing) {
      return;
    }
    _currentLevelUndoCount++;
    widget.analytics.logUndoUsed(_currentLevelId, _engine.moveCount);
    setState(() {
      _engine.undo();
      _feedback?.playUndo();
      _game.updateEngine(_engine);
    });
  }

  void _toggleSound() {
    final next = !(_progress?.isSoundEnabled ?? true);
    _progress?.setSoundEnabled(next);
    widget.analytics.logSoundToggled(next);
    setState(() {});
  }

  void _openLevelSelect() {
    if (_progress == null) return;
    _isModalShowing = true;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => LevelSelectDialog(
        currentLevelId: _currentLevelId,
        progress: _progress!,
        onSelectLevel: _switchLevel,
      ),
    ).then((_) {
      _isModalShowing = false;
    });
  }

  void _handleLevelSolved() {
    if (_isWinDialogShowing || !mounted) return;
    _isWinDialogShowing = true;
    _isModalShowing = true;
    _feedback?.playLevelComplete();

    final level = LevelDefinitions.getLevel(_currentLevelId);
    int stars = 3;
    if (level.optimalMoves > 0) {
      if (_engine.moveCount <= level.optimalMoves) {
        stars = 3;
      } else if (_engine.moveCount <= level.optimalMoves + 2) {
        stars = 2;
      } else {
        stars = 1;
      }
    }

    final saveFuture = _progress?.recordLevelCompletion(
          levelId: _currentLevelId,
          moveCount: _engine.moveCount,
          stars: stars,
          totalLevels: LevelDefinitions.totalLevels,
        ) ??
        Future.value(false);

    if (_currentLevelId >= 2 && !(_progress?.isTutorialCompleted ?? false)) {
      _progress?.setTutorialCompleted();
      widget.analytics.logTutorialCompleted(_currentLevelId);
    }

    saveFuture.then((isNewBest) {
      widget.analytics.logLevelCompleted(
        levelId: _currentLevelId,
        moves: _engine.moveCount,
        optimalMoves: level.optimalMoves,
        stars: stars,
        isNewBest: isNewBest,
      );

      if (_usedHintOnCurrentLevel) {
        widget.analytics.logLevelCompletedWithHint(
          levelId: _currentLevelId,
          moves: _engine.moveCount,
          optimalMoves: level.optimalMoves,
          stars: stars,
        );
      }

      if (_optimalDriftDetected || _engine.moveCount > level.optimalMoves) {
        widget.analytics.logLevelCompletedAfterOptimalDrift(
          levelId: _currentLevelId,
          moves: _engine.moveCount,
          optimalMoves: level.optimalMoves,
          stars: stars,
        );
      }

      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 380), () {
        if (!mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withValues(alpha: 0.65),
          builder: (ctx) => WinDialog(
            levelId: _currentLevelId,
            moveCount: _engine.moveCount,
            optimalMoves: level.optimalMoves,
            hasNextLevel: _currentLevelId < LevelDefinitions.totalLevels,
            isNewBest: isNewBest,
            onNextLevel: () {
              Navigator.of(ctx).pop();
              _isWinDialogShowing = false;
              _isModalShowing = false;
              final nextLevel = _currentLevelId + 1;

              widget.adService.showInterstitialIfAppropriate(
                levelId: _currentLevelId,
                completedLevelCount: _progress?.completedLevels.length ?? 0,
              );

              _switchLevel(nextLevel);
            },
            onReplay: () {
              Navigator.of(ctx).pop();
              _isWinDialogShowing = false;
              _isModalShowing = false;
              _restartCurrentLevel();
            },
          ),
        ).then((_) {
          _isWinDialogShowing = false;
          _isModalShowing = false;
        });
      });
    });
  }

  void _handleEchoAction() {
    if (_game.isAnimating ||
        _game.isEchoReplaying ||
        _engine.isSolved ||
        _isWinDialogShowing) {
      return;
    }

    if (_engine.echo.isIdle) {
      setState(() {
        _engine.echo.startRecording();
      });
    } else if (_engine.echo.isRecording) {
      widget.analytics.logEchoRecorded(_currentLevelId, _engine.echo.length);
      setState(() {
        _engine.echo.stopRecording();
      });
    } else if (_engine.echo.canReplay) {
      widget.analytics.logEchoReplayed(_currentLevelId, _engine.echo.length);
      _triggerEcho();
    }
  }

  void _discardEcho() {
    if (_game.isAnimating ||
        _game.isEchoReplaying ||
        _engine.isSolved ||
        _isWinDialogShowing) {
      return;
    }
    setState(() {
      _engine.echo.clear();
      _feedback?.playDiscard();
    });
  }

  void _triggerEcho() {
    if (_game.isAnimating ||
        _game.isEchoReplaying ||
        _engine.isSolved ||
        !_engine.echo.canReplay) {
      return;
    }
    _game.triggerEchoReplay(() {
      if (mounted) {
        if (!_engine.isSolved) {
          _failedEchoAttempts++;
        }
        setState(() {});
      }
    });
    setState(() {});
  }

  void _onPanStart(DragStartDetails details) {
    if (_showTutorialOverlay) {
      _dismissTutorial();
    }
    _panStart = details.localPosition;
    _panCurrent = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _panCurrent = details.localPosition;
  }

  void _onPanEnd(DragEndDetails details) {
    if (_game.isAnimating || _game.isEchoReplaying || _isWinDialogShowing) return;

    final dx = _panCurrent.dx - _panStart.dx;
    final dy = _panCurrent.dy - _panStart.dy;
    const minSwipeDistance = 24.0;

    if (dx.abs() < minSwipeDistance && dy.abs() < minSwipeDistance) return;

    if (dx.abs() > dy.abs()) {
      final row = _game.getRowAt(_panStart);
      if (row != null) {
        final dir = dx > 0 ? ShiftDirection.right : ShiftDirection.left;
        _game.triggerShiftRow(row, dir);
      }
    } else {
      final col = _game.getColAt(_panStart);
      if (col != null) {
        final dir = dy > 0 ? ShiftDirection.down : ShiftDirection.up;
        _game.triggerShiftColumn(col, dir);
      }
    }
  }

  void _handleRequestHint() {
    if (_game.isAnimating ||
        _game.isEchoReplaying ||
        _engine.isSolved ||
        _isWinDialogShowing) {
      return;
    }

    if (_game.activeHint != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hint is already visible on the board!'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF1E293B),
        ),
      );
      return;
    }

    _isModalShowing = true;
    widget.analytics.logHintOffered(_currentLevelId);
    widget.analytics.logHintButtonViewed(_currentLevelId, isStruggling: _isStruggling);

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFFBBF24).withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFBBF24).withValues(alpha: 0.18),
                blurRadius: 28,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Color(0x90000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFFFBBF24),
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'NEED A HINT?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Watch a short video ad to reveal the next optimal move.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        widget.analytics.logHintCancelled(_currentLevelId);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF94A3B8),
                        side: const BorderSide(color: Color(0xFF334155)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('NOT NOW', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        widget.analytics.logHintRequested(_currentLevelId);
                        _executeRewardedAdForHint(source: 'manual_hint');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: const Color(0xFF0F172A),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'WATCH AD',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      _isModalShowing = false;
    });
  }

  void _checkOptimalDriftNudge() {
    final level = LevelDefinitions.getLevel(_currentLevelId);
    if (!level.isOptimalDriftNudgeEnabled) return;
    if (_optimalDriftNudgeShown) return;
    if (_engine.isSolved) return;
    if (_isWinDialogShowing || _isModalShowing) return;
    if (_game.isAnimating || _game.isEchoReplaying) return;
    if (_engine.echo.isRecording) return;
    if (_game.activeHint != null) return;

    if (_engine.moveCount == level.optimalMoves + 1) {
      _optimalDriftDetected = true;
      _optimalDriftNudgeShown = true;

      widget.analytics.logOptimalDriftDetected(
        levelId: _currentLevelId,
        chapterId: level.chapter,
        hasMemoryEcho: level.hasMemoryEcho,
        moveCount: _engine.moveCount,
        optimalMoves: level.optimalMoves,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_engine.isSolved || _isWinDialogShowing || _isModalShowing) return;
        if (_game.isAnimating || _game.isEchoReplaying) return;
        _showOptimalDriftNudgeDialog();
      });
    }
  }

  void _showOptimalDriftNudgeDialog() {
    final level = LevelDefinitions.getLevel(_currentLevelId);
    _isModalShowing = true;

    widget.analytics.logOptimalDriftNudgeShown(
      levelId: _currentLevelId,
      chapterId: level.chapter,
      hasMemoryEcho: level.hasMemoryEcho,
      moveCount: _engine.moveCount,
      optimalMoves: level.optimalMoves,
    );

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => OptimalDriftNudgeDialog(
        levelId: _currentLevelId,
        moveCount: _engine.moveCount,
        optimalMoves: level.optimalMoves,
        onKeepSolving: () {
          Navigator.of(ctx).pop();
          widget.analytics.logOptimalDriftKeepSolving(
            levelId: _currentLevelId,
            moveCount: _engine.moveCount,
          );
        },
        onWatchAd: () {
          Navigator.of(ctx).pop();
          widget.analytics.logOptimalDriftHintRequested(
            levelId: _currentLevelId,
            moveCount: _engine.moveCount,
          );
          _executeRewardedAdForHint(source: 'optimal_drift');
        },
      ),
    ).then((_) {
      _isModalShowing = false;
    });
  }

  void _executeRewardedAdForHint({String source = 'manual_hint'}) {
    final placement = source == 'optimal_drift'
        ? 'optimal_drift_level_$_currentLevelId'
        : 'hint_level_$_currentLevelId';
    widget.analytics.logRewardedAdRequested(placement);
    if (source == 'optimal_drift') {
      widget.analytics.logOptimalDriftAdStarted(
        levelId: _currentLevelId,
        placement: placement,
      );
    }

    widget.adService.showRewardedAd(
      placement: placement,
      onRewardEarned: () {
        widget.analytics.logRewardedAdCompleted(placement);
        if (source == 'optimal_drift') {
          widget.analytics.logOptimalDriftAdRewarded(
            levelId: _currentLevelId,
            placement: placement,
          );
        }
        final level = LevelDefinitions.getLevel(_currentLevelId);
        final nextMove = PuzzleSolver.getNextBestMove(_engine.currentGrid, level);

        if (!mounted) return;
        if (nextMove != null) {
          widget.analytics.logHintGranted(_currentLevelId);
          widget.analytics.logHintCompleted(_currentLevelId);
          if (source == 'optimal_drift') {
            widget.analytics.logOptimalDriftHintRevealed(
              levelId: _currentLevelId,
              moveCount: _engine.moveCount,
            );
          }
          _usedHintOnCurrentLevel = true;
          setState(() {
            _game.setHint(nextMove);
          });
          _feedback?.playPieceSeated();
          widget.analytics.logHintUsed(_currentLevelId);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Hint: Shift ${nextMove.isRow ? 'Row' : 'Column'} ${nextMove.index + 1} ${nextMove.direction.name.toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFFEF3C7)),
              ),
              backgroundColor: const Color(0xFF78350F),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          widget.analytics.logHintFailed(_currentLevelId, 'already_at_solution');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are already close to the solution!'),
              backgroundColor: Color(0xFF1E293B),
            ),
          );
        }
      },
    ).then((rewardEarned) {
      if (!rewardEarned && mounted) {
        if (source == 'optimal_drift') {
          widget.analytics.logOptimalDriftAdFailed(
            levelId: _currentLevelId,
            placement: placement,
            reason: 'ad_not_completed',
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad was not completed. Keep solving!'),
            backgroundColor: Color(0xFF1E293B),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final level = LevelDefinitions.getLevel(_currentLevelId);
    final isSoundOn = _progress?.isSoundEnabled ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(
              levelId: _currentLevelId,
              levelTitle: level.title,
              moveCount: _engine.moveCount,
              optimalMoves: level.optimalMoves,
              isSoundEnabled: isSoundOn,
              onToggleSound: _toggleSound,
              onOpenLevelSelect: _openLevelSelect,
            ),
            if (level.hint != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Text(
                  level.hint!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            GameWidget(game: _game),
                            if (_showTutorialOverlay)
                              TutorialOverlay(
                                levelId: _currentLevelId,
                                onDismiss: _dismissTutorial,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            GameControls(
              onRestart: _restartCurrentLevel,
              onPreviousLevel: _currentLevelId > 1
                  ? () => _switchLevel(_currentLevelId - 1)
                  : null,
              onNextLevel: _currentLevelId < LevelDefinitions.totalLevels
                  ? () => _switchLevel(_currentLevelId + 1)
                  : null,
              hasPrevious: _currentLevelId > 1,
              hasNext: _currentLevelId < LevelDefinitions.totalLevels,
              showEchoButton: level.hasMemoryEcho,
              echoStatus: _engine.echo.status,
              echoCount: _engine.echo.length,
              isBoardBusy: _game.isAnimating || _game.isEchoReplaying,
              canUndo: _engine.canUndo &&
                  !_game.isAnimating &&
                  !_game.isEchoReplaying &&
                  !_engine.isSolved,
              onUndo: _handleUndo,
              onEchoAction: _handleEchoAction,
              onDiscardEcho: _discardEcho,
              onHint: _handleRequestHint,
              isHintActive: _game.activeHint != null,
              isStruggling: _isStruggling,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
