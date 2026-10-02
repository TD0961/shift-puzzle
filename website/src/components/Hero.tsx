"use client";

import React from "react";
import Image from "next/image";
import { Download, PlayCircle, ShieldCheck, Sparkles } from "lucide-react";
import { siteConfig } from "../config/site";
import { trackFunnelEvent } from "../lib/analytics";

export function Hero() {
  const handleDownloadClick = () => {
    trackFunnelEvent("download_clicked", { placement: "hero_primary" });
  };

  const handleWatchClick = () => {
    trackFunnelEvent("gameplay_viewed", { placement: "hero_secondary" });
  };

  return (
    <section className="relative overflow-hidden pt-12 pb-20 md:pt-20 md:pb-28">
      {/* Background radial glow */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[550px] h-[550px] bg-brand/10 rounded-full blur-[140px] pointer-events-none" />
      <div className="absolute top-1/3 right-10 w-[300px] h-[300px] bg-gold/5 rounded-full blur-[100px] pointer-events-none" />

      <div className="max-w-6xl mx-auto px-4 sm:px-6 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          {/* Left Column: Core Value Proposition & CTAs */}
          <div className="lg:col-span-7 text-center lg:text-left space-y-6">
            {/* Top pill badge */}
            <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-surface border border-cardBorder text-xs font-semibold text-slate-300 shadow-sm">
              <span className="flex h-2 w-2 rounded-full bg-brand animate-pulse" />
              <span>Direct Android Release • 100% Offline Playable</span>
            </div>

            <h1 className="text-4xl sm:text-5xl md:text-6xl font-black tracking-tight text-white leading-[1.1]">
              SHIFT <span className="text-brand">PUZZLE</span>
            </h1>

            <p className="text-lg sm:text-xl text-slate-300 font-medium max-w-2xl mx-auto lg:mx-0 leading-relaxed">
              A satisfying tactical puzzle where every move changes the board.
            </p>

            <p className="text-sm sm:text-base text-slate-400 max-w-xl mx-auto lg:mx-0">
              Shift entire rows and columns across a 5×5 toroidal matrix. Plan
              optimal moves, harness signature memory echoes, and conquer 150
              handcrafted challenges.
            </p>

            {/* CTAs */}
            <div className="pt-2 flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4">
              <a
                href={siteConfig.apkUrl}
                download="shift-puzzle.apk"
                onClick={handleDownloadClick}
                className="w-full sm:w-auto inline-flex items-center justify-center gap-3 px-8 py-4 rounded-2xl bg-brand text-slate-950 font-black text-base shadow-xl shadow-brand/30 hover:bg-brand-hover hover:scale-[1.02] active:scale-[0.98] transition-all"
              >
                <Download className="w-5 h-5 stroke-[2.5]" />
                <span>DOWNLOAD FOR ANDROID</span>
              </a>

              <a
                href="#gameplay"
                onClick={handleWatchClick}
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 px-6 py-4 rounded-2xl bg-surface hover:bg-surfaceLight text-slate-200 border border-cardBorder font-semibold text-base transition-all"
              >
                <PlayCircle className="w-5 h-5 text-brand" />
                <span>WATCH GAMEPLAY</span>
              </a>
            </div>

            {/* Trust and Spec Badges */}
            <div className="pt-4 flex flex-wrap items-center justify-center lg:justify-start gap-4 text-xs text-slate-400">
              <div className="flex items-center gap-1.5 bg-surface/70 px-3 py-1.5 rounded-lg border border-cardBorder">
                <span className="font-semibold text-slate-200">APK Size:</span>
                <span>{siteConfig.apkSize}</span>
              </div>
              <div className="flex items-center gap-1.5 bg-surface/70 px-3 py-1.5 rounded-lg border border-cardBorder">
                <span className="font-semibold text-slate-200">Requires:</span>
                <span>{siteConfig.minimumAndroidVersion}</span>
              </div>
              <div className="flex items-center gap-1.5 bg-surface/70 px-3 py-1.5 rounded-lg border border-cardBorder">
                <ShieldCheck className="w-4 h-4 text-emerald" />
                <span className="font-semibold text-slate-200">Release Verified</span>
              </div>
            </div>
          </div>

          {/* Right Column: Hero Visual Graphic */}
          <div className="lg:col-span-5 flex justify-center">
            <div className="relative w-full max-w-[340px] sm:max-w-[380px] aspect-square">
              {/* Outer pulsing glow */}
              <div className="absolute inset-0 rounded-[40px] bg-gradient-to-tr from-brand/30 to-gold/20 blur-2xl transform scale-95 animate-pulse-subtle" />

              {/* Main App Icon Container */}
              <div className="relative w-full h-full rounded-[38px] p-2 bg-gradient-to-b from-brand/30 to-slate-800/80 shadow-2xl border border-brand/40 overflow-hidden group">
                <div className="relative w-full h-full rounded-[30px] overflow-hidden bg-surface">
                  <Image
                    src="/icon.png"
                    alt="Shift Puzzle Gameplay Icon"
                    fill
                    className="object-cover transition-transform duration-500 group-hover:scale-105"
                    priority
                  />
                  {/* Floating floating mini-badge */}
                  <div className="absolute bottom-3 left-3 right-3 p-3 rounded-2xl bg-surface/85 backdrop-blur-md border border-cardBorder flex items-center justify-between">
                    <div>
                      <div className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">
                        150 Levels
                      </div>
                      <div className="text-xs font-extrabold text-white flex items-center gap-1">
                        <Sparkles className="w-3.5 h-3.5 text-gold" />
                        <span>Toroidal Shift Logic</span>
                      </div>
                    </div>
                    <span className="text-[10px] font-bold px-2 py-1 rounded bg-brand/15 text-brand border border-brand/30">
                      FREE APK
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
