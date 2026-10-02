export interface SiteConfig {
  name: string;
  tagline: string;
  description: string;
  appVersion: string;
  apkSize: string;
  minimumAndroidVersion: string;
  targetAndroidVersion: string;
  releaseDate: string;
  /** Canonical base URL of the website. Configured via NEXT_PUBLIC_SITE_URL or NEXT_PUBLIC_CANONICAL_URL. */
  siteUrl: string;
  /** Whether the current siteUrl is an unverified placeholder rather than a confirmed live production domain. */
  isPlaceholderDomain: boolean;
  /** Clean hostname for display purposes (e.g. 'shiftpuzzle.app' or 'shift-puzzle.pages.dev'). */
  displayDomain: string;
  /** Primary APK download destination. Supports external CDN/object storage (NEXT_PUBLIC_APK_URL) or local fallback. */
  apkUrl: string;
  /** Whether the APK URL points to an external object storage/CDN rather than the local website fallback. */
  isExternalApkUrl: boolean;
  /** Official release APK file SHA-256 checksum for cryptographic verification. */
  apkSha256: string;
  /** Permanent release signing certificate SHA-256 fingerprint. */
  certFingerprint: string;
  /** Optional Adsterra SmartLink URL for voluntary sponsor support. Disabled if unset. */
  smartLinkUrl?: string;
  /** Optional telemetry endpoint. Disabled if unset. */
  analyticsEndpoint?: string;
  /** Support contact email. */
  contactEmail: string;
  socialLinks: {
    tiktok?: string;
    youtube?: string;
    instagram?: string;
    facebook?: string;
    telegram?: string;
  };
}

// Resolve site URL with explicit placeholder detection
const configuredSiteUrl =
  process.env.NEXT_PUBLIC_SITE_URL || process.env.NEXT_PUBLIC_CANONICAL_URL;
const DEFAULT_PLACEHOLDER_URL = "https://shiftpuzzle.app";
const rawSiteUrl = configuredSiteUrl && configuredSiteUrl.trim().length > 0
  ? configuredSiteUrl.trim().replace(/\/+$/, "")
  : DEFAULT_PLACEHOLDER_URL;

let resolvedDisplayDomain = "shiftpuzzle.app";
try {
  resolvedDisplayDomain = new URL(rawSiteUrl).hostname;
} catch {
  resolvedDisplayDomain = "shiftpuzzle.app";
}

// Resolve APK URL
const DEFAULT_PUBLIC_APK_URL =
  "https://github.com/TD0961/shift-puzzle/releases/download/v1.0.0/app-release.apk";
const configuredApkUrl = process.env.NEXT_PUBLIC_APK_URL;
const rawApkUrl =
  configuredApkUrl && configuredApkUrl.trim().length > 0
    ? configuredApkUrl.trim()
    : DEFAULT_PUBLIC_APK_URL;
const isExternal = Boolean(
  rawApkUrl.startsWith("http://") || rawApkUrl.startsWith("https://")
);
const resolvedApkUrl = rawApkUrl;

export const siteConfig: SiteConfig = {
  name: "Shift Puzzle",
  tagline: "A satisfying tactical puzzle where every move changes the board.",
  description:
    "Shift entire rows and columns across a 5x5 toroidal matrix. Plan moves, trigger memory echoes, and conquer 150 handcrafted levels with zero pay-to-win mechanics.",
  appVersion: process.env.NEXT_PUBLIC_APP_VERSION || "1.0.0",
  apkSize: process.env.NEXT_PUBLIC_APK_SIZE || "50.0 MB",
  minimumAndroidVersion: "Android 6.0 (Marshmallow, API 23)+",
  targetAndroidVersion: "Android 14 (API 34)",
  releaseDate: process.env.NEXT_PUBLIC_RELEASE_DATE || "October 2026",
  siteUrl: rawSiteUrl,
  isPlaceholderDomain: !configuredSiteUrl || configuredSiteUrl === DEFAULT_PLACEHOLDER_URL,
  displayDomain: resolvedDisplayDomain,
  apkUrl: resolvedApkUrl,
  isExternalApkUrl: isExternal,
  apkSha256: "da866194f55c5552632268bbf110f375b1b913b90ebbf6614e97e9e3da5f4ef6",
  certFingerprint:
    "d2198e7313be052a9a047435cb71fa11d913f6e6bf31b62d42e74accdad85242",
  smartLinkUrl: process.env.NEXT_PUBLIC_ADSTERRA_SMARTLINK_URL || undefined,
  analyticsEndpoint: process.env.NEXT_PUBLIC_ANALYTICS_ENDPOINT || undefined,
  contactEmail: process.env.NEXT_PUBLIC_CONTACT_EMAIL || "support@shiftpuzzle.app",
  socialLinks: {
    tiktok: process.env.NEXT_PUBLIC_TIKTOK_URL || "https://tiktok.com/@shiftpuzzle",
    youtube: process.env.NEXT_PUBLIC_YOUTUBE_URL || "https://youtube.com/@shiftpuzzle",
    instagram:
      process.env.NEXT_PUBLIC_INSTAGRAM_URL || "https://instagram.com/shiftpuzzle",
    facebook:
      process.env.NEXT_PUBLIC_FACEBOOK_URL || "https://facebook.com/shiftpuzzle",
    telegram: process.env.NEXT_PUBLIC_TELEGRAM_URL || "https://t.me/shiftpuzzle",
  },
};
