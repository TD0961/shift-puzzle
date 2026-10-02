"use client";

import React, { useState } from "react";
import Image from "next/image";
import { ArrowLeft, ArrowRight, ArrowUp, ArrowDown, Sparkles, CheckCircle2 } from "lucide-react";

export function GameplayDemo() {
  // Simple 5x5 board state simulation to demonstrate toroidal row/column shift
  // 0: empty, 1: blue circle, 2: gold diamond, 3: target
  const initialGrid = [
    [0, 0, 0, 0, 0],
    [0, 0, 3, 0, 0],
    [0, 1, 0, 0, 0],
    [0, 0, 2, 0, 0],
    [0, 0, 0, 0, 0],
  ];

  const [grid, setGrid] = useState<number[][]>(initialGrid);
  const [moves, setMoves] = useState(0);

  // Shift row right with toroidal wrap
  const shiftRowRight = (rowIndex: number) => {
    setGrid((prev) => {
      const next = prev.map((row) => [...row]);
      const last = next[rowIndex][4];
      for (let c = 4; c > 0; c--) {
        next[rowIndex][c] = next[rowIndex][c - 1];
      }
      next[rowIndex][0] = last;
      return next;
    });
    setMoves((m) => m + 1);
  };

  // Shift row left with toroidal wrap
  const shiftRowLeft = (rowIndex: number) => {
    setGrid((prev) => {
      const next = prev.map((row) => [...row]);
      const first = next[rowIndex][0];
      for (let c = 0; c < 4; c++) {
        next[rowIndex][c] = next[rowIndex][c + 1];
      }
      next[rowIndex][4] = first;
      return next;
    });
    setMoves((m) => m + 1);
  };

  // Shift column down with toroidal wrap
  const shiftColDown = (colIndex: number) => {
    setGrid((prev) => {
      const next = prev.map((row) => [...row]);
      const last = next[4][colIndex];
      for (let r = 4; r > 0; r--) {
        next[r][colIndex] = next[r - 1][colIndex];
      }
      next[0][colIndex] = last;
      return next;
    });
    setMoves((m) => m + 1);
  };

  // Shift column up with toroidal wrap
  const shiftColUp = (colIndex: number) => {
    setGrid((prev) => {
      const next = prev.map((row) => [...row]);
      const first = next[0][colIndex];
      for (let r = 0; r < 4; r++) {
        next[r][colIndex] = next[r + 1][colIndex];
      }
      next[4][colIndex] = first;
      return next;
    });
    setMoves((m) => m + 1);
  };

  const resetSimulation = () => {
    setGrid(initialGrid);
    setMoves(0);
  };

  return (
    <section id="gameplay" className="py-20 bg-surface/50 border-y border-cardBorder relative">
      <div className="max-w-6xl mx-auto px-4 sm:px-6">
        <div className="text-center max-w-2xl mx-auto mb-14 space-y-3">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-brand/10 border border-brand/20 text-xs font-bold text-brand uppercase tracking-wider">
            <Sparkles className="w-3.5 h-3.5" />
            <span>Interactive Demonstration</span>
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
            How The Board Shifts
          </h2>
          <p className="text-slate-400 text-sm sm:text-base">
            Pieces don&apos;t move in isolation. When you swipe a row or column, the entire line moves together and wraps seamlessly across opposite edges.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 items-center">
          {/* Interactive Board Simulator */}
          <div className="lg:col-span-6 bg-surface p-6 sm:p-8 rounded-3xl border border-cardBorder shadow-2xl flex flex-col items-center">
            <div className="flex items-center justify-between w-full mb-6">
              <span className="text-xs font-extrabold uppercase tracking-wider text-slate-400">
                Interactive 5×5 Matrix
              </span>
              <div className="flex items-center gap-3">
                <span className="text-xs font-semibold text-slate-300 bg-surfaceLight px-2.5 py-1 rounded-md">
                  Moves: <strong className="text-brand font-mono">{moves}</strong>
                </span>
                <button
                  type="button"
                  onClick={resetSimulation}
                  className="text-xs font-semibold text-slate-400 hover:text-white underline transition-colors"
                >
                  Reset
                </button>
              </div>
            </div>

            {/* Board Container with controls */}
            <div className="relative p-3 rounded-2xl bg-[#070A10] border border-cardBorder">
              {/* Top Shift Controls */}
              <div className="flex justify-around mb-2 px-1">
                {[0, 1, 2, 3, 4].map((c) => (
                  <button
                    key={`up-${c}`}
                    type="button"
                    onClick={() => shiftColUp(c)}
                    className="p-1 rounded text-slate-500 hover:text-brand hover:bg-surfaceLight transition-colors"
                    title={`Shift Col ${c + 1} Up`}
                  >
                    <ArrowUp className="w-4 h-4" />
                  </button>
                ))}
              </div>

              <div className="flex items-center gap-2">
                {/* Left Shift Controls */}
                <div className="flex flex-col justify-around h-60 py-1">
                  {[0, 1, 2, 3, 4].map((r) => (
                    <button
                      key={`left-${r}`}
                      type="button"
                      onClick={() => shiftRowLeft(r)}
                      className="p-1 rounded text-slate-500 hover:text-brand hover:bg-surfaceLight transition-colors"
                      title={`Shift Row ${r + 1} Left`}
                    >
                      <ArrowLeft className="w-4 h-4" />
                    </button>
                  ))}
                </div>

                {/* 5x5 Grid */}
                <div className="grid grid-cols-5 gap-2 w-60 h-60 p-2 bg-surface/80 rounded-xl border border-slate-800">
                  {grid.map((row, r) =>
                    row.map((cell, c) => (
                      <div
                        key={`${r}-${c}`}
                        className={`rounded-lg flex items-center justify-center transition-all duration-200 border ${
                          cell === 1
                            ? "bg-brand/20 border-brand shadow-lg shadow-brand/40"
                            : cell === 2
                            ? "bg-gold/20 border-gold shadow-lg shadow-gold/40"
                            : cell === 3
                            ? "bg-slate-800/80 border-slate-700 border-dashed"
                            : "bg-surfaceLight/40 border-slate-800/60"
                        }`}
                      >
                        {cell === 1 && (
                          <div className="w-6 h-6 rounded-full bg-brand shadow-md shadow-brand/60 animate-pulse" />
                        )}
                        {cell === 2 && (
                          <div className="w-5 h-5 bg-gold rotate-45 rounded-sm shadow-md shadow-gold/60" />
                        )}
                        {cell === 3 && (
                          <div className="w-2.5 h-2.5 rounded-full bg-brand/40 ring-4 ring-brand/10" />
                        )}
                      </div>
                    ))
                  )}
                </div>

                {/* Right Shift Controls */}
                <div className="flex flex-col justify-around h-60 py-1">
                  {[0, 1, 2, 3, 4].map((r) => (
                    <button
                      key={`right-${r}`}
                      type="button"
                      onClick={() => shiftRowRight(r)}
                      className="p-1 rounded text-slate-500 hover:text-brand hover:bg-surfaceLight transition-colors"
                      title={`Shift Row ${r + 1} Right`}
                    >
                      <ArrowRight className="w-4 h-4" />
                    </button>
                  ))}
                </div>
              </div>

              {/* Bottom Shift Controls */}
              <div className="flex justify-around mt-2 px-1">
                {[0, 1, 2, 3, 4].map((c) => (
                  <button
                    key={`down-${c}`}
                    type="button"
                    onClick={() => shiftColDown(c)}
                    className="p-1 rounded text-slate-500 hover:text-brand hover:bg-surfaceLight transition-colors"
                    title={`Shift Col ${c + 1} Down`}
                  >
                    <ArrowDown className="w-4 h-4" />
                  </button>
                ))}
              </div>
            </div>

            <p className="mt-4 text-xs text-slate-400 text-center">
              Tap the arrows above, below, or beside any row/column to see the toroidal wrap in action.
            </p>
          </div>

          {/* Real In-Game Screenshots Card */}
          <div className="lg:col-span-6 space-y-6">
            <div className="bg-surface rounded-3xl border border-cardBorder overflow-hidden shadow-xl p-2">
              <div className="relative aspect-[16/9] w-full rounded-2xl overflow-hidden bg-black/60">
                <Image
                  src="/screenshots/level4.png"
                  alt="Shift Puzzle Level 4 Gameplay Screenshot"
                  fill
                  className="object-cover"
                />
                <div className="absolute top-3 left-3 bg-surface/90 backdrop-blur-md px-3 py-1 rounded-full border border-cardBorder text-xs font-bold text-white flex items-center gap-1.5">
                  <CheckCircle2 className="w-3.5 h-3.5 text-emerald" />
                  <span>Level 4: Crossroads</span>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="bg-surface p-4 rounded-2xl border border-cardBorder">
                <div className="text-brand font-black text-xl mb-1">Toroidal Wrap</div>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Moving off the right side reappears on the left. The board is a continuous closed surface.
                </p>
              </div>
              <div className="bg-surface p-4 rounded-2xl border border-cardBorder">
                <div className="text-gold font-black text-xl mb-1">Minimal Par</div>
                <p className="text-xs text-slate-400 leading-relaxed">
                  Every level features an exact mathematical par. Can you find the globally optimal solution?
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
