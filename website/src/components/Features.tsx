"use client";

import React from "react";
import { Layers, WifiOff, Lock, Zap } from "lucide-react";

export function Features() {
  const features = [
    {
      icon: Layers,
      title: "150 Handcrafted Levels",
      description:
        "15 progressive thematic chapters designed by hand. Every puzzle introduces new spatial twists without repetitive filler.",
    },
    {
      icon: WifiOff,
      title: "100% Offline Playable",
      description:
        "Play in airplane mode, subway transit, or remote off-grid locations. Your progress and best moves save entirely locally.",
    },
    {
      icon: Lock,
      title: "Zero Accounts & No Pay-To-Win",
      description:
        "No signup forms, no passwords, no artificial energy bars, and no push notifications interrupting your life.",
    },
    {
      icon: Zap,
      title: "Instant 60fps Performance",
      description:
        "Under 55 MB download size. Starts instantly on Android 6.0+ devices with responsive touch animations and haptic feedback.",
    },
  ];

  return (
    <section className="py-20 bg-surface/30 border-y border-cardBorder">
      <div className="max-w-6xl mx-auto px-4 sm:px-6">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
          {features.map((feat, idx) => {
            const Icon = feat.icon;
            return (
              <div key={idx} className="space-y-3">
                <div className="w-12 h-12 rounded-2xl bg-brand/10 border border-brand/20 flex items-center justify-center text-brand">
                  <Icon className="w-6 h-6" />
                </div>
                <h3 className="text-lg font-bold text-white tracking-tight">
                  {feat.title}
                </h3>
                <p className="text-xs sm:text-sm text-slate-400 leading-relaxed">
                  {feat.description}
                </p>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
