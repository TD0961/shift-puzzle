#!/usr/bin/env python3
"""
Generate professional Android Launcher & Google Play Store icons for Shift Puzzle.
Renders at 4x resolution with high-precision anti-aliasing and Lanczos downsampling.
"""

import math
import os
from PIL import Image, ImageDraw, ImageFilter

def create_icon_layers(size=512):
    """
    Renders the Shift Puzzle icon at 4x resolution for extreme anti-aliased clarity.
    Returns (master_composite, foreground_transparent, background_layer).
    """
    scale = 4
    canvas_size = size * scale
    center = canvas_size / 2.0

    # 1. Background Layer (Deep obsidian space with subtle deep slate radial vignette)
    bg_img = Image.new("RGBA", (canvas_size, canvas_size), (9, 13, 22, 255)) # #090D16
    bg_draw = ImageDraw.Draw(bg_img)
    
    # Subtle deep radial ambient glow in the center for depth
    max_r = canvas_size * 0.65
    for i in range(40, 0, -1):
        r = max_r * (i / 40.0)
        alpha = int(22 * (1.0 - (i / 40.0)))
        # Deep sapphire ambient #0d1b33
        bg_draw.ellipse(
            [center - r, center - r, center + r, center + r],
            fill=(13, 27, 51, alpha)
        )

    # 2. Foreground Layer (Transparent canvas for adaptive icon foreground)
    fg_img = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    fg_draw = ImageDraw.Draw(fg_img)

    # Calculate 5x5 Grid Geometry inside the guaranteed Safe Zone (66% diameter)
    # At 512px, safe diameter = 512 * 0.66 = 338px. In 4x scale = 1352px.
    # We choose a grid bounding box of 920px (230px at 1x) so even the furthest corner
    # diagonal is 460 * sqrt(2) = 650px from center, safely inside the 676px radius!
    grid_total_span = canvas_size * 0.46  # ~942px
    num_cells = 5
    gap = grid_total_span * 0.05          # ~47px
    cell_size = (grid_total_span - gap * (num_cells - 1)) / num_cells  # ~150px
    corner_radius = cell_size * 0.28      # ~42px rounded corners

    grid_origin_x = center - (grid_total_span / 2.0)
    grid_origin_y = center - (grid_total_span / 2.0)

    # Middle row index = 2 (0, 1, 2, 3, 4)
    # Dynamic shift offset for row 2 to illustrate the toroidal sliding mechanic!
    shift_offset_x = cell_size * 0.42

    # Draw toroidal flow track behind Row 2
    row2_y = grid_origin_y + 2 * (cell_size + gap)
    track_pad = gap * 0.8
    track_y0 = row2_y - track_pad
    track_y1 = row2_y + cell_size + track_pad
    track_x0 = grid_origin_x - gap * 1.5
    track_x1 = grid_origin_x + grid_total_span + gap * 1.5
    
    # Ethereal horizontal track for Row 2
    track_overlay = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    track_draw = ImageDraw.Draw(track_overlay)
    track_draw.rounded_rectangle(
        [track_x0, track_y0, track_x1, track_y1],
        radius=corner_radius * 1.2,
        fill=(0, 229, 255, 18),       # Cyan wash #00E5FF
        outline=(0, 229, 255, 45),
        width=int(2 * scale)
    )
    fg_img = Image.alpha_composite(fg_img, track_overlay)
    fg_draw = ImageDraw.Draw(fg_img)

    # Draw the 5x5 Cells
    for row in range(num_cells):
        for col in range(num_cells):
            cx0 = grid_origin_x + col * (cell_size + gap)
            cy0 = grid_origin_y + row * (cell_size + gap)

            # Apply horizontal shift to row 2
            if row == 2:
                cx0 += shift_offset_x
                # Wrap-around behavior: if it extends past right edge, wrap partially to left
                # (In our balanced composition, row 2 is gracefully shifted rightwards)

            cx1 = cx0 + cell_size
            cy1 = cy0 + cell_size

            # Cell styling
            # Standard cell: dark slate rounded tile
            cell_fill = (20, 31, 52, 235)      # #141F34
            cell_outline = (32, 49, 78, 255)   # #20314E
            cell_width = int(2.5 * scale)

            # Highlight specific puzzle cells
            if row == 2 and col == 2:
                # The central shifting jewel cell: Cyan focus!
                cell_fill = (12, 38, 62, 255)
                cell_outline = (0, 229, 255, 200) # Glowing Cyan border
                cell_width = int(3.5 * scale)
            elif row == 1 and col == 3:
                # Amber diamond target cell
                cell_fill = (38, 32, 18, 255)
                cell_outline = (255, 193, 7, 160) # Amber border
            elif row == 3 and col == 1:
                # Emerald square target cell
                cell_fill = (15, 36, 26, 255)
                cell_outline = (0, 230, 118, 160) # Emerald border

            # Draw rounded square cell
            fg_draw.rounded_rectangle(
                [cx0, cy0, cx1, cy1],
                radius=corner_radius,
                fill=cell_fill,
                outline=cell_outline,
                width=cell_width
            )

    # 3. Draw Signature Game Pieces inside the Grid

    # A. Amber Diamond Gem at (col=3, row=1)
    amber_cx = grid_origin_x + 3 * (cell_size + gap) + cell_size / 2.0
    amber_cy = grid_origin_y + 1 * (cell_size + gap) + cell_size / 2.0
    d_radius = cell_size * 0.32
    diamond_poly = [
        (amber_cx, amber_cy - d_radius),
        (amber_cx + d_radius, amber_cy),
        (amber_cx, amber_cy + d_radius),
        (amber_cx - d_radius, amber_cy)
    ]
    # Glow layer
    fg_draw.polygon(diamond_poly, fill=(255, 193, 7, 240))
    inner_d = d_radius * 0.55
    inner_poly = [
        (amber_cx, amber_cy - inner_d),
        (amber_cx + inner_d, amber_cy),
        (amber_cx, amber_cy + inner_d),
        (amber_cx - inner_d, amber_cy)
    ]
    fg_draw.polygon(inner_poly, fill=(255, 248, 225, 255)) # Warm white core

    # B. Emerald Hexagon/Square Gem at (col=1, row=3)
    em_cx = grid_origin_x + 1 * (cell_size + gap) + cell_size / 2.0
    em_cy = grid_origin_y + 3 * (cell_size + gap) + cell_size / 2.0
    em_r = cell_size * 0.30
    fg_draw.rounded_rectangle(
        [em_cx - em_r, em_cy - em_r, em_cx + em_r, em_cy + em_r],
        radius=corner_radius * 0.5,
        fill=(0, 230, 118, 240),
        outline=(232, 245, 233, 220),
        width=int(1.5 * scale)
    )

    # C. Central Master Hero: Luminous Cyan Circle Piece at (col=2, row=2) shifted
    hero_cx = grid_origin_x + 2 * (cell_size + gap) + shift_offset_x + cell_size / 2.0
    hero_cy = grid_origin_y + 2 * (cell_size + gap) + cell_size / 2.0
    hero_radius = cell_size * 0.36

    # Multi-stage radial halo glow for the Hero piece
    halo_img = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    halo_draw = ImageDraw.Draw(halo_img)
    for hr in range(int(hero_radius * 1.7), int(hero_radius), -int(3 * scale)):
        fade = 1.0 - (hr - hero_radius) / (hero_radius * 0.7)
        alpha = int(70 * (fade ** 1.5))
        halo_draw.ellipse(
            [hero_cx - hr, hero_cy - hr, hero_cx + hr, hero_cy + hr],
            fill=(0, 229, 255, alpha)
        )
    fg_img = Image.alpha_composite(fg_img, halo_img)
    fg_draw = ImageDraw.Draw(fg_img)

    # White target seated verification ring
    target_ring_r = hero_radius * 1.15
    fg_draw.ellipse(
        [hero_cx - target_ring_r, hero_cy - target_ring_r, hero_cx + target_ring_r, hero_cy + target_ring_r],
        outline=(255, 255, 255, 175),
        width=int(2.5 * scale)
    )

    # Solid cyan piece body
    fg_draw.ellipse(
        [hero_cx - hero_radius, hero_cy - hero_radius, hero_cx + hero_radius, hero_cy + hero_radius],
        fill=(0, 229, 255, 255),
        outline=(255, 255, 255, 220),
        width=int(2 * scale)
    )

    # Brilliant specular highlight on the hero piece
    hl_r = hero_radius * 0.42
    hl_offset_x = -hero_radius * 0.22
    hl_offset_y = -hero_radius * 0.22
    fg_draw.ellipse(
        [hero_cx + hl_offset_x - hl_r, hero_cy + hl_offset_y - hl_r,
         hero_cx + hl_offset_x + hl_r, hero_cy + hl_offset_y + hl_r],
        fill=(224, 247, 250, 240) # Bright cyan-white highlight #E0F7FA
    )

    # D. Toroidal directional shift chevron on Row 2
    # Subtle kinetic arrow accent indicating rightward slide and wrapping
    arrow_cx = grid_origin_x + grid_total_span + gap * 0.6 + shift_offset_x * 0.4
    arrow_cy = hero_cy
    arrow_size = cell_size * 0.28
    arrow_pts = [
        (arrow_cx - arrow_size * 0.6, arrow_cy - arrow_size),
        (arrow_cx + arrow_size * 0.5, arrow_cy),
        (arrow_cx - arrow_size * 0.6, arrow_cy + arrow_size)
    ]
    fg_draw.line(arrow_pts, fill=(0, 229, 255, 210), width=int(3 * scale), joint="round")

    # Downsample using high-quality Lanczos resampling
    final_bg = bg_img.resize((size, size), Image.Resampling.LANCZOS)
    final_fg = fg_img.resize((size, size), Image.Resampling.LANCZOS)

    # Full composite for master store icon and legacy mipmaps
    master_composite = Image.alpha_composite(final_bg, final_fg)

    return master_composite, final_fg, final_bg

