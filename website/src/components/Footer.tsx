"use client";

import React from "react";
import Image from "next/image";
import Link from "next/link";
import { siteConfig } from "../config/site";

export function Footer() {

  return (
    <footer className="bg-[#05080F] border-t border-cardBorder py-14 text-slate-400 text-xs">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 space-y-10">
        <div className="flex flex-col md:flex-row items-center justify-between gap-6 pb-8 border-b border-slate-800/80">
          <div className="flex items-center gap-3">
            <div className="relative w-8 h-8 rounded-lg overflow-hidden border border-brand/30">
              <Image src="/icon.png" alt="Shift Puzzle" fill className="object-cover" />
            </div>
            <div>
              <div className="text-white font-black text-base tracking-tight">
                {siteConfig.name}
              </div>
              <p className="text-[11px] text-slate-500">
                Toroidal Matrix Puzzle Game • v{siteConfig.appVersion}
              </p>
            </div>
          </div>

          {/* Social Links & Share */}
          <div className="flex flex-wrap items-center gap-3">
            {siteConfig.socialLinks.tiktok && (
              <a
                href={siteConfig.socialLinks.tiktok}
                target="_blank"
                rel="noopener noreferrer"
                className="px-3 py-1.5 rounded-lg bg-surface border border-cardBorder hover:text-white hover:border-slate-600 transition-colors"
              >
                TikTok
              </a>
            )}
            {siteConfig.socialLinks.youtube && (
              <a
                href={siteConfig.socialLinks.youtube}
                target="_blank"
                rel="noopener noreferrer"
                className="px-3 py-1.5 rounded-lg bg-surface border border-cardBorder hover:text-white hover:border-slate-600 transition-colors"
              >
                YouTube
              </a>
            )}
            {siteConfig.socialLinks.instagram && (
              <a
                href={siteConfig.socialLinks.instagram}
                target="_blank"
                rel="noopener noreferrer"
                className="px-3 py-1.5 rounded-lg bg-surface border border-cardBorder hover:text-white hover:border-slate-600 transition-colors"
              >
                Instagram
              </a>
            )}
            {siteConfig.socialLinks.telegram && (
              <a
                href={siteConfig.socialLinks.telegram}
                target="_blank"
                rel="noopener noreferrer"
                className="px-3 py-1.5 rounded-lg bg-surface border border-cardBorder hover:text-white hover:border-slate-600 transition-colors"
              >
                Telegram
              </a>
            )}
          </div>
        </div>

        <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <Link href="/privacy" className="hover:text-white transition-colors">
              Privacy Policy
            </Link>
            <span>•</span>
            <a
              href={`mailto:${siteConfig.contactEmail}`}
              className="hover:text-white transition-colors"
            >
              Contact Support
            </a>
            <span>•</span>
            <Link href="/download" className="hover:text-white transition-colors">
              Direct Download
            </Link>
          </div>

          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-slate-900 border border-slate-800 text-[11px] text-slate-400">
            <span className="w-1.5 h-1.5 rounded-full bg-brand" />
            <span>Google Play Release Coming Soon</span>
          </div>
        </div>

        <div className="text-center text-[11px] text-slate-600 pt-4">
          &copy; {new Date().getFullYear()} Shift Puzzle. All rights reserved. Free standalone Android release.
        </div>
      </div>
    </footer>
  );
}
