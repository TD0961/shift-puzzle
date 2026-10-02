import 'package:flutter/services.dart';

/// Contract for acquisition, viral challenge, and social sharing.
///
/// Designed to decouple UI and gameplay from specific third-party share plugins,
/// allowing graceful fallback to clipboard, deep links, or platform intents.
abstract class ShareService {
  /// Shares plain or rich text with an optional subject line.
  Future<bool> shareText({
    required String text,
    String? subject,
  });

  /// Shares a level completion challenge to invite friends to beat the player's score.
  Future<bool> shareLevelChallenge({
    required int levelId,
    required int moves,
    int? stars,
    String? downloadUrl,
  });
}

/// No-op implementation for environments where sharing is unavailable or disabled.
class NoOpShareService implements ShareService {
  const NoOpShareService();

  @override
  Future<bool> shareText({required String text, String? subject}) async => false;

  @override
  Future<bool> shareLevelChallenge({
    required int levelId,
    required int moves,
    int? stars,
    String? downloadUrl,
  }) async => false;
}

/// Lightweight clipboard-based share implementation.
///
/// Copies formatted challenge text directly to the system clipboard, making it
/// universally compatible with direct APK distribution and social messaging apps.
class ClipboardShareService implements ShareService {
  final Future<void> Function(String text)? onCopy;

  const ClipboardShareService({this.onCopy});

  @override
  Future<bool> shareText({required String text, String? subject}) async {
    try {
      if (onCopy != null) {
        await onCopy!(text);
      } else {
        await Clipboard.setData(ClipboardData(text: text));
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> shareLevelChallenge({
    required int levelId,
    required int moves,
    int? stars,
    String? downloadUrl,
  }) async {
    final url = downloadUrl ??
        const String.fromEnvironment(
          'DOWNLOAD_URL',
          defaultValue: 'https://shiftpuzzle.app',
        );
    final starStr = stars != null && stars > 0 ? ' (${'★' * stars})' : '';
    final message =
        '🧩 I solved Shift Puzzle Level $levelId in $moves moves$starStr! Can you beat my score? Download here: $url';
    return shareText(text: message, subject: 'Shift Puzzle Challenge');
  }
}
