"use client";

import React, { useEffect } from "react";
import { Hero } from "../components/Hero";
import { GameplayDemo } from "../components/GameplayDemo";
import { Mechanics } from "../components/Mechanics";
import { Features } from "../components/Features";
import { DownloadSection } from "../components/DownloadSection";
import { InstallationGuide } from "../components/InstallationGuide";
import { QrCodeSection } from "../components/QrCodeSection";
import { TrustSection } from "../components/TrustSection";
import { AdsterraBanner } from "../components/AdsterraBanner";
import { AdsterraNativeBanner } from "../components/AdsterraNativeBanner";
import { trackFunnelEvent, getAcquisitionSource } from "../lib/analytics";

export default function HomePage() {
  useEffect(() => {
    // Record page view with source attribution on mount
    const source = getAcquisitionSource();
    trackFunnelEvent("landing_page_view", { source, page: "home" });
  }, []);

  return (
    <>
      <Hero />
      <GameplayDemo />
      <div className="hidden sm:block">
        <AdsterraBanner format="728x90" />
      </div>
      <div className="sm:hidden">
        <AdsterraBanner format="300x250" />
      </div>
      <Mechanics />
      <Features />
      <DownloadSection />
      <AdsterraNativeBanner />
      <InstallationGuide />
      <QrCodeSection />
      <TrustSection />
    </>
  );
}
