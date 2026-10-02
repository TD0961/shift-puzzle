"use client";

import React from "react";
import { ExternalLink, HeartHandshake, Info } from "lucide-react";
import { siteConfig } from "../config/site";
import { trackFunnelEvent } from "../lib/analytics";

export function SmartLinkSection() {
  // If the SmartLink URL is absent, do NOT render this section at all
  if (!siteConfig.smartLinkUrl || siteConfig.smartLinkUrl.trim().length === 0) {
    return null;
  }

  const handleSmartLinkClick = () => {
    trackFunnelEvent("smartlink_clicked", { placement: "landing_optional_sponsor" });
  };

  return (
    <section className="py-14 bg-surface/30 border-t border-cardBorder relative">
      <div className="max-w-3xl mx-auto px-4 sm:px-6 text-center">
        <div className="p-6 sm:p-8 rounded-3xl bg-surface border border-cardBorder shadow-lg space-y-4">
          <div className="w-10 h-10 rounded-xl bg-purple-500/10 border border-purple-500/20 text-purple-400 flex items-center justify-center mx-auto">
            <HeartHandshake className="w-5 h-5" />
          </div>

          <h3 className="text-xl sm:text-2xl font-bold text-white tracking-tight">
            Enjoying Shift Puzzle? Support Development
          </h3>

          <p className="text-slate-400 text-xs sm:text-sm max-w-md mx-auto leading-relaxed">
            Shift Puzzle is 100% free with no microtransactions. If you would like to help fund upcoming chapters and Google Play publishing, you can check out an offer from our partner sponsor.
          </p>

          <div className="pt-2">
            <a
              href={siteConfig.smartLinkUrl}
              target="_blank"
              rel="noopener noreferrer sponsored"
              onClick={handleSmartLinkClick}
              className="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-surfaceLight hover:bg-slate-700 text-purple-300 border border-purple-500/30 font-semibold text-sm transition-all hover:scale-[1.02] active:scale-[0.98]"
            >
              <span>Discover an Offer / Support Game</span>
              <ExternalLink className="w-4 h-4" />
            </a>
          </div>

          <div className="flex items-center justify-center gap-1.5 text-[11px] text-slate-500">
            <Info className="w-3.5 h-3.5" />
            <span>Optional external advertising destination. No in-game items or rewards are granted.</span>
          </div>
        </div>
      </div>
    </section>
  );
}
