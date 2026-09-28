#!/usr/bin/env python3
"""
Generate official Google Play Store Feature Graphic (1024x500) for Shift Puzzle.
Rendered with 2x supersampling (2048x1000) and downsampled with Lanczos filter.
Complies with Google Play Store graphic asset policy.
"""

import math
import os
from PIL import Image, ImageDraw, ImageFont

def render_feature_graphic():
    target_w, target_h = 1024, 500
    scale = 2
    w = target_w * scale  # 2048
    h = target_h * scale  # 1000

    # 1. Base Canvas - Deep Obsidian #090D16
    img = Image.new("RGBA", (w, h), (9, 13, 22, 255))
    draw = ImageDraw.Draw(img)

    # 2. Ambient Lighting & Depth
    # Subtle ambient sapphire glow on left behind grid
    left_cx = int(w * 0.28)
    left_cy = int(h * 0.50)
    for r in range(int(w * 0.45), 0, -int(12 * scale)):
        alpha = int(24 * (1.0 - (r / (w * 0.45))))
        draw.ellipse([left_cx - r, left_cy - r, left_cx + r, left_cy + r], fill=(13, 31, 60, alpha))

    # Subtle cyan radial focus on center piece
    for r in range(int(w * 0.22), 0, -int(8 * scale)):
        alpha = int(20 * (1.0 - (r / (w * 0.22))))
        draw.ellipse([left_cx - r, left_cy - r, left_cx + r, left_cy + r], fill=(0, 180, 216, alpha))

    # 3. Draw 5x5 Toroidal Grid on Left Side
    grid_span = int(h * 0.68)  # ~680px
    num_cells = 5
    gap = int(grid_span * 0.045)  # ~30px
    cell_size = (grid_span - gap * (num_cells - 1)) / num_cells  # ~112px
    corner_radius = cell_size * 0.26

    grid_x0 = left_cx - (grid_span // 2)
    grid_y0 = left_cy - (grid_span // 2)

    shift_offset_x = cell_size * 0.45

    # Toroidal row 2 track
    row2_y = grid_y0 + 2 * (cell_size + gap)
    track_pad = gap * 0.7
    track_overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    t_draw = ImageDraw.Draw(track_overlay)
    t_draw.rounded_rectangle(
        [grid_x0 - gap * 1.5, row2_y - track_pad, grid_x0 + grid_span + gap * 1.8, row2_y + cell_size + track_pad],
        radius=corner_radius * 1.2,
        fill=(0, 229, 255, 16),
        outline=(0, 229, 255, 55),
        width=int(2 * scale)
    )
    img = Image.alpha_composite(img, track_overlay)
    draw = ImageDraw.Draw(img)

    # Draw grid cells
    for r in range(num_cells):
        for c in range(num_cells):
            cx = grid_x0 + c * (cell_size + gap)
            cy = grid_y0 + r * (cell_size + gap)

            if r == 2:
                cx += shift_offset_x

            cell_fill = (20, 31, 52, 235)
            cell_outline = (32, 49, 78, 255)
            c_width = int(2.5 * scale)

            if r == 2 and c == 2:
                cell_fill = (12, 38, 62, 255)
                cell_outline = (0, 229, 255, 220)
                c_width = int(3.5 * scale)
            elif r == 1 and c == 3:
                cell_fill = (38, 32, 18, 255)
                cell_outline = (255, 193, 7, 180)
            elif r == 3 and c == 1:
                cell_fill = (15, 36, 26, 255)
                cell_outline = (0, 230, 118, 180)

            draw.rounded_rectangle(
                [cx, cy, cx + cell_size, cy + cell_size],
                radius=corner_radius,
                fill=cell_fill,
                outline=cell_outline,
                width=c_width
            )

    # 4. Draw Gem Pieces on Grid
    # Amber Diamond at (c=3, r=1)
    amber_cx = grid_x0 + 3 * (cell_size + gap) + cell_size / 2.0
    amber_cy = grid_y0 + 1 * (cell_size + gap) + cell_size / 2.0
    dr = cell_size * 0.32
    draw.polygon([
        (amber_cx, amber_cy - dr), (amber_cx + dr, amber_cy),
        (amber_cx, amber_cy + dr), (amber_cx - dr, amber_cy)
    ], fill=(255, 193, 7, 240))
    inner_dr = dr * 0.52
    draw.polygon([
        (amber_cx, amber_cy - inner_dr), (amber_cx + inner_dr, amber_cy),
        (amber_cx, amber_cy + inner_dr), (amber_cx - inner_dr, amber_cy)
    ], fill=(255, 248, 225, 255))

    # Emerald Square at (c=1, r=3)
    em_cx = grid_x0 + 1 * (cell_size + gap) + cell_size / 2.0
    em_cy = grid_y0 + 3 * (cell_size + gap) + cell_size / 2.0
    em_r = cell_size * 0.30
    draw.rounded_rectangle(
        [em_cx - em_r, em_cy - em_r, em_cx + em_r, em_cy + em_r],
        radius=corner_radius * 0.5,
        fill=(0, 230, 118, 240),
        outline=(232, 245, 233, 220),
        width=int(1.5 * scale)
    )

    # Hero Cyan Circle at (c=2, r=2 shifted)
    hero_cx = grid_x0 + 2 * (cell_size + gap) + shift_offset_x + cell_size / 2.0
    hero_cy = grid_y0 + 2 * (cell_size + gap) + cell_size / 2.0
    hr = cell_size * 0.36

    # Cyan halo
    halo_img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    h_draw = ImageDraw.Draw(halo_img)
    for rad in range(int(hr * 1.8), int(hr), -int(3 * scale)):
        fade = 1.0 - (rad - hr) / (hr * 0.8)
        alpha = int(75 * (fade ** 1.5))
        h_draw.ellipse([hero_cx - rad, hero_cy - rad, hero_cx + rad, hero_cy + rad], fill=(0, 229, 255, alpha))
    img = Image.alpha_composite(img, halo_img)
    draw = ImageDraw.Draw(img)

    # Target confirmation ring
    draw.ellipse([hero_cx - hr * 1.15, hero_cy - hr * 1.15, hero_cx + hr * 1.15, hero_cy + hr * 1.15],
                 outline=(255, 255, 255, 180), width=int(2.5 * scale))
    # Cyan body
    draw.ellipse([hero_cx - hr, hero_cy - hr, hero_cx + hr, hero_cy + hr],
                 fill=(0, 229, 255, 255), outline=(255, 255, 255, 220), width=int(2 * scale))
    # Specular highlight
    hl_r = hr * 0.40
    draw.ellipse([hero_cx - hr * 0.22 - hl_r, hero_cy - hr * 0.22 - hl_r,
                  hero_cx - hr * 0.22 + hl_r, hero_cy - hr * 0.22 + hl_r],
                 fill=(224, 247, 250, 240))

    # Toroidal shift arrow
    arrow_cx = grid_x0 + grid_span + gap * 0.8 + shift_offset_x * 0.3
    arrow_cy = hero_cy
    asize = cell_size * 0.28
    draw.line([
        (arrow_cx - asize * 0.6, arrow_cy - asize),
        (arrow_cx + asize * 0.5, arrow_cy),
        (arrow_cx - asize * 0.6, arrow_cy + asize)
    ], fill=(0, 229, 255, 220), width=int(3 * scale), joint="round")

    # 5. Right Side Typography & Branding
    font_bold_path = "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"
    font_regular_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
    if not os.path.exists(font_regular_path):
        font_regular_path = "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf"

    font_title = ImageFont.truetype(font_bold_path, size=int(56 * scale))
    font_subtitle = ImageFont.truetype(font_bold_path, size=int(20 * scale))
    font_badge = ImageFont.truetype(font_bold_path, size=int(14 * scale))
    font_desc = ImageFont.truetype(font_regular_path, size=int(16 * scale))

    text_x = int(w * 0.55)
    text_y = int(h * 0.25)

    # Subtitle Category Badge
    badge_text = "PURE SPATIAL LOGIC"
    badge_pad_x = int(14 * scale)
    badge_pad_y = int(6 * scale)
    bbox_b = font_badge.getbbox(badge_text)
    bw = bbox_b[2] - bbox_b[0]
    bh = bbox_b[3] - bbox_b[1]
    draw.rounded_rectangle(
        [text_x, text_y, text_x + bw + badge_pad_x * 2, text_y + bh + badge_pad_y * 2],
        radius=int(6 * scale),
        fill=(18, 38, 64, 255),
        outline=(0, 229, 255, 140),
        width=int(1.5 * scale)
    )
    draw.text((text_x + badge_pad_x, text_y + badge_pad_y - int(1 * scale)), badge_text, font=font_badge, fill=(0, 229, 255, 255))

    # Main Title: SHIFT PUZZLE
    title_y = text_y + bh + badge_pad_y * 2 + int(14 * scale)
    draw.text((text_x, title_y), "SHIFT PUZZLE", font=font_title, fill=(255, 255, 255, 255))

    # Tagline
    tagline_y = title_y + int(64 * scale)
    draw.text((text_x, tagline_y), "5×5 Toroidal Grid • Minimal Par Logic", font=font_subtitle, fill=(148, 163, 184, 255)) # Slate 400

    # 3 Pillar Feature Bullet Badges
    features = [
        ("•", "150 Deterministic Handcrafted Levels", (255, 193, 7, 255)),
        ("•", "Signature Memory Echo Macro Mechanic", (192, 132, 252, 255)),
        ("•", "100% Offline-First • Zero Accounts", (0, 230, 118, 255))
    ]

    feat_y = tagline_y + int(42 * scale)
    for bullet, text, color in features:
        draw.text((text_x, feat_y), bullet, font=font_desc, fill=color)
        draw.text((text_x + int(16 * scale), feat_y), text, font=font_desc, fill=(226, 232, 240, 255))
        feat_y += int(28 * scale)

    # 6. Downsample with Lanczos filter to exact 1024x500 24-bit PNG
    final_img = img.resize((target_w, target_h), Image.Resampling.LANCZOS)
    rgb_img = Image.new("RGB", (target_w, target_h), (9, 13, 22))
    rgb_img.paste(final_img, mask=final_img.split()[3])

    out_path = "assets/branding/store/feature_graphic_1024x500.png"
    rgb_img.save(out_path, "PNG", optimize=True)
    print(f"✓ Successfully generated: {out_path} ({target_w}x{target_h}, RGB 24-bit)")

if __name__ == "__main__":
    render_feature_graphic()