def create_preview_sheet(master_icon):
    """
    Renders a verification sheet showing the master icon with:
    1. Square full-bleed
    2. Google Play Squircle mask
    3. Circular mask
    4. 48x48 launcher preview
    """
    size = master_icon.size[0]
    preview = Image.new("RGBA", (size * 3 + 120, size + 160), (18, 24, 38, 255))
    draw = ImageDraw.Draw(preview)

    # 1. Full bleed
    preview.paste(master_icon, (40, 60))

    # 2. Rounded squircle
    mask_squircle = Image.new("L", (size, size), 0)
    sq_draw = ImageDraw.Draw(mask_squircle)
    sq_draw.rounded_rectangle([0, 0, size, size], radius=int(size * 0.20), fill=255)
    squircle_icon = Image.composite(master_icon, Image.new("RGBA", (size, size), (0, 0, 0, 0)), mask_squircle)
    preview.paste(squircle_icon, (size + 60, 60), mask=squircle_icon)

    # 3. Circular mask (Standard Android launcher)
    mask_circle = Image.new("L", (size, size), 0)
    c_draw = ImageDraw.Draw(mask_circle)
    c_draw.ellipse([0, 0, size, size], fill=255)
    circle_icon = Image.composite(master_icon, Image.new("RGBA", (size, size), (0, 0, 0, 0)), mask_circle)
    preview.paste(circle_icon, (size * 2 + 80, 60), mask=circle_icon)

    return preview

