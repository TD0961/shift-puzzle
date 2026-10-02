"use client";

import React, { useState } from "react";
import Link from "next/link";
import { ShieldCheck, Check, Copy, KeyRound, FileCheck } from "lucide-react";
import { siteConfig } from "../config/site";

export function TrustSection() {
  const [copiedFileHash, setCopiedFileHash] = useState(false);
  const [copiedCertHash, setCopiedCertHash] = useState(false);

  const copyText = (text: string, isCert: boolean) => {
    if (typeof navigator !== "undefined" && navigator.clipboard) {
      navigator.clipboard.writeText(text);
      if (isCert) {
        setCopiedCertHash(true);
        setTimeout(() => setCopiedCertHash(false), 2500);
      } else {
        setCopiedFileHash(true);
        setTimeout(() => setCopiedFileHash(false), 2500);
      }
    }
  };

  return (
    <section id="security" className="py-20 bg-background border-t border-cardBorder">
      <div className="max-w-4xl mx-auto px-4 sm:px-6">
        <div className="text-center max-w-xl mx-auto mb-12 space-y-3">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-xs font-bold text-emerald uppercase tracking-wider">
            <ShieldCheck className="w-3.5 h-3.5" />
            <span>Cryptographic Integrity</span>
          </div>
          <h2 className="text-3xl font-extrabold text-white tracking-tight">
            Security, Integrity & Trust
          </h2>
          <p className="text-slate-400 text-sm">
            We value your security. Every official APK release is signed with our permanent release key and mathematically verifiable.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* APK File SHA-256 */}
          <div className="p-6 rounded-2xl bg-surface border border-cardBorder space-y-3 flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2 text-sm font-bold text-white">
                  <FileCheck className="w-4 h-4 text-brand" />
                  <span>APK File SHA-256 Checksum</span>
                </div>
                <button
                  type="button"
                  onClick={() => copyText(siteConfig.apkSha256, false)}
                  className="text-xs text-brand hover:underline inline-flex items-center gap-1"
                >
                  {copiedFileHash ? (
                    <>
                      <Check className="w-3.5 h-3.5 text-emerald" />
                      <span className="text-emerald">Copied</span>
                    </>
                  ) : (
                    <>
                      <Copy className="w-3.5 h-3.5" />
                      <span>Copy</span>
                    </>
                  )}
                </button>
              </div>
              <p className="text-xs text-slate-400 leading-relaxed mb-3">
                Use <code className="font-mono text-slate-300">sha256sum shift-puzzle.apk</code> to verify that the file downloaded matches our build artifact bit-for-bit.
              </p>
            </div>
            <code className="block text-[11px] font-mono text-slate-300 break-all select-all bg-[#070A10] p-3 rounded-xl border border-slate-800">
              {siteConfig.apkSha256}
            </code>
          </div>

          {/* Signing Certificate SHA-256 */}
          <div className="p-6 rounded-2xl bg-surface border border-cardBorder space-y-3 flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2 text-sm font-bold text-white">
                  <KeyRound className="w-4 h-4 text-gold" />
                  <span>Release Certificate Fingerprint</span>
                </div>
                <button
                  type="button"
                  onClick={() => copyText(siteConfig.certFingerprint, true)}
                  className="text-xs text-brand hover:underline inline-flex items-center gap-1"
                >
                  {copiedCertHash ? (
                    <>
                      <Check className="w-3.5 h-3.5 text-emerald" />
                      <span className="text-emerald">Copied</span>
                    </>
                  ) : (
                    <>
                      <Copy className="w-3.5 h-3.5" />
                      <span>Copy</span>
                    </>
                  )}
                </button>
              </div>
              <p className="text-xs text-slate-400 leading-relaxed mb-3">
                The permanent Android cryptographic certificate that signs every APK and AAB bundle. Never accepts debug keys.
              </p>
            </div>
            <code className="block text-[11px] font-mono text-slate-300 break-all select-all bg-[#070A10] p-3 rounded-xl border border-slate-800">
              {siteConfig.certFingerprint}
            </code>
          </div>
        </div>

        {/* Security Disclosures */}
        <div className="mt-8 text-center text-xs text-slate-400 space-y-2">
          <p>
            Shift Puzzle requests zero invasive permissions. Learn more about our privacy commitments in our{" "}
            <Link href="/privacy" className="text-brand hover:underline font-semibold">
              Privacy Policy
            </Link>
            .
          </p>
        </div>
      </div>
    </section>
  );
}
