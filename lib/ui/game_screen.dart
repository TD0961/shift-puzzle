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
import '../core/connectivity/connectivity_service.dart';
import 'hint_unavailable_dialog.dart';
import 'internet_needed_dialog.dart';
import 'move_limit_dialog.dart';
import 'optimal_drift_nudge_dialog.dart';
import '../core/sharing/share_service.dart';
import 'win_dialog.dart';
import 'widgets/tutorial_overlay.dart';

class GameScreen extends StatefulWidget {
  final PlayerProgress? progress;
  final AdService adService;
  final AnalyticsService analytics;
  final ConnectivityService connectivityService;
  final ShareService shareService;

  GameScreen({
    super.key,
    this.progress,
    AdService? adService,
    AnalyticsService? analytics,
    ConnectivityService? connectivityService,
    ShareService? shareService,
  })  : adService = adService ?? NoOpAdService(),
        analytics = analytics ?? const DebugAnalyticsService(),
        connectivityService = connectivityService ?? const NetworkConnectivityService(),
        shareService = shareService ?? const ClipboardShareService();

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
  bool _isRequestingAd = false;
  bool _isTutorialDismissed = false;

  bool get _showTutorialOverlay {
    final isCompleted = _progress?.isTutorialCompleted ?? false;
    return !isCompleted &&
        (_currentLevelId == 1 || _currentLevelId == 2) &&
        !_isTutorialDismissed;
  }

  int _attemptNumber = 1;
  int _sessionNumber = 1;
  late final DateTime _sessionStartTime;

  int _currentLevelRestartCount = 0;
  int _currentLevelUndoCount = 0;
  int _failedEchoAttempts = 0;
  bool _usedHintOnCurrentLevel = false;
  bool _optimalDriftNudgeShown = false;
  bool _optimalDriftDetected = false;

  bool _extraMoveExtensionUsed = false;
  int _extraMovesGranted = 0;
  bool _isMoveLimitReached = false;
  bool _isMoveLimitDialogShowing = false;
  bool _undoLockExplanationShown = false;

  int get _normalMoveLimit {
    final level = LevelDefinitions.getLevel(_currentLevelId);
    return level.optimalMoves > 0 ? level.optimalMoves + 2 : 999;
  }

  int get _currentMoveLimit => _normalMoveLimit + _extraMovesGranted;

  bool get _canUndo =>
      !_game.isAnimating &&
      !_game.isEchoReplaying &&
      !_isWinDialogShowing &&
      !_isMoveLimitReached &&
      _engine.canUndo;

