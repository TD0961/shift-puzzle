# Shift Puzzle — Task 15 Final Engineering Report
## Campaign Optimality Integrity + Difficulty Hierarchy Audit

**Date**: September 27, 2026  
**Milestone**: Task 15 — Optimality Verification, Solver Audit & Campaign Calibration  
**Status**: **AUDIT COMPLETE — SOLVER CORRECTED — 21 PARS UPDATED — 100% MATHEMATICAL INTEGRITY VERIFIED**

---

## 1. Executive Summary & Root Cause of Level 22 Discrepancy

### The Observed Anomaly
During manual human playtesting on Level 22 ("Ring of Saturn"), a player solved the level in **5 moves**. The HUD displayed `Moves: 5 / 6`, and the completion screen reported:
```
LEVEL COMPLETE
PERFECT!
Moves: 5
Optimal: 6 moves
★ NEW PERSONAL BEST!
```
The game awarded 3 stars ("PERFECT!"), yet claimed that the optimal solution was 6 moves.

### Root Cause Investigation & Trace
Our investigation traced the exact discrepancy through the solver, level metadata, and game engine:

1. **The Solver Algorithm**:
   In `lib/core/puzzle/logic/puzzle_solver.dart`, `PuzzleSolver.solveFromGrid()` utilized a bidirectional Breadth-First Search (BFS) starting from `startGrid` and `goalGrid`.
   
2. **The Flaw in Bidirectional BFS Termination**:
   The solver evaluated:
   ```dart
   if (otherVisited.containsKey(nextCode)) {
     return _reconstructBidirectionalPath(...);
   }
   ```
   In bidirectional BFS, alternating forward and backward queues by queue element count rather than strict distance synchrony means that a node at distance 3 from the start can collide with a node at distance 3 from the goal (total length $3 + 3 = 6$). 
   Because the solver **immediately terminated upon the very first collision found**, it returned length 6, before the search expanded pending frontier nodes at distance 2 that would connect to distance 3 (total length $3 + 2 = 5$).

3. **How It Contaminated Campaign Metadata**:
   In prior calibration tasks, `level.optimalMoves` in `level_definitions.dart` had been populated using `PuzzleSolver.solve(level)`.
   Because `PuzzleSolver.solve(level22)` returned 6, `optimalMoves: 6` was hardcoded into `level_definitions.dart`.
   Furthermore, regression tests in `test/solver/level_analysis_test.dart` asserted:
   ```dart
   expect(result.minMoves, equals(level.optimalMoves));
   ```
   Both the solver and the stored par were 6, so tests passed (6 == 6), creating a closed feedback loop that concealed the discrepancy from automated test suites.

4. **Human Verification**:
   The human player discovered the true shortest legal solution:
   1. `Row 0 left` (moves cyan from (0,3) to (0,2), violet from (0,4) to (0,3))
   2. `Row 2 right` (moves amber from (2,2) to (2,3))
   3. `Row 2 right` (moves amber from (2,3) to (2,4) — target reached!)
   4. `Col 3 up` (moves violet from (0,3) to (4,3))
   5. `Row 4 left` (moves violet from (4,3) to (4,2) — target reached!)
   *All 3 targets satisfied in exactly 5 moves.*

5. **The Algorithmic Fix**:
   `PuzzleSolver.solveFromGrid()` was upgraded to track `bestDist` and `bestMeetingCode`, terminating **only** when the sum of minimum distances in the forward and backward frontiers satisfies:
   $$\text{fwdFrontierDist} + \text{bwdFrontierDist} \ge \text{bestDist}$$
   Under this textbook termination condition, it is mathematically proven that no shorter path can exist. The upgraded solver immediately discovers the 5-move solution for Level 22 in just 146 explored states (~1ms).

---

## 2. Campaign Audit Metrics Overview

Across the complete 150-level campaign:

| Metric | Count | Percentage |
| :--- | :---: | :---: |
| **Total Levels Audited** | 150 | 100.0% |
| **Levels with Par == True Minimum (MATCH)** | 129 | 86.0% |
| **Levels with Par Too High (PAR_TOO_HIGH by 1 move)** | 21 | 14.0% |
| **Levels with Par Too Low (PAR_TOO_LOW)** | 0 | 0.0% |
| **Solver/Gameplay Rule Mismatches** | 0 | 0.0% |
| **Unsolved Levels** | 0 | 0.0% |
| **Puzzle Content Modified** | 0 | 0.0% (Frozen) |

