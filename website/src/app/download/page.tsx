"use client";

import React, { useEffect, useState } from "react";
import Link from "next/link";
import { DownloadSection } from "../../components/DownloadSection";
import { InstallationGuide } from "../../components/InstallationGuide";
import { SmartLinkSection } from "../../components/SmartLinkSection";
import { TrustSection } from "../../components/TrustSection";
import { AdsterraNativeBanner } from "../../components/AdsterraNativeBanner";
import { trackFunnelEvent, getAcquisitionSource, AcquisitionSource } from "../../lib/analytics";
import { ArrowLeft, Sparkles } from "lucide-react";

export default function DownloadPage() {
  const [source, setSource] = useState<AcquisitionSource>("direct");

  useEffect(() => {
    const detected = getAcquisitionSource();
    setSource(detected);
    trackFunnelEvent("landing_page_view", { source: detected, page: "download" });
  }, []);

  return (
    <div className="pt-6 pb-20">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 mb-4 flex items-center justify-between">
        <Link
          href="/"
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-400 hover:text-white transition-colors"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Back to Overview</span>
        </Link>

        {source !== "direct" && (
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-brand/10 border border-brand/20 text-xs font-bold text-brand uppercase tracking-wider" title="Website-side acquisition attribution. Sideloaded APKs operate with offline local analytics.">
            <Sparkles className="w-3.5 h-3.5" />
            <span>Website Referral: {source}</span>
          </div>
        )}
      </div>

      <DownloadSection />
      <AdsterraNativeBanner />
      <InstallationGuide />
      <SmartLinkSection />
      <TrustSection />
    </div>
  );
}