  bool get _isStruggling {
    final level = LevelDefinitions.getLevel(_currentLevelId);
    return _currentLevelRestartCount >= 2 ||
        _currentLevelUndoCount >= 3 ||
        _failedEchoAttempts >= 2 ||
        (_engine.moveCount >= level.optimalMoves + 2);
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
    _sessionStartTime = DateTime.now();
    if (widget.progress != null) {
      _progress = widget.progress;
      _feedback = GameFeedback(_progress!);
      _currentLevelId = _progress!.lastPlayedLevel.clamp(1, LevelDefinitions.totalLevels);
      _setupAnalyticsAndSession(_progress!);
    } else {
      PlayerProgress.initialize().then((p) {
        if (mounted) {
          setState(() {
            _progress = p;
            _feedback = GameFeedback(_progress!);
            _setupAnalyticsAndSession(p);
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

  void _setupAnalyticsAndSession(PlayerProgress p) {
    widget.analytics.setAnonymousContext(
      installationId: p.installationId,
      acquisitionSource: p.acquisitionSource,
    );
    widget.analytics.logAppOpen(source: p.acquisitionSource);
    if (p.isFirstLaunch) {
      widget.analytics.logFirstLaunch(source: p.acquisitionSource);
    }
    p.incrementSessionCount().then((sNum) {
      _sessionNumber = sNum;
      widget.analytics.logSessionStart(
        sessionNumber: _sessionNumber,
        source: p.acquisitionSource,
      );
    });
  }

  @override
  void dispose() {
    widget.analytics.logSessionEnd(
      sessionNumber: _sessionNumber,
      durationSeconds: DateTime.now().difference(_sessionStartTime).inSeconds,
    );
    super.dispose();
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
    _extraMoveExtensionUsed = false;
    _extraMovesGranted = 0;
    _isMoveLimitReached = false;
    _isMoveLimitDialogShowing = false;
    _undoLockExplanationShown = false;
    _isModalShowing = false;
    final level = LevelDefinitions.getLevel(_currentLevelId);
    _engine = PuzzleEngine(level);

    if (!(_progress?.isTutorialCompleted ?? false) && (levelId == 1 || levelId == 2)) {
      widget.analytics.logTutorialStarted(levelId);
    }

    widget.analytics.logLevelStart(
      levelId: levelId,
      chapterId: level.chapterId,
      attemptNumber: _attemptNumber,
    );
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
        if (_engine.isSolved) {
          return;
        }
        _checkOptimalDriftNudge();
        _checkMoveLimit();
      },
    );
  }

  void _switchLevel(int levelId) {
    if (levelId < 1 || levelId > LevelDefinitions.totalLevels) return;
    if (_progress != null && !_progress!.isLevelUnlocked(levelId)) return;

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
    _extraMoveExtensionUsed = false;
    _extraMovesGranted = 0;
    _isMoveLimitReached = false;
    _isMoveLimitDialogShowing = false;
    _undoLockExplanationShown = false;
    _isModalShowing = false;
    if (levelId > 2 && !(_progress?.isTutorialCompleted ?? false)) {
      _progress?.setTutorialCompleted();
      widget.analytics.logTutorialCompleted(_currentLevelId);
    } else if (!(_progress?.isTutorialCompleted ?? false) && (levelId == 1 || levelId == 2)) {
      widget.analytics.logTutorialStarted(levelId);
    }

    setState(() {
      _currentLevelId = levelId;
      _attemptNumber = 1;
      _progress?.setLastPlayedLevel(levelId);
      final level = LevelDefinitions.getLevel(_currentLevelId);
      _engine = PuzzleEngine(level);
      _game.updateEngine(_engine);
    });

    widget.analytics.logLevelStart(
      levelId: levelId,
      chapterId: LevelDefinitions.getLevel(levelId).chapterId,
      attemptNumber: _attemptNumber,
    );
    widget.analytics.logLevelStarted(levelId);
  }

  void _restartCurrentLevel() {
    _attemptNumber++;
    _currentLevelRestartCount++;
    _optimalDriftNudgeShown = false;
    _optimalDriftDetected = false;
    _failedEchoAttempts = 0;
    _usedHintOnCurrentLevel = false;
    _extraMoveExtensionUsed = false;
    _extraMovesGranted = 0;
    _isMoveLimitReached = false;
    _isMoveLimitDialogShowing = false;
    _undoLockExplanationShown = false;
    _isModalShowing = false;
    widget.analytics.logLevelRestart(
      levelId: _currentLevelId,
      chapterId: LevelDefinitions.getLevel(_currentLevelId).chapterId,
    );
    widget.analytics.logLevelRestarted(_currentLevelId);
    setState(() {
      _engine.reset();
      _game.updateEngine(_engine);
    });
  }

  void _handleUndo() {
    if (!_canUndo) {
      _handleUndoDisabled();
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

  void _handleUndoDisabled() {
    final level = LevelDefinitions.getLevel(_currentLevelId);
    if ((_engine.isUndoLocked || _engine.moveCount >= level.optimalMoves) &&
        !_undoLockExplanationShown) {
      _undoLockExplanationShown = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Undo is available before reaching the optimal move count.'),
          backgroundColor: Color(0xFF1E293B),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
      widget.analytics.logLevelComplete(
        levelId: _currentLevelId,
        chapterId: level.chapterId,
        movesUsed: _engine.moveCount,
        parMoves: level.optimalMoves,
        stars: stars,
      );
      if (_currentLevelId % 10 == 0) {
        widget.analytics.logChapterComplete(level.chapterId);
      }

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

      if (_extraMoveExtensionUsed) {
        widget.analytics.logLevelCompletedAfterExtraMoves(
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
            onShare: () async {
              widget.analytics.logShareClicked(
                placement: 'win_dialog',
                levelId: _currentLevelId,
              );
              final shared = await widget.shareService.shareLevelChallenge(
                levelId: _currentLevelId,
                moves: _engine.moveCount,
                stars: stars,
              );
              if (shared && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Challenge copied to clipboard! Share it with friends.'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            onSupport: (widget.adService is BootstrapAdService &&
                    (widget.adService as BootstrapAdService).isBootstrapLinkAvailable)
                ? () {
                    (widget.adService as BootstrapAdService).openBootstrapLink();
                  }
                : null,
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
    if (_isMoveLimitReached) {
      if (!_isMoveLimitDialogShowing && !_isModalShowing) {
        _showMoveLimitDialog();
      }
      return;
    }
    if (_showTutorialOverlay) {
      _dismissTutorial();
    }
    _panStart = details.localPosition;
    _panCurrent = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isMoveLimitReached) return;
    _panCurrent = details.localPosition;
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isMoveLimitReached || _game.isAnimating || _game.isEchoReplaying || _isWinDialogShowing) return;

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

  void _handleRequestHint() async {
    if (_game.isAnimating ||
        _game.isEchoReplaying ||
        _engine.isSolved ||
        _isWinDialogShowing ||
        _isMoveLimitReached ||
        _isMoveLimitDialogShowing ||
        _isModalShowing ||
        _isRequestingAd) {
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

    _isRequestingAd = true;
    final isOnline = await widget.connectivityService.hasInternetConnection();
    _isRequestingAd = false;
    if (!mounted) return;

    if (!isOnline) {
      widget.analytics.logHintNetworkUnavailable(_currentLevelId, source: 'manual_hint');
      _showInternetNeededDialog(source: 'manual_hint');
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

  void _executeRewardedAdForHint({String source = 'manual_hint'}) async {
    if (_isRequestingAd) return;
    _isRequestingAd = true;

    final placement = source == 'optimal_drift'
        ? 'optimal_drift_level_$_currentLevelId'
        : 'hint_level_$_currentLevelId';

    // 1. Connectivity check
    final isOnline = await widget.connectivityService.hasInternetConnection();
    if (!mounted) {
      _isRequestingAd = false;
      return;
    }

    if (!isOnline) {
      _isRequestingAd = false;
      if (source == 'optimal_drift') {
        widget.analytics.logOptimalDriftAdFailed(
          levelId: _currentLevelId,
          placement: placement,
          reason: 'network_unavailable',
        );
      }
      widget.analytics.logHintNetworkUnavailable(_currentLevelId, source: source);
      _showInternetNeededDialog(source: source);
      return;
    }

    // 2. Check if ad is ready, or wait briefly if loading
    if (!widget.adService.isRewardedAdReady) {
      await widget.adService.preloadRewardedAd();
      for (int i = 0; i < 4 && !widget.adService.isRewardedAdReady && mounted; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    }

    if (!mounted) {
      _isRequestingAd = false;
      return;
    }

    if (!widget.adService.isRewardedAdReady) {
      _isRequestingAd = false;
      if (source == 'optimal_drift') {
        widget.analytics.logOptimalDriftAdFailed(
          levelId: _currentLevelId,
          placement: placement,
          reason: 'ad_unavailable',
        );
      }
      widget.analytics.logHintAdUnavailable(_currentLevelId, source: source);
      _showHintUnavailableDialog(source: source);
      return;
    }

    // 3. Ad is ready - show it
    widget.analytics.logRewardedAdRequested(placement);
    widget.analytics.logHintAdStarted(_currentLevelId, placement: placement, source: source);
    if (source == 'optimal_drift') {
      widget.analytics.logOptimalDriftAdStarted(
        levelId: _currentLevelId,
        placement: placement,
      );
    }

    bool rewardEarned = false;
    bool rewardDispatched = false;

    try {
      await widget.adService.showRewardedAd(
        placement: placement,
        onRewardEarned: () {
          if (rewardDispatched) return;
          rewardDispatched = true;
          rewardEarned = true;
          _grantHint(source: source, placement: placement);
        },
      );

      _isRequestingAd = false;
      if (!rewardEarned && mounted) {
        if (source == 'optimal_drift') {
          widget.analytics.logOptimalDriftAdFailed(
            levelId: _currentLevelId,
            placement: placement,
            reason: 'ad_not_completed',
          );
        }
        widget.analytics.logHintAdFailed(
          _currentLevelId,
          placement: placement,
          reason: 'ad_not_completed',
          source: source,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad was not completed. Keep solving!'),
            backgroundColor: Color(0xFF1E293B),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _isRequestingAd = false;
      if (source == 'optimal_drift') {
        widget.analytics.logOptimalDriftAdFailed(
          levelId: _currentLevelId,
          placement: placement,
          reason: 'ad_error',
        );
      }
      widget.analytics.logHintAdFailed(
        _currentLevelId,
        placement: placement,
        reason: 'ad_error',
        source: source,
      );
      if (mounted) {
        _showHintUnavailableDialog(source: source);
      }
    }
  }

  void _grantHint({required String source, required String placement}) {
    widget.analytics.logRewardedAdCompleted(placement);
    widget.analytics.logHintAdRewarded(
      _currentLevelId,
      placement: placement,
      source: source,
    );
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
  }

  void _showInternetNeededDialog({required String source}) {
    if (_isModalShowing) return;
    _isModalShowing = true;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => InternetNeededDialog(
        onTryAgain: () async {
          final isConnected = await widget.connectivityService.hasInternetConnection();
          if (isConnected) {
            widget.analytics.logHintAdRetry(
              _currentLevelId,
              outcome: 'success',
              source: source,
            );
            if (ctx.mounted) {
              Navigator.of(ctx).pop();
            }
            if (mounted) {
              _executeRewardedAdForHint(source: source);
            }
            return true;
          } else {
            widget.analytics.logHintAdRetry(
              _currentLevelId,
              outcome: 'still_offline',
              source: source,
            );
            return false;
          }
        },
        onNotNow: () {
          Navigator.of(ctx).pop();
        },
      ),
    ).then((_) {
      _isModalShowing = false;
    });
  }

  void _showHintUnavailableDialog({required String source}) {
    if (_isModalShowing) return;
    _isModalShowing = true;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => HintUnavailableDialog(
        onTryAgain: () async {
          await widget.adService.preloadRewardedAd();
          for (int i = 0; i < 4 && !widget.adService.isRewardedAdReady && mounted; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 300));
          }
          if (widget.adService.isRewardedAdReady) {
            widget.analytics.logHintAdRetry(
              _currentLevelId,
              outcome: 'success',
              source: source,
            );
            if (ctx.mounted) {
              Navigator.of(ctx).pop();
            }
            if (mounted) {
              _executeRewardedAdForHint(source: source);
            }
            return true;
          } else {
            widget.analytics.logHintAdRetry(
              _currentLevelId,
              outcome: 'still_unavailable',
              source: source,
            );
            return false;
          }
        },
        onNotNow: () {
          Navigator.of(ctx).pop();
        },
      ),
    ).then((_) {
      _isModalShowing = false;
    });
  }

  void _checkMoveLimit() {
    if (_engine.isSolved || _isWinDialogShowing) return;
    if (_isMoveLimitDialogShowing || _isModalShowing) return;
    if (_game.isAnimating || _game.isEchoReplaying) return;

    final level = LevelDefinitions.getLevel(_currentLevelId);
    if (level.optimalMoves <= 0) return;

    if (_engine.moveCount >= _currentMoveLimit) {
      _isMoveLimitReached = true;
      widget.analytics.logLevelFailed(
        levelId: _currentLevelId,
        chapterId: level.chapterId,
        movesUsed: _engine.moveCount,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_engine.isSolved || _isWinDialogShowing) return;
        _showMoveLimitDialog();
      });
    }
  }

  void _showMoveLimitDialog() {
    if (_isMoveLimitDialogShowing || _isModalShowing || _isWinDialogShowing) return;
    _isMoveLimitDialogShowing = true;
    _isModalShowing = true;

    final level = LevelDefinitions.getLevel(_currentLevelId);
    final canExtend = !_extraMoveExtensionUsed;

    if (!canExtend) {
      widget.analytics.logMoveLimitFinalAttemptExhausted(
        levelId: _currentLevelId,
        movesUsed: _engine.moveCount,
      );
    } else {
      widget.analytics.logMoveLimitReached(
        levelId: _currentLevelId,
        chapterId: level.chapter,
        optimalMoves: level.optimalMoves,
        normalMoveLimit: _normalMoveLimit,
        movesUsed: _engine.moveCount,
        isEchoLevel: level.hasMemoryEcho,
        isExtendedLimit: _extraMovesGranted > 0,
      );
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => MoveLimitDialog(
        levelId: _currentLevelId,
        movesUsed: _engine.moveCount,
        optimalMoves: level.optimalMoves,
        canExtend: canExtend,
        onReplay: () {
          Navigator.of(ctx).pop();
          _isMoveLimitDialogShowing = false;
          _isModalShowing = false;
          widget.analytics.logMoveLimitReplaySelected(
            levelId: _currentLevelId,
            movesUsed: _engine.moveCount,
          );
          _restartCurrentLevel();
        },
        onWatchAd: () {
          Navigator.of(ctx).pop();
          _isMoveLimitDialogShowing = false;
          _isModalShowing = false;
          widget.analytics.logMoveLimitExtraMovesRequested(
            levelId: _currentLevelId,
            movesUsed: _engine.moveCount,
          );
          _executeRewardedAdForExtraMoves();
        },
      ),
    ).then((_) {
      _isMoveLimitDialogShowing = false;
      _isModalShowing = false;
    });
  }

  void _executeRewardedAdForExtraMoves() async {
    if (_isRequestingAd) return;
    _isRequestingAd = true;

    final placement = 'extra_moves_level_$_currentLevelId';

    // 1. Connectivity check
    final isOnline = await widget.connectivityService.hasInternetConnection();
    if (!mounted) {
      _isRequestingAd = false;
      return;
    }

    if (!isOnline) {
      _isRequestingAd = false;
      widget.analytics.logMoveLimitAdFailed(
        levelId: _currentLevelId,
        placement: placement,
        reason: 'network_unavailable',
      );
      _showInternetNeededDialogForExtraMoves();
      return;
    }

    // 2. Check if ad is ready, or wait briefly if loading
    if (!widget.adService.isRewardedAdReady) {
      await widget.adService.preloadRewardedAd();
      for (int i = 0; i < 4 && !widget.adService.isRewardedAdReady && mounted; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    }

    if (!mounted) {
      _isRequestingAd = false;
      return;
    }

    if (!widget.adService.isRewardedAdReady) {
      _isRequestingAd = false;
      widget.analytics.logMoveLimitAdFailed(
        levelId: _currentLevelId,
        placement: placement,
        reason: 'ad_unavailable',
      );
      _showAdUnavailableDialogForExtraMoves();
      return;
    }

    // 3. Ad is ready - show it
    widget.analytics.logRewardedAdRequested(placement);
    widget.analytics.logMoveLimitAdStarted(
      levelId: _currentLevelId,
      placement: placement,
    );

    bool rewardEarned = false;
    bool rewardDispatched = false;

    try {
      await widget.adService.showRewardedAd(
        placement: placement,
        onRewardEarned: () {
          if (rewardDispatched) return;
          rewardDispatched = true;
          rewardEarned = true;
          _grantExtraMoves(placement: placement);
        },
      );

      _isRequestingAd = false;
      if (!rewardEarned && mounted) {
        widget.analytics.logMoveLimitAdFailed(
          levelId: _currentLevelId,
          placement: placement,
          reason: 'ad_not_completed',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad was not completed. Replay level or try again.'),
            backgroundColor: Color(0xFF1E293B),
            duration: Duration(seconds: 2),
          ),
        );
        _showMoveLimitDialog();
      }
    } catch (e) {
      _isRequestingAd = false;
      widget.analytics.logMoveLimitAdFailed(
        levelId: _currentLevelId,
        placement: placement,
        reason: 'ad_error',
      );
      if (mounted) {
        _showAdUnavailableDialogForExtraMoves();
      }
    }
  }

  void _grantExtraMoves({required String placement}) {
    widget.analytics.logRewardedAdCompleted(placement);
    widget.analytics.logMoveLimitAdRewarded(
      levelId: _currentLevelId,
      placement: placement,
    );

    setState(() {
      _extraMoveExtensionUsed = true;
      _extraMovesGranted = 5;
      _isMoveLimitReached = false;
    });

    widget.analytics.logMoveLimitExtraMovesGranted(
      levelId: _currentLevelId,
      extraMovesGranted: 5,
      newMoveLimit: _currentMoveLimit,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '+5 extra moves unlocked! Keep solving.',
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFFEF3C7)),
        ),
        backgroundColor: Color(0xFF78350F),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showInternetNeededDialogForExtraMoves() {
    if (_isModalShowing) return;
    _isModalShowing = true;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => InternetNeededDialog(
        title: 'INTERNET CONNECTION NEEDED',
        body: 'A rewarded ad is required to unlock extra moves.\nTurn on Wi-Fi or mobile data, then try again.',
        onTryAgain: () async {
          final isConnected = await widget.connectivityService.hasInternetConnection();
          if (isConnected) {
            if (ctx.mounted) {
              Navigator.of(ctx).pop();
            }
            if (mounted) {
              _executeRewardedAdForExtraMoves();
            }
            return true;
          } else {
            return false;
          }
        },
        onNotNow: () {
          Navigator.of(ctx).pop();
          if (mounted) {
            _showMoveLimitDialog();
          }
        },
      ),
    ).then((_) {
      _isModalShowing = false;
    });
  }

  void _showAdUnavailableDialogForExtraMoves() {
    if (_isModalShowing) return;
    _isModalShowing = true;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => HintUnavailableDialog(
        title: 'EXTRA MOVES TEMPORARILY UNAVAILABLE',
        body: 'The rewarded ad isn’t available right now. Please try again.',
        onTryAgain: () async {
          await widget.adService.preloadRewardedAd();
          for (int i = 0; i < 4 && !widget.adService.isRewardedAdReady && mounted; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 300));
          }
          if (widget.adService.isRewardedAdReady) {
            if (ctx.mounted) {
              Navigator.of(ctx).pop();
            }
            if (mounted) {
              _executeRewardedAdForExtraMoves();
            }
            return true;
          } else {
            return false;
          }
        },
        onNotNow: () {
          Navigator.of(ctx).pop();
          if (mounted) {
            _showMoveLimitDialog();
          }
        },
      ),
    ).then((_) {
      _isModalShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final level = LevelDefinitions.getLevel(_currentLevelId);
    final isSoundOn = _progress?.isSoundEnabled ?? true;

    return PopScope(
      canPop: !_isMoveLimitReached,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isMoveLimitReached) {
          _showMoveLimitDialog();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF040C3A),
        body: SafeArea(
          child: Column(
            children: [
              GameHeader(
                levelId: _currentLevelId,
                levelTitle: level.title,
                moveCount: _engine.moveCount,
                optimalMoves: level.optimalMoves,
                moveLimit: _currentMoveLimit,
                hasExtraMoves: _extraMovesGranted > 0,
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
                onNextLevel: (_currentLevelId < LevelDefinitions.totalLevels &&
                        (_progress?.isLevelUnlocked(_currentLevelId + 1) ?? false))
                    ? () => _switchLevel(_currentLevelId + 1)
                    : null,
                hasPrevious: _currentLevelId > 1,
                hasNext: _currentLevelId < LevelDefinitions.totalLevels &&
                    (_progress?.isLevelUnlocked(_currentLevelId + 1) ?? false),
                showEchoButton: level.hasMemoryEcho,
                echoStatus: _engine.echo.status,
                echoCount: _engine.echo.length,
                isBoardBusy: _game.isAnimating || _game.isEchoReplaying,
                canUndo: _canUndo,
                isUndoLocked: _engine.isUndoLocked || _engine.moveCount >= level.optimalMoves,
                onUndo: _handleUndo,
                onUndoDisabled: _handleUndoDisabled,
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
      ),
    );
  }
}
