"use client";

import React, { useEffect, useState } from "react";
import QRCode from "qrcode";
import { QrCode, Smartphone, ExternalLink, Info } from "lucide-react";
import { siteConfig } from "../config/site";

export function QrCodeSection() {
  const [qrDataUrl, setQrDataUrl] = useState<string>("");

  const downloadPageUrl = `${siteConfig.siteUrl}/download/?source=qr`;

  useEffect(() => {
    QRCode.toDataURL(downloadPageUrl, {
      width: 280,
      margin: 2,
      color: {
        dark: "#0F172A",
        light: "#FFFFFF",
      },
    })
      .then((url) => setQrDataUrl(url))
      .catch(() => {});
  }, [downloadPageUrl]);

  return (
    <section className="py-20 bg-background border-t border-cardBorder relative">
      <div className="max-w-4xl mx-auto px-4 sm:px-6">
        <div className="bg-surface rounded-3xl border border-cardBorder p-8 sm:p-10 flex flex-col md:flex-row items-center gap-8 justify-between">
          <div className="space-y-4 text-center md:text-left max-w-md">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-brand/10 border border-brand/20 text-xs font-bold text-brand uppercase tracking-wider">
              <QrCode className="w-3.5 h-3.5" />
              <span>Mobile Quick Transfer</span>
            </div>

            <h2 className="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
              SCAN TO DOWNLOAD
            </h2>

            <p className="text-slate-400 text-sm leading-relaxed">
              Browsing on a PC or laptop? Scan this code with your Android phone&apos;s camera to open the official download page directly on your device.
            </p>

            <div className="flex flex-col gap-2 text-xs text-slate-300 font-medium">
              <div className="flex items-center gap-2 justify-center md:justify-start">
                <Smartphone className="w-4 h-4 text-brand" />
                <span>Destination:</span>
                <a
                  href={downloadPageUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-brand hover:underline font-mono inline-flex items-center gap-1"
                >
                  <span>/download/?source=qr</span>
                  <ExternalLink className="w-3 h-3" />
                </a>
              </div>

              <div className="flex items-start gap-1.5 text-[11px] text-slate-500 justify-center md:justify-start">
                <Info className="w-3.5 h-3.5 shrink-0 mt-0.5 text-slate-500" />
                <span>
                  QR parameter measures web landing visits only; it is not transferred into the sideloaded APK.
                </span>
              </div>

              {siteConfig.isPlaceholderDomain && (
                <div className="text-[11px] text-amber-400/90 bg-amber-500/10 px-2.5 py-1.5 rounded-lg border border-amber-500/20 text-center md:text-left">
                  Deployment note: Configure <code className="font-mono text-amber-300">NEXT_PUBLIC_SITE_URL</code> for your live production domain.
                </div>
              )}
            </div>
          </div>

          {/* QR Code Container */}
          <div className="shrink-0 flex flex-col items-center">
            <div className="p-4 bg-white rounded-2xl shadow-xl shadow-black/50 border-4 border-slate-800">
              {qrDataUrl ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={qrDataUrl}
                  alt="Scan to Download Shift Puzzle APK"
                  width={200}
                  height={200}
                  className="rounded-lg"
                />
              ) : (
                <div className="w-[200px] h-[200px] bg-slate-100 animate-pulse rounded-lg flex items-center justify-center text-xs text-slate-400">
                  Generating QR...
                </div>
              )}
            </div>
            <span className="mt-3 text-[11px] font-extrabold uppercase tracking-widest text-slate-400">
              Shift Puzzle • Official APK
            </span>
          </div>
        </div>
      </div>
    </section>
  );
}