def main():
    print("Generating Shift Puzzle production icon assets...")
    
    # 1. Generate 512x512 Master Assets
    master_512, fg_512, bg_512 = create_icon_layers(512)
    
    # Save project master branding assets
    os.makedirs("assets/branding/app_icon", exist_ok=True)
    master_512.save("assets/branding/app_icon/shift_puzzle_icon_512.png", "PNG", optimize=True)
    fg_512.save("assets/branding/app_icon/shift_puzzle_icon_foreground_512.png", "PNG", optimize=True)
    bg_512.save("assets/branding/app_icon/shift_puzzle_icon_background_512.png", "PNG", optimize=True)
    print("✓ Saved 512x512 master branding assets in assets/branding/app_icon/")

    # Save visual verification preview sheet
    preview = create_preview_sheet(master_512)
    preview.save("assets/branding/app_icon/shift_puzzle_icon_preview.png", "PNG")
    print("✓ Saved preview sheet: assets/branding/app_icon/shift_puzzle_icon_preview.png")

    # 2. Generate Android Adaptive Icon Layers (432x432 px at xxxhdpi)
    master_432, fg_432, bg_432 = create_icon_layers(432)

    # 3. Generate Android Mipmaps for all densities
    # Standard dimensions: mdpi (48), hdpi (72), xhdpi (96), xxhdpi (144), xxxhdpi (192)
    densities = {
        "mdpi": (48, 108),
        "hdpi": (72, 162),
        "xhdpi": (96, 216),
        "xxhdpi": (144, 324),
        "xxxhdpi": (192, 432)
    }

    res_dir = "android/app/src/main/res"

    for density, (legacy_size, adaptive_size) in densities.items():
        density_dir = os.path.join(res_dir, f"mipmap-{density}")
        os.makedirs(density_dir, exist_ok=True)

        # Legacy Square Icon
        legacy_icon = master_512.resize((legacy_size, legacy_size), Image.Resampling.LANCZOS)
        # Apply gentle rounding to legacy icon (18% squircle) so it looks premium on older Android
        legacy_mask = Image.new("L", (legacy_size, legacy_size), 0)
        lm_draw = ImageDraw.Draw(legacy_mask)
        lm_draw.rounded_rectangle([0, 0, legacy_size, legacy_size], radius=int(legacy_size * 0.18), fill=255)
        legacy_final = Image.composite(legacy_icon, Image.new("RGBA", (legacy_size, legacy_size), (0,0,0,0)), legacy_mask)
        legacy_final.save(os.path.join(density_dir, "ic_launcher.png"), "PNG", optimize=True)

        # Round Icon for devices supporting android:roundIcon
        round_mask = Image.new("L", (legacy_size, legacy_size), 0)
        rm_draw = ImageDraw.Draw(round_mask)
        rm_draw.ellipse([0, 0, legacy_size, legacy_size], fill=255)
        round_final = Image.composite(legacy_icon, Image.new("RGBA", (legacy_size, legacy_size), (0,0,0,0)), round_mask)
        round_final.save(os.path.join(density_dir, "ic_launcher_round.png"), "PNG", optimize=True)

        # Adaptive Foreground Layer for this density
        adaptive_fg = fg_432.resize((adaptive_size, adaptive_size), Image.Resampling.LANCZOS)
        adaptive_fg.save(os.path.join(density_dir, "ic_launcher_foreground.png"), "PNG", optimize=True)

        print(f"✓ Generated {density}: ic_launcher ({legacy_size}px), ic_launcher_round ({legacy_size}px), foreground ({adaptive_size}px)")

    # 4. Generate Web icons (web/icons/) for consistency
    if os.path.exists("web/icons"):
        master_512.save("web/icons/Icon-512.png", "PNG", optimize=True)
        master_512.resize((192, 192), Image.Resampling.LANCZOS).save("web/icons/Icon-192.png", "PNG", optimize=True)
        # Maskable web icons
        master_512.save("web/icons/Icon-maskable-512.png", "PNG", optimize=True)
        master_512.resize((192, 192), Image.Resampling.LANCZOS).save("web/icons/Icon-maskable-192.png", "PNG", optimize=True)
        master_512.resize((64, 64), Image.Resampling.LANCZOS).save("web/favicon.png", "PNG", optimize=True)
        print("✓ Updated web icons in web/icons/ for brand consistency")

    print("\nAll icon assets successfully generated and deployed!")

if __name__ == "__main__":
    main()
