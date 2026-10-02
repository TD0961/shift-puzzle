import React from "react";
import Link from "next/link";
import { ArrowLeft, ShieldCheck, CheckCircle2, XCircle } from "lucide-react";
import { siteConfig } from "../../config/site";

export const metadata = {
  title: "Privacy Policy | Shift Puzzle",
  description:
    "Privacy Policy for Shift Puzzle Android APK and website. Learn about our offline-first architecture, anonymous telemetry, and data privacy principles.",
};

export default function PrivacyPolicyPage() {
  return (
    <div className="py-16 bg-background">
      <div className="max-w-3xl mx-auto px-4 sm:px-6">
        <Link
          href="/"
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-400 hover:text-white transition-colors mb-8"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Back to Home</span>
        </Link>

        <div className="space-y-10">
          <div>
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-brand/10 border border-brand/20 text-xs font-bold text-brand uppercase tracking-wider mb-3">
              <ShieldCheck className="w-3.5 h-3.5" />
              <span>Privacy & Data Transparency</span>
            </div>
            <h1 className="text-3xl sm:text-4xl font-black text-white tracking-tight">
              Shift Puzzle Privacy Policy
            </h1>
            <p className="text-xs text-slate-500 mt-2">
              Last Updated: {siteConfig.releaseDate} • Applies to Shift Puzzle Mobile Game and Website
            </p>
          </div>

          {/* Section 1: Overview & Architecture */}
          <div className="space-y-4 text-slate-300 text-sm leading-relaxed">
            <h2 className="text-xl font-bold text-white tracking-tight">
              1. Architecture &amp; Direct APK Distribution
            </h2>
            <p>
              Shift Puzzle is distributed as a standalone Android APK directly to players. The game is engineered with an offline-first philosophy: all 150 puzzle levels, move validation, solver logic, sound effects, and player progress persist strictly on your device using local storage (<code className="font-mono text-slate-300">SharedPreferences</code>).
            </p>
            <p>
              You do not need an account, login, email address, or internet connection to play the game, solve puzzles, or unlock all levels. No user documents, photos, or personal files are ever accessed or uploaded.
            </p>
          </div>

          {/* Section 2: Data We NEVER Collect */}
          <div className="space-y-4 text-slate-300 text-sm leading-relaxed p-6 rounded-2xl bg-surface border border-cardBorder">
            <h2 className="text-xl font-bold text-white tracking-tight flex items-center gap-2">
              <XCircle className="w-5 h-5 text-rose-500" />
              <span>2. Data We Do NOT Collect</span>
            </h2>
            <p>
              Shift Puzzle strictly avoids invasive tracking. We never access, request, or store:
            </p>
            <ul className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs text-slate-300 pt-1">
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                <span>Names, emails, or phone numbers</span>
              </li>
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                <span>Precise or coarse GPS location</span>
              </li>
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                <span>Device IMEI or hardware serials</span>
              </li>
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                <span>Android Advertising ID (AAID)</span>
              </li>
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                <span>Address book or personal contacts</span>
              </li>
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                <span>Camera, microphone, or external files</span>
              </li>
            </ul>
          </div>

          {/* Section 3: Campaign Attribution & Telemetry Separation */}
          <div className="space-y-4 text-slate-300 text-sm leading-relaxed">
            <h2 className="text-xl font-bold text-white tracking-tight flex items-center gap-2">
              <CheckCircle2 className="w-5 h-5 text-emerald" />
              <span>3. Campaign Attribution &amp; Telemetry Separation</span>
            </h2>
            <p>
              To measure marketing effectiveness across social media channels, our landing website and mobile application maintain separate, privacy-respecting attribution models:
            </p>
            <div className="space-y-3 pl-2 border-l-2 border-slate-700">
              <p>
                <strong className="text-white">Website-Side Attribution:</strong> When visiting via promotional campaigns (e.g. <code className="font-mono text-slate-300">?source=tiktok</code> or <code className="font-mono text-slate-300">?source=qr</code>), the source parameter is validated and stored strictly in your browser&apos;s local storage (<code className="font-mono text-slate-300">localStorage</code>) to measure landing page conversion and download clicks. No cookies, fingerprinting, or tracking pixels are utilized.
              </p>
              <p>
                <strong className="text-white">Separation from the Sideloaded APK:</strong> Because direct APK sideloading has no app store install referrer, website campaign parameters are <strong className="text-white">never transferred to, injected into, or stored within the installed Android application</strong>.
              </p>
              <p>
                <strong className="text-white">In-App Telemetry (When Configured):</strong> If an analytics endpoint is explicitly enabled during application build, the mobile game transmits anonymous operational metrics (level starts, retries, par comparison, session duration) tagged with a purely anonymous, locally generated RFC 4122 v4 UUID (<code className="font-mono text-slate-300">installationId</code>). Direct APK builds default to a generic source tag (&quot;direct&quot;). If no telemetry endpoint is configured or if the device is offline, telemetry operates in completely silent no-op mode.
              </p>
            </div>
          </div>

          {/* Section 4: Advertising & Voluntary Sponsor Links */}
          <div className="space-y-4 text-slate-300 text-sm leading-relaxed">
            <h2 className="text-xl font-bold text-white tracking-tight">
              4. Advertising &amp; Outbound Sponsor Links
            </h2>
            <p>
              In our direct bootstrap release, we may display advertising banners or offer optional sponsored actions (such as rewarded hints or extra moves via partner sponsor links).
            </p>
            <p>
              Interacting with a sponsor offer opens an external browser tab to a partner website. Visiting external sponsor sites is subject to their respective privacy policies and terms.
            </p>
          </div>

          {/* Section 5: Children's Privacy */}
          <div className="space-y-4 text-slate-300 text-sm leading-relaxed">
            <h2 className="text-xl font-bold text-white tracking-tight">
              5. Children&apos;s Privacy
            </h2>
            <p>
              Shift Puzzle does not knowingly collect any personal information from children or adults. Because the game requires no personal registration or accounts, no personal information is held on our servers.
            </p>
          </div>

          {/* Section 6: Contact Information */}
          <div className="space-y-4 text-slate-300 text-sm leading-relaxed p-6 rounded-2xl bg-surface border border-cardBorder">
            <h2 className="text-xl font-bold text-white tracking-tight">
              6. Contact Support
            </h2>
            <p>
              If you have any questions or feedback regarding this Privacy Policy or our software, please contact our team:
            </p>
            <p className="font-mono text-brand text-xs sm:text-sm">
              {siteConfig.contactEmail}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
