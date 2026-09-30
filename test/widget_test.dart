import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_puzzle/core/puzzle/models/shift_direction.dart';
import 'package:shift_puzzle/game/scenes/shift_puzzle_game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shift_puzzle/core/storage/player_progress.dart';
import 'package:shift_puzzle/main.dart';
import 'package:shift_puzzle/ui/game_screen.dart';
import 'package:shift_puzzle/ui/level_select_dialog.dart';
import 'package:shift_puzzle/ui/win_dialog.dart';

void main() {
  testWidgets('ShiftPuzzleApp initializes and renders GameScreen with Flame GameWidget', (tester) async {
    // Provide a standard phone test screen size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShiftPuzzleApp());
    await tester.pump();

    // Verify main screen widgets
    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('LEVEL 1'), findsOneWidget);
    expect(find.text('First Shift'), findsOneWidget);
    expect(find.text('Moves: '), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);

    // Verify Flame GameWidget is present
    expect(find.byWidgetPredicate((w) => w is GameWidget), findsOneWidget);
  });

  testWidgets('Restart button resets state and moves', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShiftPuzzleApp());
    await tester.pump();

    // Tap restart button
    final restartBtn = find.text('Restart');
    expect(restartBtn, findsOneWidget);
    await tester.tap(restartBtn);
    await tester.pump();

    expect(find.text('Moves: '), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Navigation switches levels smoothly', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'sp_highest_unlocked': 10,
    });

    await tester.pumpWidget(const ShiftPuzzleApp());
    await tester.pump();

    expect(find.text('LEVEL 1'), findsOneWidget);

    // Tap next level icon button
    final nextBtn = find.byTooltip('Next Level');
    expect(nextBtn, findsOneWidget);
    await tester.tap(nextBtn);
    await tester.pump();

    expect(find.text('LEVEL 2'), findsOneWidget);
    expect(find.text('The Edge Wrap'), findsOneWidget);

    // Tap previous level icon button
    final prevBtn = find.byTooltip('Previous Level');
    expect(prevBtn, findsOneWidget);
    await tester.tap(prevBtn);
    await tester.pump();

    expect(find.text('LEVEL 1'), findsOneWidget);
  });

  testWidgets('Echo button is hidden on Levels 1-8 and visible on Level 9', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'sp_highest_unlocked': 10,
    });

    await tester.pumpWidget(const ShiftPuzzleApp());
    await tester.pump();

    // Level 1: No echo button
    expect(find.byKey(const ValueKey('echo_button')), findsNothing);

    // Navigate to Level 9
    final nextBtn = find.byTooltip('Next Level');
    for (int i = 1; i < 9; i++) {
      await tester.tap(nextBtn);
      await tester.pump();
    }

    // Now on Level 9: "Echo"
    expect(find.text('LEVEL 9'), findsOneWidget);
    expect(find.text('Echo'), findsOneWidget); // Level title
    expect(find.text('Record shifts, stop, reposition the board, then Echo.'), findsOneWidget);

    // Echo button must now be present on Level 9 in idle REC state!
    final echoBtn = find.byKey(const ValueKey('echo_button'));
    expect(echoBtn, findsOneWidget);
    expect(find.descendant(of: echoBtn, matching: find.text('REC')), findsOneWidget);

    // In idle state, REC button is enabled so player can initiate recording
    final elevatedBtn = tester.widget<ElevatedButton>(echoBtn);
    expect(elevatedBtn.onPressed, isNotNull);

    // Tap REC -> starts recording
    await tester.tap(echoBtn);
    await tester.pump();
    expect(find.descendant(of: echoBtn, matching: find.text('● REC')), findsOneWidget);

    // Tap again with 0 moves -> stops and returns to idle REC
    await tester.tap(echoBtn);
    await tester.pump();
    expect(find.descendant(of: echoBtn, matching: find.text('REC')), findsOneWidget);
  });

  testWidgets('Level 9 full flow: explicit Record -> Stop -> Reposition -> Echo -> Finish', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'sp_highest_unlocked': 10,
    });

    await tester.pumpWidget(const ShiftPuzzleApp());
    await tester.pump();

    // Navigate to Level 9
    final nextBtn = find.byTooltip('Next Level');
    for (int i = 1; i < 9; i++) {
      await tester.tap(nextBtn);
      await tester.pump();
    }

    final gameWidget = tester.widget<GameWidget<ShiftPuzzleGame>>(find.byType(GameWidget<ShiftPuzzleGame>));
    final game = gameWidget.game!;

    // Initial state: 0 moves, idle REC button
    expect(find.text('0'), findsOneWidget);
    final echoBtn = find.byKey(const ValueKey('echo_button'));
    expect(find.descendant(of: echoBtn, matching: find.text('REC')), findsOneWidget);

    // 1. [REC] Tap to start recording
    await tester.tap(echoBtn);
    await tester.pump();
    expect(find.descendant(of: echoBtn, matching: find.text('● REC')), findsOneWidget);

    // 2. Perform 2 shifts while recording
    // Shift 1: Col 2 down
    game.triggerShiftColumn(2, ShiftDirection.down);
    await tester.pump(const Duration(milliseconds: 210));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(find.descendant(of: echoBtn, matching: find.text('● REC · 1')), findsOneWidget);

    // Shift 2: Col 2 down
    game.triggerShiftColumn(2, ShiftDirection.down);
    await tester.pump(const Duration(milliseconds: 210));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    expect(find.descendant(of: echoBtn, matching: find.text('● REC · 2')), findsOneWidget);

    // 3. [STOP] Tap to stop recording -> freezes sequence at 2 shifts
    await tester.tap(echoBtn);
    await tester.pump();
    expect(find.descendant(of: echoBtn, matching: find.text('Echo (2)')), findsOneWidget);

    // 4. REPOSITIONING: shifts made after stopping recording (NOT added to Echo!)
    // Move 3: Row 0 left
    game.triggerShiftRow(0, ShiftDirection.left);
    await tester.pump(const Duration(milliseconds: 210));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(find.descendant(of: echoBtn, matching: find.text('Echo (2)')), findsOneWidget);

    // Move 4: Row 0 left
    game.triggerShiftRow(0, ShiftDirection.left);
    await tester.pump(const Duration(milliseconds: 210));
    await tester.pump();
    expect(find.text('4'), findsOneWidget);
    expect(find.descendant(of: echoBtn, matching: find.text('Echo (2)')), findsOneWidget);

    // 5. [ECHO] Trigger replay of the 2 recorded shifts
    await tester.tap(echoBtn);
    await tester.pump();

    // Replay is now active
    expect(find.descendant(of: echoBtn, matching: find.text('Replaying...')), findsOneWidget);
    expect(tester.widget<ElevatedButton>(echoBtn).onPressed, isNull);

    // Pump frames to complete the 2 echo shifts and pauses
    for (int i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump();

    // After replay:
    // Move count remains strictly 4!
    expect(find.text('4'), findsOneWidget);
    // Button is now marked as used
    expect(find.descendant(of: echoBtn, matching: find.text('Echo (Used)')), findsOneWidget);
    expect(tester.widget<ElevatedButton>(echoBtn).onPressed, isNull);

    // 6. FINISH: Final Player move to solve (Row 2 right)
    game.triggerShiftRow(2, ShiftDirection.right);
    await tester.pump(const Duration(milliseconds: 210));
    await tester.pump();

    // Moves is now 5
    expect(find.text('5'), findsOneWidget);

    // Win satisfaction delay (380ms) + dialog entrance transition
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    // Win dialog is displayed!
    expect(find.text('LEVEL COMPLETE'), findsOneWidget);
    expect(find.text('Moves: 5'), findsOneWidget);

    // Tap Replay button on dialog
    await tester.tap(find.text('Replay'));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();

    // Level resets: moves = 0, echo resets to idle REC
    expect(find.text('0'), findsOneWidget);
    expect(find.descendant(of: echoBtn, matching: find.text('REC')), findsOneWidget);
    expect(tester.widget<ElevatedButton>(echoBtn).onPressed, isNotNull);
  });

  testWidgets('Memory Echo discard button cancels recording window back to idle REC', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'sp_highest_unlocked': 10,
    });

    await tester.pumpWidget(const ShiftPuzzleApp());
    await tester.pump();

    // Navigate to Level 9
    final nextBtn = find.byTooltip('Next Level');
    for (int i = 1; i < 9; i++) {
      await tester.tap(nextBtn);
      await tester.pump();
    }

    final echoBtn = find.byKey(const ValueKey('echo_button'));

    // Initially idle: no discard button
    expect(find.descendant(of: echoBtn, matching: find.text('REC')), findsOneWidget);
    expect(find.byKey(const ValueKey('discard_echo_button')), findsNothing);

    // Tap REC -> now recording: discard button appears
    await tester.tap(echoBtn);
    await tester.pump();
    expect(find.descendant(of: echoBtn, matching: find.text('● REC')), findsOneWidget);
    expect(find.byKey(const ValueKey('discard_echo_button')), findsOneWidget);

    // Tap Discard button -> cancels recording back to idle REC!
    await tester.tap(find.byKey(const ValueKey('discard_echo_button')));
    await tester.pump();
    expect(find.descendant(of: echoBtn, matching: find.text('REC')), findsOneWidget);
    expect(find.byKey(const ValueKey('discard_echo_button')), findsNothing);

    // Start recording again and record 1 move
    await tester.tap(echoBtn);
    await tester.pump();

    final gameWidgetFinder = find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>);
    final gameWidget = tester.widget<GameWidget<ShiftPuzzleGame>>(gameWidgetFinder);
    final game = gameWidget.game!;

    game.triggerShiftColumn(2, ShiftDirection.down);
    await tester.pump(const Duration(milliseconds: 210));
    await tester.pump();

    // Stop recording -> now in ready state: Echo (1)
    await tester.tap(echoBtn);
    await tester.pump();
    expect(find.descendant(of: echoBtn, matching: find.text('Echo (1)')), findsOneWidget);
    expect(find.byKey(const ValueKey('discard_echo_button')), findsOneWidget);

    // Tap discard button while in ready state -> resets to idle REC!
    await tester.tap(find.byKey(const ValueKey('discard_echo_button')));
    await tester.pump();
    expect(find.descendant(of: echoBtn, matching: find.text('REC')), findsOneWidget);
    expect(find.byKey(const ValueKey('discard_echo_button')), findsNothing);
  });

  testWidgets('WinDialog displays 3-star rating and optimal comparison', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WinDialog(
            levelId: 1,
            moveCount: 1,
            optimalMoves: 1,
            hasNextLevel: true,
            onNextLevel: () {},
            onReplay: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('LEVEL COMPLETE'), findsOneWidget);
    expect(find.text('Moves: 1'), findsOneWidget);
    expect(find.text('Optimal: 1 moves'), findsOneWidget);
    expect(find.text('PERFECT!'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
  });

  testWidgets('Undo button is disabled at start, enables on shift, and reverts move on tap', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'sp_highest_unlocked': 10,
    });

    await tester.pumpWidget(const ShiftPuzzleApp());
    await tester.pump();

    // Navigate to Level 4 (requires 4 moves, won't solve on move 1)
    final nextBtn = find.byTooltip('Next Level');
    for (int i = 1; i < 4; i++) {
      await tester.tap(nextBtn);
      await tester.pump();
    }
    expect(find.text('LEVEL 4'), findsOneWidget);

    final undoBtn = find.byKey(const ValueKey('undo_button'));
    expect(undoBtn, findsOneWidget);
    // Initially disabled
    expect(tester.widget<IconButton>(undoBtn).onPressed, isNull);

    // Make a shift
    final gameWidgetFinder = find.byWidgetPredicate((w) => w is GameWidget<ShiftPuzzleGame>);
    final game = tester.widget<GameWidget<ShiftPuzzleGame>>(gameWidgetFinder).game!;
    game.triggerShiftColumn(4, ShiftDirection.down);
    await tester.pump(const Duration(milliseconds: 210));
    await tester.pump();

    // Move count is 1, Undo is now enabled
    expect(find.text('1'), findsOneWidget);
    expect(tester.widget<IconButton>(undoBtn).onPressed, isNotNull);

    // Tap Undo
    await tester.tap(undoBtn);
    await tester.pump();

    // Move count reverts to 0, Undo button is disabled again
    expect(find.text('0'), findsOneWidget);
    expect(tester.widget<IconButton>(undoBtn).onPressed, isNull);
  });

  testWidgets('Next level button is disabled when next level is locked without passing current level', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'sp_highest_unlocked': 1,
    });

    await tester.pumpWidget(const ShiftPuzzleApp());
    await tester.pump();

    expect(find.text('LEVEL 1'), findsOneWidget);

    final nextBtn = find.byWidgetPredicate(
      (w) => w is IconButton && w.tooltip == 'Next Level',
    );
    expect(tester.widget<IconButton>(nextBtn).onPressed, isNull);

    await tester.tap(nextBtn);
    await tester.pump();
    expect(find.text('LEVEL 1'), findsOneWidget);
  });

  testWidgets('Sound toggle button toggles audio state and icon', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final progress = PlayerProgress(prefs);

    await tester.pumpWidget(ShiftPuzzleApp(progress: progress));
    await tester.pump();

    final soundBtn = find.byKey(const ValueKey('sound_toggle_button'));
    expect(soundBtn, findsOneWidget);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);

    // Tap to mute
    await tester.tap(soundBtn);
    await tester.pump();
    expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
    expect(progress.isSoundEnabled, isFalse);

    // Tap to unmute
    await tester.tap(soundBtn);
    await tester.pump();
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    expect(progress.isSoundEnabled, isTrue);
  });

  testWidgets('Level Select dialog shows campaign progression and allows level selection', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'sp_highest_unlocked': 2,
      'sp_completed_levels': ['1'],
      'sp_stars': '{"1": 3}',
      'sp_best_moves': '{"1": 1}',
    });
    final prefs = await SharedPreferences.getInstance();
    final progress = PlayerProgress(prefs);

    await tester.pumpWidget(ShiftPuzzleApp(progress: progress));
    await tester.pump();

    // Tap level header to open level select
    final headerFinder = find.text('LEVEL 1');
    await tester.tap(headerFinder);
    await tester.pump();

    // Dialog is visible
    expect(find.byType(LevelSelectDialog), findsOneWidget);
    expect(find.text('CAMPAIGN'), findsOneWidget);
    expect(find.text('1/150 Solved  ·  ★ 3/450'), findsOneWidget);

    // Level 1 shows completed info
    expect(find.text('Best: 1 moves (Par: 1)'), findsOneWidget);

    // Level 2 is unlocked -> tap to select it
    final level2Tile = find.text('The Edge Wrap');
    expect(level2Tile, findsOneWidget);
    await tester.tap(level2Tile);
    await tester.pump();

    // Dialog dismissed and Level 2 loaded
    expect(find.byType(LevelSelectDialog), findsNothing);
    expect(find.text('LEVEL 2'), findsOneWidget);
  });

  testWidgets('Level Select dialog chapter tab switching navigates between chapters', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'sp_highest_unlocked': 100,
      'sp_completed_levels': ['1'],
    });
    final prefs = await SharedPreferences.getInstance();
    final progress = PlayerProgress(prefs);

    await tester.pumpWidget(ShiftPuzzleApp(progress: progress));
    await tester.pump();

    // Open level select
    await tester.tap(find.text('LEVEL 1'));
    await tester.pump();

    expect(find.byType(LevelSelectDialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(LevelSelectDialog),
        matching: find.text('First Shift'),
      ),
      findsOneWidget,
    );

    // Tap Chapter II: Temporal
    await tester.tap(find.text('Temporal'));
    await tester.pump();

    expect(find.text('Chapter II: Temporal Awakening'), findsOneWidget);
    expect(find.text('Temporal Cross'), findsOneWidget);

    // Tap Chapter X: The Finale
    await tester.tap(find.text('The Finale'));
    await tester.pump();

    expect(find.text('Chapter X: The Final Shift'), findsOneWidget);

    // Tap Chapter V: Grandmaster
    await tester.tap(find.text('Grandmaster'));
    await tester.pump();

    expect(find.text('Chapter V: Grandmaster'), findsOneWidget);
    expect(find.text('Prism of Light'), findsOneWidget);

    // Select Level 41
    await tester.tap(find.text('Prism of Light'));
    await tester.pump();

    expect(find.byType(LevelSelectDialog), findsNothing);
    expect(find.text('LEVEL 41'), findsOneWidget);
  });

  testWidgets('Hint button triggers optional rewarded ad disclosure and reveals hint', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShiftPuzzleApp());
    await tester.pump();

    // Verify hint button exists
    final hintBtn = find.byKey(const ValueKey('hint_button'));
    expect(hintBtn, findsOneWidget);

    // Tap hint button
    await tester.tap(hintBtn);
    await tester.pump();

    // Dialog appears with clear disclosure
    expect(find.text('NEED A HINT?'), findsOneWidget);
    expect(find.text('Watch a short video ad to reveal the next optimal move.'), findsOneWidget);
    expect(find.text('NOT NOW'), findsOneWidget);
    expect(find.text('WATCH AD'), findsOneWidget);

    // Tap WATCH AD
    await tester.tap(find.text('WATCH AD'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Dialog is dismissed and hint snackbar appears
    expect(find.text('NEED A HINT?'), findsNothing);
    expect(find.textContaining('Hint: Shift'), findsOneWidget);
  });

  testWidgets('First-session tutorial overlay displays on Level 1 and 2 for new players', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'sp_tutorial_completed': false,
      'sp_highest_unlocked': 2,
    });
    final prefs = await SharedPreferences.getInstance();
    final progress = PlayerProgress(prefs);

    await tester.pumpWidget(ShiftPuzzleApp(progress: progress));
    await tester.pump();

    // Tutorial overlay visible on Level 1
    expect(find.text('SWIPE TO SHIFT ➔'), findsOneWidget);

    // Navigate to Level 2
    final nextBtn = find.byTooltip('Next Level');
    await tester.tap(nextBtn);
    await tester.pump();

    // Tutorial overlay visible on Level 2
    expect(find.text('THE BOARD WRAPS ↺'), findsOneWidget);
  });

  testWidgets('Level Select dialog navigates to Chapter XV: The Singularity and Level 141', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'sp_highest_unlocked': 150,
      'sp_completed_levels': ['1'],
    });
    final prefs = await SharedPreferences.getInstance();
    final progress = PlayerProgress(prefs);

    await tester.pumpWidget(ShiftPuzzleApp(progress: progress));
    await tester.pump();

    // Open level select
    await tester.tap(find.text('LEVEL 1'));
    await tester.pump();

    expect(find.byType(LevelSelectDialog), findsOneWidget);

    // Tap Chapter XV: Singularity
    await tester.tap(find.text('Singularity'));
    await tester.pump();

    expect(find.text('Chapter XV: The Singularity'), findsOneWidget);
    expect(find.text('Singularity: Event Horizon'), findsOneWidget);

    // Select Level 141
    await tester.tap(find.text('Singularity: Event Horizon'));
    await tester.pump();

    expect(find.byType(LevelSelectDialog), findsNothing);
    expect(find.text('LEVEL 141'), findsOneWidget);
    expect(find.text('Singularity: Event Horizon'), findsOneWidget);
  });

  testWidgets(
      'Contextual hint presentation shows "Need a hint?" chip when player restarts repeatedly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'sp_highest_unlocked': 10,
      'sp_completed_levels': ['1'],
    });
    final prefs = await SharedPreferences.getInstance();
    final progress = PlayerProgress(prefs);

    await tester.pumpWidget(ShiftPuzzleApp(progress: progress));
    await tester.pump();

    // Normal state: icon button without "Need a hint?" text
    expect(find.text('Need a hint?'), findsNothing);

    // Repeated restarts triggers struggle condition
    await tester.tap(find.text('Restart'));
    await tester.pump();
    await tester.tap(find.text('Restart'));
    await tester.pump();

    // Contextual button should now display "Need a hint?"
    expect(find.text('Need a hint?'), findsOneWidget);

    // Tapping it opens the voluntary hint disclosure dialog
    await tester.tap(find.text('Need a hint?'));
    await tester.pump();

    expect(find.text('NEED A HINT?'), findsOneWidget);
    expect(find.text('WATCH AD'), findsOneWidget);
  });
}
