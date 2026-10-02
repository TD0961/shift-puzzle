"use client";

import React, { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { Download, Menu, X, ShieldCheck } from "lucide-react";
import { siteConfig } from "../config/site";

export function Header() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <header className="sticky top-0 z-50 backdrop-blur-md bg-background/80 border-b border-cardBorder">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 h-16 flex items-center justify-between">
        <Link href="/" className="flex items-center gap-3 group">
          <div className="relative w-9 h-9 rounded-xl overflow-hidden shadow-lg shadow-brand/20 border border-brand/30 transition-transform duration-300 group-hover:scale-105">
            <Image
              src="/icon.png"
              alt="Shift Puzzle Icon"
              fill
              className="object-cover"
              priority
            />
          </div>
          <div>
            <span className="text-lg font-extrabold tracking-tight text-white group-hover:text-brand transition-colors">
              {siteConfig.name}
            </span>
            <span className="hidden sm:inline-block ml-2 text-[10px] uppercase tracking-wider font-bold bg-brand/10 text-brand px-2 py-0.5 rounded-full border border-brand/20">
              v{siteConfig.appVersion}
            </span>
          </div>
        </Link>

        {/* Desktop Navigation */}
        <nav className="hidden md:flex items-center gap-7 text-sm font-medium text-text-muted">
          <a
            href="#gameplay"
            className="hover:text-white transition-colors py-1"
          >
            Gameplay
          </a>
          <a
            href="#mechanics"
            className="hover:text-white transition-colors py-1"
          >
            Mechanics
          </a>
          <a
            href="#install"
            className="hover:text-white transition-colors py-1"
          >
            Install Guide
          </a>
          <a
            href="#security"
            className="hover:text-white transition-colors py-1 flex items-center gap-1.5"
          >
            <ShieldCheck className="w-4 h-4 text-emerald" />
            Security
          </a>
        </nav>

        {/* Action Button */}
        <div className="hidden sm:flex items-center gap-3">
          <a
            href="#download"
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-brand text-slate-950 font-bold text-sm shadow-md shadow-brand/25 hover:bg-brand-hover hover:scale-[1.02] active:scale-[0.98] transition-all"
          >
            <Download className="w-4 h-4" />
            <span>Download APK</span>
          </a>
        </div>

        {/* Mobile Hamburger Button */}
        <button
          type="button"
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          className="md:hidden p-2 rounded-lg text-slate-400 hover:text-white hover:bg-surface"
          aria-label="Toggle mobile menu"
        >
          {mobileMenuOpen ? (
            <X className="w-6 h-6" />
          ) : (
            <Menu className="w-6 h-6" />
          )}
        </button>
      </div>

      {/* Mobile Menu Dropdown */}
      {mobileMenuOpen && (
        <div className="md:hidden bg-surface border-b border-cardBorder px-4 pt-2 pb-6 space-y-3">
          <a
            href="#gameplay"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-lg text-base font-medium text-slate-200 hover:bg-surfaceLight"
          >
            Gameplay
          </a>
          <a
            href="#mechanics"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-lg text-base font-medium text-slate-200 hover:bg-surfaceLight"
          >
            Mechanics
          </a>
          <a
            href="#install"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-lg text-base font-medium text-slate-200 hover:bg-surfaceLight"
          >
            Install Guide
          </a>
          <a
            href="#security"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-lg text-base font-medium text-slate-200 hover:bg-surfaceLight flex items-center gap-2"
          >
            <ShieldCheck className="w-4 h-4 text-emerald" />
            Security & Trust
          </a>
          <div className="pt-2">
            <a
              href="#download"
              onClick={() => setMobileMenuOpen(false)}
              className="w-full flex items-center justify-center gap-2 px-4 py-3 rounded-xl bg-brand text-slate-950 font-bold text-sm shadow-md"
            >
              <Download className="w-4 h-4" />
              <span>Download for Android</span>
            </a>
          </div>
        </div>
      )}
    </header>
  );
}