Every single one of the 21 discrepancies was inflated by exactly **1 move** ($N$ instead of $N - 1$), caused by the premature termination in bidirectional BFS.

---

## 3. All 21 Corrected Levels

All 21 levels have been updated in `lib/core/puzzle/levels/level_definitions.dart`. Every solution was replayed through `PuzzleEngine` in automated test `test/core/task_15_optimality_audit_test.dart` to verify that all shifts are valid, move counts increment properly, and the board reaches the solved state.

| Level | Chapter | Level Title | Echo? | Old Par | True Optimal | Verified Shortest Solution Path |
| :---: | :---: | :--- | :---: | :---: | :---: | :--- |
| **5** | Ch 1 | Dual Alignment | No | 4 | **3** | Col 3 up $\to$ Row 2 left $\to$ Col 2 up |
| **11** | Ch 2 | Temporal Cross | Yes | 6 | **5** | Row 3 right $\to$ Col 2 up $\to$ Row 3 right $\to$ Row 2 left $\to$ Row 2 left |
| **14** | Ch 2 | Interference Matrix | No | 6 | **5** | Col 0 up $\to$ Row 2 right $\to$ Col 1 up $\to$ Col 3 down $\to$ Col 2 up |
| **17** | Ch 2 | Shift Synchrony | Yes | 6 | **5** | Col 2 down $\to$ Row 3 left $\to$ Col 3 down $\to$ Col 2 up $\to$ Row 0 left |
| **20** | Ch 2 | Temporal Threshold | Yes | 8 | **7** | Row 3 left $\to$ Col 3 up $\to$ Row 2 right $\to$ Row 1 left $\to$ Col 2 up $\to$ Row 2 left $\to$ Row 2 left |
| **22** | Ch 3 | Ring of Saturn | No | 6 | **5** | Row 0 left $\to$ Row 2 right $\to$ Row 2 right $\to$ Col 3 up $\to$ Row 4 left |
| **38** | Ch 4 | Clockwork | Yes | 8 | **7** | Col 1 up $\to$ Col 3 up $\to$ Col 3 up $\to$ Row 4 left $\to$ Row 0 left $\to$ Row 0 left $\to$ Col 1 up |
| **39** | Ch 4 | Flux Capacitor | Yes | 8 | **7** | Row 2 right $\to$ Col 3 up $\to$ Col 3 up $\to$ Col 0 down $\to$ Row 2 right $\to$ Col 0 down $\to$ Row 0 left |
| **40** | Ch 4 | The Engine | Yes | 8 | **7** | Col 1 up $\to$ Col 2 down $\to$ Col 2 down $\to$ Col 1 up $\to$ Col 0 down $\to$ Col 0 down $\to$ Row 3 right |
| **45** | Ch 5 | Labyrinth of Time | Yes | 8 | **7** | Row 0 left $\to$ Col 3 up $\to$ Row 2 right $\to$ Col 4 down $\to$ Row 4 left $\to$ Row 2 right $\to$ Row 0 right |
| **46** | Ch 5 | Celestial Compass | No | 8 | **7** | Row 1 left $\to$ Col 1 up $\to$ Row 1 left $\to$ Row 2 right $\to$ Col 2 down $\to$ Col 0 down $\to$ Row 0 right |
| **56** | Ch 6 | Orbit & Recall | Yes | 6 | **5** | Row 0 right $\to$ Col 0 down $\to$ Col 0 down $\to$ Row 1 left $\to$ Col 4 down |
| **57** | Ch 6 | Temporal Setup | Yes | 8 | **7** | Row 0 right $\to$ Col 3 down $\to$ Col 3 down $\to$ Row 1 left $\to$ Row 1 left $\to$ Col 3 down $\to$ Row 2 left |
| **62** | Ch 7 | Cross-Axis Lock | No | 8 | **7** | Row 0 left $\to$ Row 4 right $\to$ Col 2 down $\to$ Col 2 down $\to$ Row 2 left $\to$ Col 1 down $\to$ Row 1 right |
| **75** | Ch 8 | Strobe Gate | Yes | 8 | **7** | Row 2 left $\to$ Col 1 down $\to$ Row 0 right $\to$ Row 0 right $\to$ Col 3 down $\to$ Col 1 up $\to$ Col 1 up |
| **80** | Ch 8 | The Automaton | Yes | 9 | **8** | Col 1 down $\to$ Col 4 up $\to$ Row 3 right $\to$ Col 0 up $\to$ Row 2 left $\to$ Col 2 down $\to$ Col 2 down $\to$ Col 0 up |
| **85** | Ch 9 | The Crucible | Yes | 10 | **9** | Col 4 down $\to$ Row 0 right $\to$ Row 4 left $\to$ Col 0 up $\to$ Col 0 up $\to$ Row 2 left $\to$ Col 0 up $\to$ Row 2 left $\to$ Col 1 down |
| **107** | Ch 11 | Timbre Weave | No | 8 | **7** | Row 0 left $\to$ Row 2 right $\to$ Row 2 right $\to$ Col 2 down $\to$ Row 4 right $\to$ Col 2 down $\to$ Col 2 down |
| **109** | Ch 11 | Standing Wave | No | 8 | **7** | Col 2 down $\to$ Row 1 right $\to$ Row 1 right $\to$ Col 2 down $\to$ Row 2 right $\to$ Col 4 up $\to$ Row 2 right |
| **118** | Ch 12 | Entangled Lattice | No | 8 | **7** | Row 1 left $\to$ Col 1 up $\to$ Row 1 left $\to$ Row 2 right $\to$ Col 2 down $\to$ Col 0 down $\to$ Row 0 right |
| **136** | Ch 14 | Temporal Brake | No | 6 | **5** | Col 0 up $\to$ Row 4 left $\to$ Col 1 down $\to$ Row 0 right $\to$ Col 0 up |

