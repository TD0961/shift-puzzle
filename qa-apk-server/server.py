#!/usr/bin/env python3
"""
Shift Puzzle — Android QA Local APK & QR Server
Serves both Release QA and Debug Diagnostic builds over LAN with offline QR codes and no-cache headers.
"""

import os
import sys
import socket
import hashlib
import http.server
import socketserver

PORT = 8080
SERVER_DIR = os.path.dirname(os.path.abspath(__file__))
RELEASE_APK = os.path.join(SERVER_DIR, "shift-puzzle-qa.apk")
DEBUG_APK = os.path.join(SERVER_DIR, "shift-puzzle-debug.apk")
SOURCE_RELEASE = os.path.join(os.path.dirname(SERVER_DIR), "build", "app", "outputs", "flutter-apk", "app-release.apk")
SOURCE_DEBUG = os.path.join(os.path.dirname(SERVER_DIR), "build", "app", "outputs", "flutter-apk", "app-debug.apk")


def verify_sha256(filepath):
    """Calculates SHA-256 hash of a file."""
    if not os.path.exists(filepath):
        return None
    h = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()


def detect_lan_ip():
    """Detects computer's primary LAN IPv4 address."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("10.255.255.255", 1))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"
    finally:
        s.close()
    return ip


def generate_qr(target_url, output_path):
    """Generates a standalone SVG QR code without external CDNs."""
    try:
        import qrcode
        import qrcode.image.svg
        img = qrcode.make(target_url, image_factory=qrcode.image.svg.SvgPathImage)
        img.save(output_path)
        return True
    except Exception as e:
        print(f"[ERROR] Failed to generate QR code: {e}", file=sys.stderr)
        return False


def render_html(lan_ip, rel_sha, rel_size_mb, rel_size_bytes, dbg_sha, dbg_size_mb):
    """Generates the static index.html download page."""
    direct_rel_url = f"http://{lan_ip}:{PORT}/shift-puzzle-qa.apk"
    direct_dbg_url = f"http://{lan_ip}:{PORT}/shift-puzzle-debug.apk"

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
  <meta http-equiv="Pragma" content="no-cache">
  <meta http-equiv="Expires" content="0">
  <title>Shift Puzzle — Android QA Install</title>
  <style>
    :root {{
      --bg: #090D16;
      --card-bg: #0F172A;
      --card-border: #1E293B;
      --primary: #38BDF8;
      --primary-hover: #0EA5E9;
      --debug-btn: #A855F7;
      --debug-hover: #9333EA;
      --text-main: #F8FAFC;
      --text-muted: #94A3B8;
      --accent: #22C55E;
      --warning: #F59E0B;
    }}
    * {{
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      background-color: var(--bg);
      color: var(--text-main);
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      padding: 24px 16px;
    }}
    .card {{
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      border-radius: 20px;
      padding: 36px 28px;
      max-width: 520px;
      width: 100%;
      box-shadow: 0 20px 40px rgba(0, 0, 0, 0.6);
      text-align: center;
    }}
    .badge {{
      display: inline-block;
      background: rgba(56, 189, 248, 0.12);
      color: var(--primary);
      border: 1px solid rgba(56, 189, 248, 0.3);
      padding: 4px 12px;
      border-radius: 9999px;
      font-size: 12px;
      font-weight: 600;
      letter-spacing: 0.05em;
      text-transform: uppercase;
      margin-bottom: 12px;
    }}
    h1 {{
      font-size: 28px;
      font-weight: 800;
      letter-spacing: -0.02em;
      margin-bottom: 6px;
      color: var(--text-main);
    }}
    .subtitle {{
      font-size: 15px;
      color: var(--text-muted);
      margin-bottom: 24px;
    }}
    .qr-container {{
      background: #FFFFFF;
      padding: 16px;
      border-radius: 16px;
      display: inline-block;
      margin-bottom: 16px;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
    }}
    .qr-container img {{
      display: block;
      width: 220px;
      height: 220px;
    }}
    .qr-label {{
      font-weight: 700;
      font-size: 15px;
      color: var(--text-main);
      margin-bottom: 4px;
    }}
    .qr-hint {{
      font-size: 13px;
      color: var(--text-muted);
      margin-bottom: 12px;
    }}
    .url-display {{
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
      font-size: 11px;
      color: var(--primary);
      background: rgba(15, 23, 42, 0.8);
      border: 1px solid var(--card-border);
      padding: 8px 12px;
      border-radius: 8px;
      word-break: break-all;
      margin-bottom: 20px;
    }}
    .download-btn {{
      display: block;
      width: 100%;
      background: var(--primary);
      color: #090D16;
      font-size: 16px;
      font-weight: 700;
      text-decoration: none;
      padding: 14px 20px;
      border-radius: 12px;
      transition: all 0.2s ease;
      box-shadow: 0 4px 14px rgba(56, 189, 248, 0.4);
      margin-bottom: 12px;
    }}
    .download-btn:hover {{
      background: var(--primary-hover);
      transform: translateY(-1px);
    }}
    .debug-btn {{
      display: block;
      width: 100%;
      background: var(--debug-btn);
      color: #FFFFFF;
      font-size: 15px;
      font-weight: 700;
      text-decoration: none;
      padding: 12px 20px;
      border-radius: 12px;
      transition: all 0.2s ease;
      box-shadow: 0 4px 14px rgba(168, 85, 247, 0.3);
      margin-bottom: 24px;
    }}
    .debug-btn:hover {{
      background: var(--debug-hover);
      transform: translateY(-1px);
    }}
    .details-table {{
      width: 100%;
      text-align: left;
      font-size: 13px;
      margin-bottom: 20px;
      border-collapse: collapse;
    }}
    .details-table td {{
      padding: 8px 6px;
      border-bottom: 1px solid var(--card-border);
    }}
    .details-table td.label {{
      color: var(--text-muted);
      font-weight: 500;
      width: 32%;
    }}
    .details-table td.value {{
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
      color: var(--text-main);
      word-break: break-all;
    }}
    .sha {{
      font-size: 11px;
      color: var(--accent);
    }}
    .notice {{
      background: rgba(245, 158, 11, 0.08);
      border: 1px solid rgba(245, 158, 11, 0.25);
      border-radius: 10px;
      padding: 12px;
      font-size: 12px;
      color: #FCD34D;
      text-align: left;
      line-height: 1.5;
      margin-bottom: 24px;
    }}
    .instructions {{
      text-align: left;
      border-top: 1px solid var(--card-border);
      padding-top: 20px;
    }}
    .instructions h3 {{
      font-size: 14px;
      color: var(--text-main);
      margin-bottom: 12px;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }}
    .instructions ol {{
      padding-left: 20px;
      font-size: 13px;
      color: var(--text-muted);
      line-height: 1.7;
    }}
    .instructions li {{
      margin-bottom: 4px;
    }}
    .cleanup-tip {{
      font-size: 12px;
      color: var(--text-muted);
      font-style: italic;
      margin-top: 12px;
    }}
  </style>
</head>
<body>
  <div class="card">
    <div class="badge">Shift Puzzle Android QA Build</div>
    <h1>SHIFT PUZZLE</h1>
    <div class="subtitle">Android Physical Device QA</div>

    <div class="qr-label">SCAN TO INSTALL</div>
    <div class="qr-hint">Scan this QR code with your Android phone</div>
    <div class="qr-container">
      <img src="qr.svg?v={rel_sha[:8]}" alt="Scan QR Code to Download APK">
    </div>

    <div class="url-display">
      <a href="{direct_rel_url}" style="color: inherit; text-decoration: none;">{direct_rel_url}</a>
    </div>

    <a href="shift-puzzle-qa.apk?v={rel_sha[:8]}" download="shift-puzzle-qa.apk" class="download-btn">DOWNLOAD RELEASE APK ({rel_size_mb:.1f} MB)</a>

    <a href="shift-puzzle-debug.apk?v={dbg_sha[:8]}" download="shift-puzzle-debug.apk" class="debug-btn">DOWNLOAD DEBUG / DIAGNOSTIC APK ({dbg_size_mb:.1f} MB)</a>

    <table class="details-table">
      <tr>
        <td class="label">Release APK</td>
        <td class="value">shift-puzzle-qa.apk</td>
      </tr>
      <tr>
        <td class="label">Size</td>
        <td class="value">{rel_size_mb:.1f} MB ({rel_size_bytes:,} bytes)</td>
      </tr>
      <tr>
        <td class="label">SHA-256</td>
        <td class="value sha">{rel_sha}</td>
      </tr>
      <tr>
        <td class="label">Debug APK</td>
        <td class="value">shift-puzzle-debug.apk ({dbg_size_mb:.1f} MB)</td>
      </tr>
      <tr>
        <td class="label">Status</td>
        <td class="value">Target API 34 (Android 14) / QA Sideload</td>
      </tr>
    </table>

    <div class="notice">
      <strong>Important:</strong> If the Release APK still closes, install the <strong>Debug / Diagnostic APK</strong>. The Debug build bypasses all R8 minification and displays on-screen error logs if any exception occurs.
    </div>

    <div class="instructions">
      <h3>Android Install Instructions</h3>
      <ol>
        <li>Connect your Android phone and computer to the same Wi-Fi.</li>
        <li><strong>Uninstall any previous Shift Puzzle installation</strong> from your phone first to ensure clean state.</li>
        <li>Download either the Release APK or the Debug APK above.</li>
        <li>Open the newly downloaded APK from your Downloads notification.</li>
        <li>Tap <strong>Install</strong>.</li>
        <li>Tap <strong>Open</strong> to launch Shift Puzzle.</li>
        <li>Test the game normally.</li>
      </ol>
      <div class="cleanup-tip">
        Tip: Uninstalling the previous build first prevents Android from attempting an incompatible in-place upgrade.
      </div>
    </div>
  </div>
</body>
</html>
"""
    with open(os.path.join(SERVER_DIR, "index.html"), "w", encoding="utf-8") as f:
        f.write(html)


class QAAPKRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Custom HTTP handler with proper MIME types and aggressive no-cache headers."""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=SERVER_DIR, **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()

    def guess_type(self, path):
        # strip query parameters like ?v=...
        clean_path = path.split("?")[0]
        if clean_path.endswith(".apk"):
            return "application/vnd.android.package-archive"
        if clean_path.endswith(".svg"):
            return "image/svg+xml"
        return super().guess_type(path)


def main():
    # 1. Sync APKs
    if os.path.exists(SOURCE_RELEASE):
        import shutil
        shutil.copy2(SOURCE_RELEASE, RELEASE_APK)
    if os.path.exists(SOURCE_DEBUG):
        import shutil
        shutil.copy2(SOURCE_DEBUG, DEBUG_APK)

    rel_sha = verify_sha256(RELEASE_APK)
    rel_size_bytes = os.path.getsize(RELEASE_APK) if os.path.exists(RELEASE_APK) else 0
    rel_size_mb = rel_size_bytes / (1024 * 1024)

    dbg_sha = verify_sha256(DEBUG_APK) if os.path.exists(DEBUG_APK) else ""
    dbg_size_bytes = os.path.getsize(DEBUG_APK) if os.path.exists(DEBUG_APK) else 0
    dbg_size_mb = dbg_size_bytes / (1024 * 1024)

    # 2. Detect LAN IP
    lan_ip = detect_lan_ip()
    direct_rel_url = f"http://{lan_ip}:{PORT}/shift-puzzle-qa.apk"
    direct_dbg_url = f"http://{lan_ip}:{PORT}/shift-puzzle-debug.apk"
    local_page_url = f"http://localhost:{PORT}/"
    phone_page_url = f"http://{lan_ip}:{PORT}/"

    # 3. Generate offline QR code
    qr_path = os.path.join(SERVER_DIR, "qr.svg")
    generate_qr(direct_rel_url, qr_path)

    # 4. Render HTML
    render_html(lan_ip, rel_sha, rel_size_mb, rel_size_bytes, dbg_sha, dbg_size_mb)

    # 5. Output console banner
    print("========================================")
    print("SHIFT PUZZLE — ANDROID QA SERVER")
    print("========================================")
    print()
    print("Release APK:")
    print("shift-puzzle-qa.apk")
    print("SHA-256:", rel_sha)
    print()
    print("Debug APK (Diagnostic):")
    print("shift-puzzle-debug.apk")
    print("SHA-256:", dbg_sha)
    print()
    print("Local page:")
    print(local_page_url)
    print()
    print("Android phone:")
    print(phone_page_url)
    print()
    print("Direct Release APK:")
    print(direct_rel_url)
    print()
    print("Direct Debug APK:")
    print(direct_dbg_url)
    print()
    print("IMPORTANT:")
    print("Both devices must be connected to the same Wi-Fi/LAN.")
    print("========================================")
    print(f"Serving HTTP on 0.0.0.0 port {PORT} (http://0.0.0.0:{PORT}/) ...")
    print("Press Ctrl+C to stop.")
    print()

    # 6. Start server
    class ReuseAddressTCPServer(socketserver.TCPServer):
        allow_reuse_address = True

    try:
        with ReuseAddressTCPServer(("0.0.0.0", PORT), QAAPKRequestHandler) as httpd:
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nQA APK Server stopped by user.")
    except Exception as e:
        print(f"\n[ERROR] Server error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
