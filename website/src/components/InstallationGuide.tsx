"use client";

import React from "react";
import { Download, FolderOpen, ShieldAlert, CheckCircle, Play, AlertCircle } from "lucide-react";
import { siteConfig } from "../config/site";

export function InstallationGuide() {
  const steps = [
    {
      step: 1,
      icon: Download,
      title: "Tap Download",
      instruction:
        "Click the 'Download for Android' button above to save the official shift-puzzle.apk package to your device.",
    },
    {
      step: 2,
      icon: FolderOpen,
      title: "Open the APK",
      instruction:
        "Once the download completes, tap the notification in your status bar or find 'shift-puzzle.apk' in your Downloads folder.",
    },
    {
      step: 3,
      icon: ShieldAlert,
      title: "Allow Source Permission",
      instruction:
        "If Android asks for permission to install from this source (e.g. your browser or file manager), allow it to continue. Shift Puzzle requires zero device permissions.",
    },
    {
      step: 4,
      icon: CheckCircle,
      title: "Confirm Install",
      instruction:
        "Tap 'Install' when prompted. Shift Puzzle contains zero intrusive permissions (no camera, contacts, or location requested).",
    },
    {
      step: 5,
      icon: Play,
      title: "Launch & Enjoy",
      instruction:
        "Tap 'Open' and jump straight into Level 1: First Shift. All progress saves locally and works 100% offline.",
    },
  ];

  return (
    <section id="install" className="py-20 bg-surface/40 border-t border-cardBorder">
      <div className="max-w-5xl mx-auto px-4 sm:px-6">
        <div className="text-center max-w-2xl mx-auto mb-14 space-y-3">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-surface border border-cardBorder text-xs font-bold text-slate-300 uppercase tracking-wider">
            <span>Direct Sideload Guide</span>
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
            How to Install on Android
          </h2>
          <p className="text-slate-400 text-sm sm:text-base">
            Android allows direct app installation without going through an app store. Follow these quick steps to get started in seconds.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
          {steps.map((s) => {
            const Icon = s.icon;
            return (
              <div
                key={s.step}
                className="bg-surface p-5 rounded-2xl border border-cardBorder flex flex-col justify-between space-y-3 relative group hover:border-brand/40 transition-colors"
              >
                <div>
                  <div className="flex items-center justify-between mb-3">
                    <span className="w-7 h-7 rounded-full bg-brand/10 border border-brand/25 text-brand font-black text-xs flex items-center justify-center">
                      {s.step}
                    </span>
                    <Icon className="w-5 h-5 text-slate-400 group-hover:text-brand transition-colors" />
                  </div>
                  <h3 className="font-bold text-white text-sm mb-1">
                    {s.title}
                  </h3>
                  <p className="text-xs text-slate-400 leading-relaxed">
                    {s.instruction}
                  </p>
                </div>
              </div>
            );
          })}
        </div>

        <div className="mt-8 p-4 rounded-2xl bg-amber-500/10 border border-amber-500/25 flex items-start gap-3 max-w-2xl mx-auto text-amber-200 text-xs leading-relaxed">
          <AlertCircle className="w-5 h-5 text-amber-400 shrink-0 mt-0.5" />
          <div>
            <strong>Security Notice:</strong> Only download Shift Puzzle from this official page (<code className="font-mono text-amber-300">{siteConfig.displayDomain}</code>). Never install modified APKs from untrusted third-party forums or mirrors.
          </div>
        </div>
      </div>
    </section>
  );
}
