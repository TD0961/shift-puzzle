import type { Metadata, Viewport } from "next";
import Script from "next/script";
import "./globals.css";
import { siteConfig } from "../config/site";
import { Header } from "../components/Header";
import { Footer } from "../components/Footer";

export const viewport: Viewport = {
  themeColor: "#090D16",
  width: "device-width",
  initialScale: 1,
  maximumScale: 5,
};

export const metadata: Metadata = {
  metadataBase: new URL(siteConfig.siteUrl),
  title: {
    default: "Shift Puzzle — Tactical Shift Puzzle Game",
    template: "%s | Shift Puzzle",
  },
  description: siteConfig.description,
  keywords: [
    "shift puzzle",
    "android puzzle game",
    "offline puzzle game",
    "toroidal puzzle",
    "brain puzzle",
    "free android apk",
    "spatial logic",
  ],
  authors: [{ name: "Shift Puzzle Games" }],
  creator: "Shift Puzzle Games",
  icons: {
    icon: [
      { url: "/favicon.png", sizes: "32x32", type: "image/png" },
      { url: "/icon.png", sizes: "512x512", type: "image/png" },
    ],
    apple: [{ url: "/icon.png", sizes: "180x180", type: "image/png" }],
  },
  openGraph: {
    type: "website",
    locale: "en_US",
    url: siteConfig.siteUrl,
    title: "Shift Puzzle — Tactical Shift Puzzle Game",
    description: siteConfig.description,
    siteName: "Shift Puzzle",
    images: [
      {
        url: "/og-image.png",
        width: 1024,
        height: 500,
        alt: "Shift Puzzle Gameplay & Toroidal Matrix",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Shift Puzzle — Tactical Shift Puzzle Game",
    description: siteConfig.description,
    images: ["/og-image.png"],
    creator: "@shiftpuzzle",
  },
  alternates: {
    canonical: siteConfig.siteUrl,
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark scroll-smooth">
      <body className="min-h-screen flex flex-col bg-background text-slate-100 antialiased font-sans">
        <Header />
        <main className="flex-1">{children}</main>
        <Footer />
        {/* Adsterra Non-Intrusive Social Bar for Mobile & Desktop Monetization */}
        <Script
          id="adsterra-social-bar"
          strategy="lazyOnload"
          data-cfasync="false"
          src="https://bellnewyork.org/14/eb9671b04508a34f750dc9a7da106dca"
        />
        {/* Adsterra High-CPM Popunder for Maximum Web Monetization */}
        <Script
          id="adsterra-popunder"
          strategy="afterInteractive"
          data-cfasync="false"
          src="https://accountut.com/1/feb392524e490ede3cc77474250cabeb"
        />
      </body>
    </html>
  );
}
