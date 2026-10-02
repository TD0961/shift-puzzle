import { siteConfig } from "../config/site";

/**
 * Permitted acquisition attribution channels for marketing campaign measurement.
 * Kept strictly browser-side in localStorage to measure web landing conversion.
 *
 * NOTE ON APK ATTRIBUTION:
 * Direct APK distribution (sideloading) DOES NOT have an app store install referrer.
 * URL parameters detected here are NEVER transferred into the installed Android app.
 * In-app telemetry uses an independent, anonymous, locally-generated ID (installationId).
 */
export const SUPPORTED_ACQUISITION_SOURCES = [
  "direct",
  "tiktok",
  "youtube",
  "instagram",
  "facebook",
  "telegram",
  "qr",
] as const;

export type AcquisitionSource = (typeof SUPPORTED_ACQUISITION_SOURCES)[number];

const STORAGE_KEY = "sp_acquisition_source";

/**
 * Validates and extracts the acquisition campaign source from URL parameters.
 * Validates against the strictly supported source list and persists in localStorage.
 *
 * PRIVACY GUARANTEE:
 * Does NOT collect any Personally Identifiable Information (PII) such as:
 * - Name, email address, phone number
 * - GPS or IP-derived precise geolocation
 * - Android Advertising ID (AAID), IMEI, or hardware serials
 */
export function getAcquisitionSource(): AcquisitionSource {
  if (typeof window === "undefined") return "direct";

  try {
    const params = new URLSearchParams(window.location.search);
    const paramSource = params.get("source") || params.get("ref");

    if (paramSource && paramSource.trim().length > 0) {
      const sanitized = paramSource.trim().toLowerCase();
      const matched = SUPPORTED_ACQUISITION_SOURCES.find((s) => s === sanitized);

      if (matched) {
        localStorage.setItem(STORAGE_KEY, matched);
        return matched;
      }
    }

    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      const matchedStored = SUPPORTED_ACQUISITION_SOURCES.find((s) => s === stored);
      if (matchedStored) return matchedStored;
    }
  } catch {
    // Fail silently in restricted sandbox contexts or private browsing
  }

  return "direct";
}

export interface FunnelEventPayload {
  event:
    | "landing_page_view"
    | "download_clicked"
    | "smartlink_clicked"
    | "share_clicked"
    | "gameplay_viewed";
  source?: AcquisitionSource;
  properties?: Record<string, string | number | boolean>;
}

/**
 * Dispatches a lightweight privacy-first funnel telemetry event.
 * Operates in completely safe no-op mode if no endpoint is configured or if offline.
 */
export function trackFunnelEvent(
  event: FunnelEventPayload["event"],
  properties: Record<string, string | number | boolean> = {}
): void {
  if (typeof window === "undefined") return;

  const source = getAcquisitionSource();
  const endpoint = siteConfig.analyticsEndpoint;

  if (process.env.NODE_ENV === "development") {
    // eslint-disable-next-line no-console
    console.log(`[Funnel Analytics] ${event}`, { source, ...properties });
  }

  if (!endpoint || endpoint.trim().length === 0) {
    return; // Safe no-op when telemetry endpoint is unconfigured
  }

  try {
    const body = JSON.stringify({
      event,
      source,
      properties,
      timestamp: new Date().toISOString(),
    });

    if (navigator.sendBeacon) {
      navigator.sendBeacon(endpoint, body);
    } else {
      fetch(endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body,
        keepalive: true,
        mode: "no-cors",
      }).catch(() => {});
    }
  } catch {
    // Telemetry errors must never disrupt page operation or download flow
  }
}