---

## 4. Authoritative Definition of Optimal & System Architecture

To ensure total integrity, the entire codebase now relies on **one singular source of truth**:

1. **Par / Optimal Definition**:
   `par` represents `level.optimalMoves`: the minimum number of player-initiated shifts needed to transform `initialGrid` into any configuration where all `level.targets` are satisfied.
2. **Storage Location**:
   Stored directly on `PuzzleLevel.optimalMoves` in `lib/core/puzzle/levels/level_definitions.dart`.
3. **Solver Authority**:
   `PuzzleSolver.solve()` in `lib/core/puzzle/logic/puzzle_solver.dart` is the sole algorithmic authority. It models:
   - Full 5×5 toroidal geometry with bidirectional wrapping: $(c \pm 1) \pmod 5$, $(r \pm 1) \pmod 5$.
   - Symmetric row and column shifts.
   - Exact piece type identities and target coordinate matching.
4. **Move Accounting Integrity**:
   - Standard moves increment `_moveCount`.
   - Memory Echo replay playback shifts pass `isEcho: true`, which executes the spatial shift on the board without incrementing `_moveCount`.
5. **Star Rating Calibration**:
   In `lib/ui/win_dialog.dart`:
   - **3 Stars ("PERFECT!")**: $\text{moveCount} \le \text{optimalMoves}$
   - **2 Stars ("GREAT SOLVE!")**: $\text{moveCount} \le \text{optimalMoves} + 2$
   - **1 Star ("PUZZLE SOLVED")**: $\text{moveCount} > \text{optimalMoves} + 2$
   Because `optimalMoves` is now the true mathematical minimum, **a player can never achieve a move count strictly less than reported optimal**. Solving in 5 moves on Level 22 yields: `Moves: 5`, `Optimal: 5 moves`, `PERFECT!`.
6. **HUD Display**:
   `GameHeader` renders `Moves: $moveCount / $optimalMoves` (e.g., `Moves: 5 / 5`), switching to a subtle amber accent only when `moveCount > optimalMoves`.

---

## 5. Memory Echo Analysis

Memory Echo levels (84 of the 150 levels) were audited for move accounting consistency:
- **Move Counting**: Recording captures moves to an action buffer while incrementing `moveCount`. Repositioning maneuvers prior to playback also count toward `moveCount`. When Echo playback executes, the ghost moves do not increment `moveCount`.
- **Par Metric Alignment**: `optimalMoves` defines the minimum player-initiated moves needed to complete the level. No Echo level required special mathematical exceptions because the BFS solver accurately computes the minimum moves required for the level configuration.
- **Safety**: Echo playback and recording continue to suppress the Optimal Drift Nudge, preventing ghost moves or recording setup from triggering prompts.

---

## 6. Task 14 Optimal Drift Nudge Safety

The Task 14 nudge triggers when:
$$\text{playerMoveCount} == \text{optimalMoves} + 1$$

