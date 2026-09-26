import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight offline player progression and settings persistence.
class PlayerProgress {
  static const String _keyHighestUnlocked = 'sp_highest_unlocked';
  static const String _keyLastPlayed = 'sp_last_played';
  static const String _keyCompletedLevels = 'sp_completed_levels';
  static const String _keyBestMoves = 'sp_best_moves';
  static const String _keyStars = 'sp_stars';
  static const String _keySoundEnabled = 'sp_sound_enabled';
  static const String _keyTutorialCompleted = 'sp_tutorial_completed';
  static const int maxCampaignLevels = 150;

  final SharedPreferences _prefs;

  PlayerProgress(this._prefs);

  /// Factory to initialize PlayerProgress asynchronously.
  static Future<PlayerProgress> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return PlayerProgress(prefs);
  }

  /// Highest level unlocked (1..150, defaults to 1).
  int get highestUnlockedLevel =>
      (_prefs.getInt(_keyHighestUnlocked) ?? 1).clamp(1, maxCampaignLevels);

  /// The level the player last visited or played (clamped to 1..150).
  int get lastPlayedLevel =>
      (_prefs.getInt(_keyLastPlayed) ?? 1).clamp(1, maxCampaignLevels);

  /// Whether audio sound effects are enabled (defaults to true).
  bool get isSoundEnabled => _prefs.getBool(_keySoundEnabled) ?? true;

  /// Whether the first-session interactive tutorial has been completed.
  bool get isTutorialCompleted => _prefs.getBool(_keyTutorialCompleted) ?? false;

  /// Marks first-session tutorial as completed.
  Future<void> setTutorialCompleted() async {
    await _prefs.setBool(_keyTutorialCompleted, true);
  }

  /// Returns true if the given level is unlocked.
  bool isLevelUnlocked(int levelId) {
    if (levelId <= 1) return true;
    return levelId <= highestUnlockedLevel;
  }

  /// Returns set of all completed level IDs (bounded between 1 and 150).
  Set<int> get completedLevels {
    final list = _prefs.getStringList(_keyCompletedLevels) ?? [];
    return list
        .map((s) => int.tryParse(s) ?? 0)
        .where((id) => id >= 1 && id <= maxCampaignLevels)
        .toSet();
  }

  /// Returns true if the level has been completed at least once.
  bool isLevelCompleted(int levelId) => completedLevels.contains(levelId);

  /// Returns the player's personal best (fewest moves) for the level, or null if uncompleted.
  int? getBestMoves(int levelId) {
    final map = _getMap(_keyBestMoves);
    return map[levelId.toString()];
  }

  /// Returns stars earned on the level (0 if uncompleted, 1..3 otherwise).
  int getStars(int levelId) {
    final map = _getMap(_keyStars);
    return map[levelId.toString()] ?? 0;
  }

  /// Saves the last played level so returning players resume right where they left off.
  Future<void> setLastPlayedLevel(int levelId) async {
    await _prefs.setInt(_keyLastPlayed, levelId.clamp(1, maxCampaignLevels));
  }

  /// Toggles or sets sound effects enabled.
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_keySoundEnabled, enabled);
  }

  /// Records completion of a level, updating unlock progress, best moves, and star rating.
  /// Returns true if a new personal best (fewer moves) was achieved.
  Future<bool> recordLevelCompletion({
    required int levelId,
    required int moveCount,
    required int stars,
    required int totalLevels,
  }) async {
    bool isNewBest = false;

    // 1. Update completed levels set
    final completed = completedLevels..add(levelId);
    await _prefs.setStringList(
      _keyCompletedLevels,
      completed.map((id) => id.toString()).toList(),
    );

    // 2. Unlock next level if applicable
    if (levelId + 1 <= totalLevels) {
      final currentHighest = highestUnlockedLevel;
      if (levelId + 1 > currentHighest) {
        await _prefs.setInt(_keyHighestUnlocked, levelId + 1);
      }
    }

    // 3. Update best moves
    final bestMovesMap = _getMap(_keyBestMoves);
    final previousBest = bestMovesMap[levelId.toString()];
    if (previousBest == null || moveCount < previousBest) {
      bestMovesMap[levelId.toString()] = moveCount;
      await _setMap(_keyBestMoves, bestMovesMap);
      isNewBest = true;
    }

    // 4. Update stars (save highest achieved)
    final starsMap = _getMap(_keyStars);
    final previousStars = starsMap[levelId.toString()] ?? 0;
    if (stars > previousStars) {
      starsMap[levelId.toString()] = stars;
      await _setMap(_keyStars, starsMap);
    }

    return isNewBest;
  }

  /// Resets all player progress to fresh start (useful for testing and debug resets).
  Future<void> resetAll() async {
    await _prefs.remove(_keyHighestUnlocked);
    await _prefs.remove(_keyLastPlayed);
    await _prefs.remove(_keyCompletedLevels);
    await _prefs.remove(_keyBestMoves);
    await _prefs.remove(_keyStars);
  }

  Map<String, int> _getMap(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final result = <String, int>{};
      for (final entry in decoded.entries) {
        final val = entry.value;
        if (val is int) {
          result[entry.key.toString()] = val;
        } else if (val is num) {
          result[entry.key.toString()] = val.toInt();
        } else if (val is String) {
          final parsed = int.tryParse(val);
          if (parsed != null) result[entry.key.toString()] = parsed;
        }
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<void> _setMap(String key, Map<String, int> map) async {
    await _prefs.setString(key, jsonEncode(map));
  }
}
