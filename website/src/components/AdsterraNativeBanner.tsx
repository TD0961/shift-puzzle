"use client";

import React, { useEffect, useRef } from "react";

interface AdsterraNativeBannerProps {
  className?: string;
}

export function AdsterraNativeBanner({ className = "" }: AdsterraNativeBannerProps) {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Only load in browser
    if (typeof window === "undefined" || !containerRef.current) return;

    // Avoid injecting multiple times
    const containerId = "container-cd99dbb1b76a5f269b5e406e4202a35b";
    let target = document.getElementById(containerId);
    if (!target) {
      target = document.createElement("div");
      target.id = containerId;
      containerRef.current.appendChild(target);
    }

    const scriptSrc = "https://bellnewyork.org/21/cd99dbb1b76a5f269b5e406e4202a35b";
    const existingScript = document.querySelector(`script[src="${scriptSrc}"]`);
    if (!existingScript) {
      const script = document.createElement("script");
      script.type = "text/javascript";
      script.async = true;
      script.setAttribute("data-cfasync", "false");
      script.src = scriptSrc;
      containerRef.current.appendChild(script);
    }
  }, []);

  return (
    <section className={`py-8 max-w-4xl mx-auto px-4 text-center ${className}`}>
      <div className="text-[11px] uppercase tracking-wider text-slate-500 font-semibold mb-3">
        Sponsored Recommendations
      </div>
      <div
        ref={containerRef}
        className="min-h-[100px] flex items-center justify-center rounded-2xl bg-surface/40 border border-cardBorder p-4 overflow-hidden"
      >
        <div id="container-cd99dbb1b76a5f269b5e406e4202a35b" />
      </div>
    </section>
  );
}