### Before vs. After Correction:
- **Before (Inflated Par)**:
  On Level 22, when par was 6 (true minimum 5):
  - At 5 moves (true par): Player was at true minimum.
  - At 6 moves: Player was 1 move over true minimum, but game showed `Moves: 6 / 6`. No nudge appeared.
  - At 7 moves: Nudge appeared claiming *"You're 1 move over par"*, when the player was actually **2 moves over par**.
- **After (Corrected Par)**:
  On Level 22, par is now 5:
  - At 5 moves: Player achieves par (`5 / 5`). Victory triggers if solved. Zero nudges.
  - At 6 moves: Player is genuinely 1 move beyond minimum par (`6 / 5`). The nudge triggers accurately with honest coaching: *"You're one move beyond the minimum par. Need a nudge?"*.
  - No false drift message can ever occur at true optimal.

---

## 7. Campaign Difficulty Hierarchy & Progression Analysis

A full programmatic audit of difficulty was executed across all 15 Chapters (Levels 1–150):

| Chapter | Name | Levels | Avg Moves | Median Moves | Avg Pieces | Avg States Explored | Echo % | Difficulty Classification |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **1** | Foundations | 1–10 | 3.5 | 4.0 | 2.1 | 64 | 20% | **Tutorial & Onboarding** |
| **2** | Temporal Echo | 11–20 | 6.1 | 6.5 | 3.4 | 725 | 60% | **Early Intermediate** |
| **3** | Orthogonal Crossroads | 21–30 | 6.6 | 7.0 | 3.7 | 1,111 | 20% | **Intermediate Spatial Locks** |
| **4** | Dual Echo Harmony | 31–40 | 7.1 | 7.0 | 3.8 | 1,217 | 60% | **Multi-Phase Echo Coordination** |
| **5** | Grandmaster Crucible | 41–50 | 7.5 | 7.5 | 4.0 | 2,562 | 60% | **Early Campaign Culmination** |
| **6** | Toroidal Labyrinths | 51–60 | 6.3 | 6.0 | 3.0 | 1,227 | 100% | **Midgame Rest & Theme Reset** |
| **7** | Echo Cadence | 61–70 | 6.9 | 7.0 | 3.4 | 2,062 | 30% | **Rhythmic Delay Challenges** |
| **8** | Symmetry & Inverse | 71–80 | 7.1 | 7.0 | 3.5 | 1,193 | 100% | **Mirrored Inversion Locks** |
| **9** | Echo Weaver | 81–90 | 7.7 | 8.0 | 3.8 | 2,632 | 60% | **Complex Interlaced Echoes** |
| **10** | Century Crucible | 91–100 | 8.1 | 8.0 | 4.3 | 5,341 | 100% | **Century Milestone Peaks** |
| **11** | Quantum Echoes | 101–110 | 7.3 | 7.0 | 3.7 | 1,880 | 10% | **Advanced Spatial Entanglement** |
| **12** | Parity & Flux | 111–120 | 7.6 | 7.5 | 3.8 | 1,978 | 10% | **Axis Parity & Non-Commutative** |
| **13** | Echo Resonance | 121–130 | 7.2 | 8.0 | 3.7 | 1,033 | 100% | **High-Fidelity Echo Orchestration**|
| **14** | Geometric Horizons | 131–140 | 7.5 | 8.0 | 4.1 | 3,335 | 10% | **Non-Euclidean Toroidal Routing** |
| **15** | The Outer Sanctum | 141–150 | 8.4 | 8.0 | 4.7 | 6,966 | 100% | **Endgame Mastery & Culmination** |

### Progression Dynamics:
1. **Pacing Curves (Breathers vs. Climaxes)**:
   - The campaign does not force artificial monotonic move increases.
   - Chapter 6 (Levels 51–53) intentionally lowers pieces from 4.0 to 3.0 (Avg moves 6.3) to let players master pure toroidal routing before ramping back up.
   - Chapter 8 introduces mirrored coordinates with a controlled 7.1 average move baseline.
2. **Notable Difficulty Climaxes**:
   - **Level 50** ("Shift Master"): 9 moves, 5 pieces, 13,388 states explored.
   - **Level 97** ("Omega Point"): 9 moves, 5 pieces, 15,408 states explored.
   - **Level 99** ("Event Horizon Zenith"): 10 moves, 5 pieces, 18,869 states explored.
   - **Level 147** ("Singularity: Hawking Radiation"): 10 moves, 5 pieces, 17,210 states explored.
   - **Level 150** ("The Grand Singularity"): 9 moves, 5 pieces, 14,196 states explored.

---

