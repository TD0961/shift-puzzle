"use client";

import React, { useState } from "react";
import { Download, ShieldCheck, Check, Copy } from "lucide-react";
import { siteConfig } from "../config/site";
import { trackFunnelEvent } from "../lib/analytics";

export function DownloadSection() {
  const [copiedChecksum, setCopiedChecksum] = useState(false);

  const handleDownload = () => {
    trackFunnelEvent("download_clicked", { placement: "download_card" });
  };

  const copyChecksum = () => {
    if (typeof navigator !== "undefined" && navigator.clipboard) {
      navigator.clipboard.writeText(siteConfig.apkSha256);
      setCopiedChecksum(true);
      setTimeout(() => setCopiedChecksum(false), 2500);
    }
  };

  return (
    <section id="download" className="py-20 bg-background relative">
      <div className="max-w-4xl mx-auto px-4 sm:px-6">
        <div className="bg-gradient-to-b from-surface to-[#0B101E] rounded-3xl border border-brand/30 p-8 sm:p-12 shadow-2xl shadow-brand/10 text-center relative overflow-hidden">
          {/* Subtle top glow bar */}
          <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-transparent via-brand to-transparent" />

          <div className="max-w-xl mx-auto space-y-6">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-brand/10 border border-brand/25 text-xs font-bold text-brand uppercase tracking-wider">
              <span>Official Direct Distribution</span>
            </div>

            <h2 className="text-3xl sm:text-4xl font-black text-white tracking-tight">
              Download Shift Puzzle for Android
            </h2>

            <p className="text-slate-300 text-sm sm:text-base leading-relaxed">
              Install the official standalone release directly on your Android phone or tablet. Fast, lightweight, and ready to play offline.
            </p>

            {/* Main Action Download Button */}
            <div className="pt-2">
              <a
                href={siteConfig.apkUrl}
                download="shift-puzzle.apk"
                onClick={handleDownload}
                className="w-full sm:w-auto inline-flex items-center justify-center gap-3 px-10 py-5 rounded-2xl bg-brand text-slate-950 font-black text-lg shadow-xl shadow-brand/35 hover:bg-brand-hover hover:scale-[1.02] active:scale-[0.98] transition-all"
              >
                <Download className="w-6 h-6 stroke-[2.5]" />
                <span>DOWNLOAD FOR ANDROID</span>
              </a>
              <div className="mt-2 text-[11px] text-slate-400">
                Direct APK package • No Google Play account required
              </div>
            </div>

            {/* Centralized Specification Grid */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-4 border-t border-cardBorder text-left">
              <div className="bg-surface/80 p-3 rounded-xl border border-cardBorder">
                <div className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">
                  Version
                </div>
                <div className="text-sm font-bold text-white mt-0.5">
                  v{siteConfig.appVersion}
                </div>
              </div>

              <div className="bg-surface/80 p-3 rounded-xl border border-cardBorder">
                <div className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">
                  Package Size
                </div>
                <div className="text-sm font-bold text-white mt-0.5">
                  {siteConfig.apkSize}
                </div>
              </div>

              <div className="bg-surface/80 p-3 rounded-xl border border-cardBorder">
                <div className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">
                  Requirement
                </div>
                <div className="text-sm font-bold text-white mt-0.5">
                  {siteConfig.minimumAndroidVersion}
                </div>
              </div>

              <div className="bg-surface/80 p-3 rounded-xl border border-cardBorder">
                <div className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">
                  Updated
                </div>
                <div className="text-sm font-bold text-white mt-0.5">
                  {siteConfig.releaseDate}
                </div>
              </div>
            </div>

            {/* File Integrity SHA-256 Checksum */}
            <div className="pt-2">
              <div className="p-3.5 rounded-xl bg-[#070A10] border border-cardBorder text-left">
                <div className="flex items-center justify-between mb-1.5">
                  <div className="flex items-center gap-1.5 text-xs font-bold text-slate-300">
                    <ShieldCheck className="w-4 h-4 text-emerald" />
                    <span>Official APK SHA-256 Checksum:</span>
                  </div>
                  <button
                    type="button"
                    onClick={copyChecksum}
                    className="inline-flex items-center gap-1 text-[11px] font-semibold text-brand hover:text-brand-hover transition-colors"
                  >
                    {copiedChecksum ? (
                      <>
                        <Check className="w-3.5 h-3.5 text-emerald" />
                        <span className="text-emerald">Copied!</span>
                      </>
                    ) : (
                      <>
                        <Copy className="w-3.5 h-3.5" />
                        <span>Copy Checksum</span>
                      </>
                    )}
                  </button>
                </div>
                <code className="block text-[11px] font-mono text-slate-400 break-all select-all bg-surface/60 p-2 rounded-lg border border-slate-800">
                  {siteConfig.apkSha256}
                </code>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
