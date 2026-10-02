#!/usr/bin/env python3
"""
Generate official social media marketing assets for Shift Puzzle:
1. avatar_1080x1080.png (Profile Avatar for TikTok, YouTube, Instagram, Telegram)
2. youtube_banner_2560x1440.png (YouTube Header with 1546x423 safe zone)
3. twitter_header_1500x500.png (X/Twitter Header)
4. telegram_promo_card_1280x720.png (Telegram Channel Promo Card)
"""

import math
import os
from PIL import Image, ImageDraw, ImageFont

OUTPUT_DIR = "assets/branding/social"
ICON_PATH = "assets/branding/app_icon/shift_puzzle_icon_512.png"

def get_font(size, bold=True):
    font_paths = [
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for path in font_paths:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    return ImageFont.load_default()

def draw_ambient_glow(img, cx, cy, radius, color, max_alpha=30):
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    steps = 15
    for i in range(steps, 0, -1):
        r = int(radius * (i / steps))
        alpha = int(max_alpha * (1.0 - (i / steps)))
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(color[0], color[1], color[2], alpha))
    return Image.alpha_composite(img, overlay)

def generate_avatar():
    size = 1080
    img = Image.new("RGBA", (size, size), (9, 13, 22, 255))
    
    # Ambient glows
    img = draw_ambient_glow(img, size // 2, size // 2, int(size * 0.45), (0, 229, 255), max_alpha=40)
    img = draw_ambient_glow(img, size // 2, size // 2, int(size * 0.30), (124, 77, 255), max_alpha=35)
    
    draw = ImageDraw.Draw(img)
    
    # Outer circular ring preview for social avatars
    ring_r = int(size * 0.44)
    cx, cy = size // 2, size // 2
    draw.ellipse([cx - ring_r, cy - ring_r, cx + ring_r, cy + ring_r], outline=(0, 229, 255, 60), width=4)
    
    # Paste centered app icon with slight inset
    if os.path.exists(ICON_PATH):
        icon = Image.open(ICON_PATH).convert("RGBA")
        icon_size = 640
        icon = icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
        
        # Mask with smooth rounded rectangle
        mask = Image.new("L", (icon_size, icon_size), 0)
        mask_draw = ImageDraw.Draw(mask)
        mask_draw.rounded_rectangle([0, 0, icon_size, icon_size], radius=140, fill=255)
        
        icon_x = (size - icon_size) // 2
        icon_y = (size - icon_size) // 2
        img.paste(icon, (icon_x, icon_y), mask)
        
        # Rounded border
        draw.rounded_rectangle(
            [icon_x - 4, icon_y - 4, icon_x + icon_size + 4, icon_y + icon_size + 4],
            radius=144,
            outline=(0, 229, 255, 120),
            width=6
        )

    out_path = os.path.join(OUTPUT_DIR, "avatar_1080x1080.png")
    img.save(out_path, "PNG", optimize=True)
    print(f"Generated {out_path}")

def generate_youtube_banner():
    # YouTube channel banner is 2560x1440. Safe text area is 1546x423 in the center (y: 508 to 931)
    w, h = 2560, 1440
    img = Image.new("RGBA", (w, h), (9, 13, 22, 255))
    
    # Atmospheric glows
    img = draw_ambient_glow(img, 700, 720, 500, (0, 229, 255), max_alpha=35)
    img = draw_ambient_glow(img, 1800, 720, 550, (124, 77, 255), max_alpha=30)
    
    draw = ImageDraw.Draw(img)
    
    # Decorative toroidal subtle tracks across center
    cy = 720
    for offset_y in [-150, 0, 150]:
        y = cy + offset_y
        draw.line([0, y, w, y], fill=(255, 255, 255, 12), width=2)
    
    # Left side: Glowing App Icon
    if os.path.exists(ICON_PATH):
        icon = Image.open(ICON_PATH).convert("RGBA")
        icon_size = 320
        icon = icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
        
        mask = Image.new("L", (icon_size, icon_size), 0)
        mask_draw = ImageDraw.Draw(mask)
        mask_draw.rounded_rectangle([0, 0, icon_size, icon_size], radius=64, fill=255)
        
        icon_x = 580
        icon_y = cy - (icon_size // 2)
        img.paste(icon, (icon_x, icon_y), mask)
        
        draw.rounded_rectangle(
            [icon_x - 3, icon_y - 3, icon_x + icon_size + 3, icon_y + icon_size + 3],
            radius=67,
            outline=(0, 229, 255, 140),
            width=4
        )
    
    # Right side: Text within safe area
    font_title = get_font(90, bold=True)
    font_sub = get_font(38, bold=True)
    font_tag = get_font(28, bold=False)
    
    text_x = 960
    draw.text((text_x, cy - 130), "SHIFT PUZZLE", font=font_title, fill=(255, 255, 255, 255))
    
    # Cyan highlight pill
    pill_text = "150 HANDCRAFTED LEVELS • TOROIDAL MECHANICS"
    bbox = font_sub.getbbox(pill_text)
    pill_w = (bbox[2] - bbox[0]) + 48
    draw.rounded_rectangle(
        [text_x, cy - 20, text_x + pill_w, cy + 32],
        radius=14,
        fill=(0, 229, 255, 30),
        outline=(0, 229, 255, 100),
        width=2
    )
    draw.text((text_x + 24, cy - 14), pill_text, font=font_sub, fill=(0, 229, 255, 255))
    
    # Subtitle / CTA
    cta = "Play Standalone Android APK • Zero Pay-to-Win • shiftpuzzle.app"
    draw.text((text_x, cy + 60), cta, font=font_tag, fill=(160, 175, 200, 240))
    
    out_path = os.path.join(OUTPUT_DIR, "youtube_banner_2560x1440.png")
    img.save(out_path, "PNG", optimize=True)
    print(f"Generated {out_path}")

def generate_twitter_header():
    # 1500x500 (3:1 aspect ratio)
    w, h = 1500, 500
    img = Image.new("RGBA", (w, h), (9, 13, 22, 255))
    
    img = draw_ambient_glow(img, 350, 250, 300, (0, 229, 255), max_alpha=35)
    img = draw_ambient_glow(img, 1150, 250, 350, (124, 77, 255), max_alpha=25)
    
    draw = ImageDraw.Draw(img)
    cy = 250
    
    # Left: App Icon
    if os.path.exists(ICON_PATH):
        icon = Image.open(ICON_PATH).convert("RGBA")
        icon_size = 220
        icon = icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
        
        mask = Image.new("L", (icon_size, icon_size), 0)
        mask_draw = ImageDraw.Draw(mask)
        mask_draw.rounded_rectangle([0, 0, icon_size, icon_size], radius=48, fill=255)
        
        icon_x = 180
        icon_y = cy - (icon_size // 2)
        img.paste(icon, (icon_x, icon_y), mask)
        
        draw.rounded_rectangle(
            [icon_x - 3, icon_y - 3, icon_x + icon_size + 3, icon_y + icon_size + 3],
            radius=51,
            outline=(0, 229, 255, 130),
            width=3
        )
    
    font_title = get_font(68, bold=True)
    font_sub = get_font(26, bold=True)
    font_tag = get_font(22, bold=False)
    
    text_x = 450
    draw.text((text_x, cy - 95), "SHIFT PUZZLE", font=font_title, fill=(255, 255, 255, 255))
    
    pill_text = "TACTICAL TOROIDAL MATRIX PUZZLE"
    draw.rounded_rectangle(
        [text_x, cy - 15, text_x + 580, cy + 24],
        radius=10,
        fill=(0, 229, 255, 30),
        outline=(0, 229, 255, 90),
        width=2
    )
    draw.text((text_x + 18, cy - 10), pill_text, font=font_sub, fill=(0, 229, 255, 255))
    
    draw.text((text_x, cy + 45), "150 Handcrafted Levels • Free Android APK • shiftpuzzle.app", font=font_tag, fill=(160, 175, 200, 230))
    
    out_path = os.path.join(OUTPUT_DIR, "twitter_header_1500x500.png")
    img.save(out_path, "PNG", optimize=True)
    print(f"Generated {out_path}")

def generate_telegram_promo_card():
    # 1280x720 (16:9 post card)
    w, h = 1280, 720
    img = Image.new("RGBA", (w, h), (9, 13, 22, 255))
    
    img = draw_ambient_glow(img, 280, 360, 350, (0, 229, 255), max_alpha=40)
    img = draw_ambient_glow(img, 980, 360, 400, (124, 77, 255), max_alpha=30)
    
    draw = ImageDraw.Draw(img)
    cy = 360
    
    # Left: Icon
    if os.path.exists(ICON_PATH):
        icon = Image.open(ICON_PATH).convert("RGBA")
        icon_size = 280
        icon = icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
        
        mask = Image.new("L", (icon_size, icon_size), 0)
        mask_draw = ImageDraw.Draw(mask)
        mask_draw.rounded_rectangle([0, 0, icon_size, icon_size], radius=60, fill=255)
        
        icon_x = 120
        icon_y = cy - (icon_size // 2)
        img.paste(icon, (icon_x, icon_y), mask)
        
        draw.rounded_rectangle(
            [icon_x - 4, icon_y - 4, icon_x + icon_size + 4, icon_y + icon_size + 4],
            radius=64,
            outline=(0, 229, 255, 140),
            width=4
        )
    
    font_title = get_font(64, bold=True)
    font_badge = get_font(24, bold=True)
    font_body = get_font(28, bold=False)
    font_cta = get_font(26, bold=True)
    
    text_x = 460
    draw.text((text_x, cy - 140), "Shift Puzzle v1.0.0", font=font_title, fill=(255, 255, 255, 255))
    
    # Badges
    badges = [("150 LEVELS", (0, 229, 255)), ("OFFLINE FIRST", (16, 185, 129)), ("FREE APK", (168, 85, 247))]
    bx = text_x
    for label, col in badges:
        bw = len(label) * 15 + 24
        draw.rounded_rectangle([bx, cy - 55, bx + bw, cy - 20], radius=8, fill=(col[0], col[1], col[2], 30), outline=(col[0], col[1], col[2], 120), width=2)
        draw.text((bx + 12, cy - 52), label, font=font_badge, fill=col)
        bx += bw + 14
        
    draw.text((text_x, cy + 5), "Tactical 5x5 toroidal sliding matrix puzzle.", font=font_body, fill=(200, 215, 235, 255))
    draw.text((text_x, cy + 45), "Shift entire rows & columns to lock coordinates.", font=font_body, fill=(160, 175, 200, 230))
    
    # Download Button graphic
    btn_y = cy + 105
    draw.rounded_rectangle([text_x, btn_y, text_x + 360, btn_y + 55], radius=14, fill=(0, 229, 255, 220))
    draw.text((text_x + 35, btn_y + 12), "Direct APK Download", font=font_cta, fill=(9, 13, 22, 255))
    
    out_path = os.path.join(OUTPUT_DIR, "telegram_promo_card_1280x720.png")
    img.save(out_path, "PNG", optimize=True)
    print(f"Generated {out_path}")

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print(f"Rendering social media graphics to {OUTPUT_DIR}/...")
    generate_avatar()
    generate_youtube_banner()
    generate_twitter_header()
    generate_telegram_promo_card()
    print("All social assets generated successfully!")

if __name__ == "__main__":
    main()
