"use client";

import React, { useEffect } from "react";
import { Hero } from "../components/Hero";
import { GameplayDemo } from "../components/GameplayDemo";
import { Mechanics } from "../components/Mechanics";
import { Features } from "../components/Features";
import { DownloadSection } from "../components/DownloadSection";
import { InstallationGuide } from "../components/InstallationGuide";
import { QrCodeSection } from "../components/QrCodeSection";
import { SmartLinkSection } from "../components/SmartLinkSection";
import { TrustSection } from "../components/TrustSection";
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
      <Mechanics />
      <Features />
      <DownloadSection />
      <InstallationGuide />
      <QrCodeSection />
      <SmartLinkSection />
      <TrustSection />
    </>
  );
}