## 8. Complete 150-Level Verification Table

Every level was evaluated against the corrected solver. All 150 levels have:
$$\text{Configured Par} == \text{Verified Optimal}$$

<details>
<summary>Click to expand full 150-Level Verification Table</summary>

| Lvl | Ch | Title | Pieces | Echo? | Stored Par | Solver Min | Status | Drift Nudge |
| :---: | :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | 1 | First Shift | 1 | No | 1 | 1 | MATCH | Excluded (Tutorial) |
| 2 | 1 | Across The Edge | 1 | No | 1 | 1 | MATCH | Excluded (Tutorial) |
| 3 | 1 | Two Paths | 1 | No | 1 | 1 | MATCH | Excluded (Tutorial) |
| 4 | 1 | Cross Currents | 2 | No | 4 | 4 | MATCH | Excluded (Onboarding) |
| 5 | 1 | Dual Alignment | 2 | No | 3 | 3 | MATCH | Excluded (Onboarding) |
| 6 | 1 | Trio Harmony | 3 | No | 5 | 5 | MATCH | Enabled (par + 1 = 6) |
| 7 | 1 | Corner Pocket | 3 | No | 5 | 5 | MATCH | Enabled (par + 1 = 6) |
| 8 | 1 | Central Cross | 3 | No | 6 | 6 | MATCH | Enabled (par + 1 = 7) |
| 9 | 1 | Temporal Echo Intro | 2 | Yes | 4 | 4 | MATCH | Enabled (par + 1 = 5) |
| 10 | 1 | Echo Bridge | 3 | Yes | 5 | 5 | MATCH | Enabled (par + 1 = 6) |
| 11 | 2 | Temporal Cross | 3 | Yes | 5 | 5 | MATCH | Enabled (par + 1 = 6) |
| 12 | 2 | Ghost Corridor | 3 | No | 5 | 5 | MATCH | Enabled (par + 1 = 6) |
| 13 | 2 | Shift Sequence | 3 | Yes | 6 | 6 | MATCH | Enabled (par + 1 = 7) |
| 14 | 2 | Interference Matrix | 3 | No | 5 | 5 | MATCH | Enabled (par + 1 = 6) |
| 15 | 2 | Temporal Loop | 3 | Yes | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 16 | 2 | Orthogonal Echo | 4 | No | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 17 | 2 | Shift Synchrony | 3 | Yes | 5 | 5 | MATCH | Enabled (par + 1 = 6) |
| 18 | 2 | Double Delay | 4 | No | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 19 | 2 | Mirror Track | 4 | Yes | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 20 | 2 | Temporal Threshold | 4 | Yes | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 21 | 3 | The Lattice | 3 | No | 6 | 6 | MATCH | Enabled (par + 1 = 7) |
| 22 | 3 | Ring of Saturn | 3 | No | 5 | 5 | MATCH | Enabled (par + 1 = 6) |
| 23 | 3 | Symmetry Break | 4 | No | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 24 | 3 | Toroidal Bypass | 4 | No | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 25 | 3 | Quadrant Shift | 4 | No | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 26 | 3 | Echo Grid | 4 | Yes | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 27 | 3 | Diagonal Drift | 4 | No | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 28 | 3 | Phase Shift | 3 | Yes | 5 | 5 | MATCH | Enabled (par + 1 = 6) |
| 29 | 3 | Harmonic Axis | 4 | No | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 30 | 3 | The Matrix | 4 | No | 8 | 8 | MATCH | Enabled (par + 1 = 9) |
| 31 | 4 | Gearbox | 4 | No | 8 | 8 | MATCH | Enabled (par + 1 = 9) |
| 32 | 4 | Dual Piston | 3 | Yes | 6 | 6 | MATCH | Enabled (par + 1 = 7) |
| 33 | 4 | Switchboard | 4 | No | 8 | 8 | MATCH | Enabled (par + 1 = 9) |
| 34 | 4 | The Carousel | 4 | Yes | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 35 | 4 | Interlock | 3 | No | 6 | 6 | MATCH | Enabled (par + 1 = 7) |
| 36 | 4 | Resonator | 4 | Yes | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 37 | 4 | Orbital Station | 4 | No | 8 | 8 | MATCH | Enabled (par + 1 = 9) |
| 38 | 4 | Clockwork | 4 | Yes | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 39 | 4 | Flux Capacitor | 4 | Yes | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 40 | 4 | The Engine | 4 | Yes | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 41 | 5 | Prism of Light | 4 | No | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 42 | 5 | Quantum Entanglement | 3 | Yes | 6 | 6 | MATCH | Enabled (par + 1 = 7) |
| 43 | 5 | The Monolith | 4 | No | 8 | 8 | MATCH | Enabled (par + 1 = 9) |
| 44 | 5 | Supernova | 4 | Yes | 8 | 8 | MATCH | Enabled (par + 1 = 9) |
| 45 | 5 | Labyrinth of Time | 4 | Yes | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 46 | 5 | Celestial Compass | 4 | No | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 47 | 5 | Event Horizon | 4 | Yes | 7 | 7 | MATCH | Enabled (par + 1 = 8) |
| 48 | 5 | Singularity | 4 | No | 8 | 8 | MATCH | Enabled (par + 1 = 9) |
| 49 | 5 | Chronos | 4 | Yes | 8 | 8 | MATCH | Enabled (par + 1 = 9) |
| 50 | 5 | Shift Master | 5 | Yes | 9 | 9 | MATCH | Enabled (par + 1 = 10) |
| 51–60 | 6 | Toroidal Labyrinths | 2–4 | Yes | 5–10 | 5–10 | MATCH | All Enabled |
| 61–70 | 7 | Echo Cadence | 2–5 | 30% | 5–9 | 5–9 | MATCH | All Enabled |
| 71–80 | 8 | Symmetry & Inverse | 2–5 | Yes | 5–8 | 5–8 | MATCH | All Enabled |
| 81–90 | 9 | Echo Weaver | 3–5 | 60% | 5–10 | 5–10 | MATCH | All Enabled |
| 91–100 | 10 | Century Crucible | 3–5 | Yes | 6–10 | 6–10 | MATCH | All Enabled |
| 101–110 | 11 | Quantum Echoes | 3–4 | 10% | 6–9 | 6–9 | MATCH | All Enabled |
| 111–120 | 12 | Parity & Flux | 3–5 | 10% | 7–9 | 7–9 | MATCH | All Enabled |
| 121–130 | 13 | Echo Resonance | 3–5 | Yes | 6–8 | 6–8 | MATCH | All Enabled |
| 131–140 | 14 | Geometric Horizons | 3–5 | 10% | 5–10 | 5–10 | MATCH | All Enabled |
| 141–150 | 15 | The Outer Sanctum | 4–5 | Yes | 7–10 | 7–10 | MATCH | All Enabled |

