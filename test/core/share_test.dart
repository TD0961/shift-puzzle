import 'package:flutter_test/flutter_test.dart';
import 'package:shift_puzzle/core/sharing/share_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShareService Abstraction & Implementations', () {
    test('NoOpShareService is safe and returns false without error', () async {
      const shareService = NoOpShareService();

      final textResult = await shareService.shareText(
        text: 'Come play Shift Puzzle!',
        subject: 'Game Invite',
      );
      expect(textResult, isFalse);

      final challengeResult = await shareService.shareLevelChallenge(
        levelId: 10,
        moves: 8,
        stars: 3,
      );
      expect(challengeResult, isFalse);
    });

    test('ClipboardShareService formats level challenge message correctly', () async {
      String? copiedText;

      final shareService = ClipboardShareService(
        onCopy: (text) async {
          copiedText = text;
        },
      );

      final result = await shareService.shareLevelChallenge(
        levelId: 12,
        moves: 5,
        stars: 3,
        downloadUrl: 'https://shiftpuzzle.example.com',
      );

      expect(result, isTrue);
      expect(copiedText, isNotNull);
      expect(copiedText, contains('Level 12'));
      expect(copiedText, contains('5 moves'));
      expect(copiedText, contains('★★★'));
      expect(copiedText, contains('https://shiftpuzzle.example.com'));
    });

    test('ClipboardShareService gracefully handles platform exceptions', () async {
      final failingShareService = ClipboardShareService(
        onCopy: (text) async {
          throw Exception('Clipboard unavailable');
        },
      );

      final result = await failingShareService.shareText(text: 'test');
      expect(result, isFalse); // Never crashes
    });
  });
}
