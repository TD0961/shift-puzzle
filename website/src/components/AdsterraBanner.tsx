"use client";

import React, { useEffect, useRef } from "react";

interface AdsterraBannerProps {
  format?: "728x90" | "300x250";
  className?: string;
}

export function AdsterraBanner({ format = "728x90", className = "" }: AdsterraBannerProps) {
  const containerRef = useRef<HTMLDivElement>(null);

  const config =
    format === "300x250"
      ? {
          key: "05011105688e30a4c5c72688bf03f099",
          width: 300,
          height: 250,
        }
      : {
          key: "f6d344198f01a05f5e192f109113beb9",
          width: 728,
          height: 90,
        };

  useEffect(() => {
    if (!containerRef.current) return;

    const iframe = document.createElement("iframe");
    iframe.width = String(config.width);
    iframe.height = String(config.height);
    iframe.style.border = "none";
    iframe.style.overflow = "hidden";
    iframe.scrolling = "no";

    containerRef.current.innerHTML = "";
    containerRef.current.appendChild(iframe);

    const doc = iframe.contentWindow?.document;
    if (doc) {
      doc.open();
      doc.write(`
        <!DOCTYPE html>
        <html>
          <head>
            <style>body { margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; background: transparent; }</style>
          </head>
          <body>
            <script type="text/javascript">
              atOptions = {
                'key': '${config.key}',
                'format': 'iframe',
                'height': ${config.height},
                'width': ${config.width},
                'params': {}
              };
            </script>
            <script type="text/javascript" src="//www.highperformanceformat.com/${config.key}/invoke.js"></script>
          </body>
        </html>
      `);
      doc.close();
    }
  }, [config.key, config.width, config.height]);

  return (
    <div className={`flex flex-col items-center my-6 overflow-hidden ${className}`}>
      <span className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold mb-1.5">
        Sponsored
      </span>
      <div
        ref={containerRef}
        className="rounded-xl overflow-hidden"
        style={{ maxWidth: "100%", width: `${config.width}px`, height: `${config.height}px` }}
      />
    </div>
  );
}
