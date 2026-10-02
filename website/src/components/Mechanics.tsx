"use client";

import React from "react";
import { Grid, History, Compass, Award } from "lucide-react";

export function Mechanics() {
  const mechanics = [
    {
      icon: Grid,
      title: "Toroidal Matrix Shifts",
      color: "text-brand",
      borderColor: "border-brand/30",
      bgGlow: "group-hover:bg-brand/5",
      description:
        "Swipe any row or column. Pieces wrap effortlessly around opposing edges in a continuous topological loop, turning simple shifts into deep geometry.",
    },
    {
      icon: History,
      title: "Signature Memory Echo",
      color: "text-purple-400",
      borderColor: "border-purple-500/30",
      bgGlow: "group-hover:bg-purple-500/5",
      description:
        "In Echo levels, previous moves repeat automatically. Coordinate your manual adjustments with past momentum to solve temporal sequences.",
    },
    {
      icon: Compass,
      title: "Optimal Drift Coach",
      color: "text-gold",
      borderColor: "border-gold/30",
      bgGlow: "group-hover:bg-gold/5",
      description:
        "Struggling off the beaten path? The smart solver notices when you drift away from minimal par and offers subtle guidance without spoiling the solution.",
    },
    {
      icon: Award,
      title: "Strict Mathematical Par",
      color: "text-emerald",
      borderColor: "border-emerald/30",
      bgGlow: "group-hover:bg-emerald/5",
      description:
        "Every single level is mathematically verified by our breadth-first search solver. There is always a clean, elegant, minimal path to 3 gold stars.",
    },
  ];

  return (
    <section id="mechanics" className="py-20 bg-background relative">
      <div className="max-w-6xl mx-auto px-4 sm:px-6">
        <div className="text-center max-w-2xl mx-auto mb-16 space-y-3">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-surface border border-cardBorder text-xs font-bold text-slate-300 uppercase tracking-wider">
            <span>Core Game Systems</span>
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
            Tactical Depth In Every Swipe
          </h2>
          <p className="text-slate-400 text-sm sm:text-base">
            Shift Puzzle combines minimal spatial rules with progressive mechanics that challenge both quick instincts and deep tactical foresight.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {mechanics.map((item, idx) => {
            const Icon = item.icon;
            return (
              <div
                key={idx}
                className={`group p-8 rounded-3xl bg-surface border ${item.borderColor} transition-all duration-300 hover:-translate-y-1 hover:shadow-2xl ${item.bgGlow}`}
              >
                <div className="flex items-center gap-4 mb-4">
                  <div className={`p-3 rounded-2xl bg-surfaceLight/80 border border-slate-700/60 ${item.color}`}>
                    <Icon className="w-6 h-6" />
                  </div>
                  <h3 className="text-xl font-bold text-white tracking-tight">
                    {item.title}
                  </h3>
                </div>
                <p className="text-slate-400 text-sm leading-relaxed">
                  {item.description}
                </p>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