</details>

---

## 9. Verification & Build Results

| Verification Step | Target | Result | Status |
| :--- | :--- | :--- | :---: |
| **Flutter Analyze** | 0 warnings, 0 errors | **No issues found!** (ran in 7.5s) | **PASS** |
| **Automated Test Suite** | 100% passing | **259 / 259 passed** | **PASS** |
| **Flutter Web Build** | Release bundle | **Built successfully** (`build/web`) | **PASS** |
| **Android Release APK** | Standalone APK | **Built 50.3MB** (`app-release.apk`) | **PASS** |
| **Android Release AppBundle** | Google Play AAB | **Built 52.3MB** (`app-release.aab`) | **PASS** |
| **Content Integrity** | 150 puzzle grids | **100% frozen, 0 layout changes** | **PASS** |
| **Offline Architecture** | No backend / no tracking | **100% preserved** | **PASS** |

---

## 10. Human Playtest Recommendations

Playtesters should focus on the 21 updated levels to verify that player perception aligns with the corrected feedback:

1. **Level 22 ("Ring of Saturn")**:
   - Solve in 5 moves: verify HUD displays `5 / 5`, WinDialog displays `Moves: 5`, `Optimal: 5 moves`, awarding 3 stars ("PERFECT!").
   - Take 6 moves: verify HUD displays `6 / 5` with subtle amber indicator, and Optimal Drift Nudge triggers gently.
2. **Onboarding Boundaries (Levels 4–6)**:
   - Level 4–5: verify no drift prompt appears even when exceeding par; verify manual hints work.
   - Level 6: verify prompt appears cleanly when reaching 6 moves (par is 5).
3. **Echo Calibration (Levels 11, 20, 38, 56, 85)**:
   - Verify that replaying Echo sequences does not falsely advance `moveCount` or trigger premature drift nudges.
   - Verify that solving in the corrected par moves displays "PERFECT!".
4. **Endgame Climax (Levels 141–150)**:
   - Verify that high-par levels (8–10 moves) evaluate smoothly without UI lag or memory pressure.
