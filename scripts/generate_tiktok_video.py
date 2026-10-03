#!/usr/bin/env python3
"""
Generate authentic, high-retention 9:16 TikTok / YouTube Shorts / Reels video:
Level 38 ("Clockwork") — 4 pieces, cross-coupled axes, Par 7 tactical masterclass.
Duration: ~24.0 seconds (720 frames at 30 FPS) with in-game UI, vector gold stars,
and synchronized audio (swipes, undo click, victory major chord).
"""

import math
import os
import wave
import numpy as np
from PIL import Image, ImageDraw, ImageFont
import imageio_ffmpeg

OUTPUT_DIR = "assets/branding/social"
OUTPUT_VIDEO = os.path.join(OUTPUT_DIR, "tiktok_promo_video.mp4")
TEMP_WAV = "/tmp/tiktok_audio.wav"

WIDTH, HEIGHT = 1080, 1920
FPS = 30
TOTAL_FRAMES = 720  # 24.0 seconds

def get_font(size, bold=True):
    paths = [
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for p in paths:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                continue
    return ImageFont.load_default()

FONT_HOOK_BIG = get_font(46, bold=True)
FONT_LEVEL_NUM = get_font(28, bold=True)
FONT_LEVEL_NAME = get_font(42, bold=True)
FONT_PAR = get_font(24, bold=True)
FONT_MOVES = get_font(28, bold=True)
FONT_HINT = get_font(22, bold=False)
FONT_WIN_TITLE = get_font(38, bold=True)
FONT_RATING = get_font(32, bold=True)
FONT_WIN_SUB = get_font(26, bold=False)
FONT_BTN = get_font(28, bold=True)
FONT_FOOTER = get_font(22, bold=True)

# Generate Audio Track with tactile clicks, undo sound, and victory chime
def generate_audio(duration_sec, sfx_times):
    sample_rate = 44100
    total_samples = int(sample_rate * duration_sec)
    audio = np.zeros(total_samples, dtype=np.float32)

    def add_swipe(t_sec):
        idx = int(t_sec * sample_rate)
        length = int(0.10 * sample_rate)
        t = np.linspace(0, 0.10, length, endpoint=False)
        freq = 480.0 - 280.0 * (t / 0.10)
        env = np.exp(-t * 40.0)
        tone = 0.35 * np.sin(2 * np.pi * freq * t) * env
        end_idx = min(idx + length, total_samples)
        audio[idx:end_idx] += tone[:end_idx - idx]

    def add_undo(t_sec):
        idx = int(t_sec * sample_rate)
        length = int(0.12 * sample_rate)
        t = np.linspace(0, 0.12, length, endpoint=False)
        freq = 240.0 + 260.0 * (t / 0.12)  # ascending 'rewind' pop
        env = np.exp(-t * 30.0)
        tone = 0.32 * np.sin(2 * np.pi * freq * t) * env
        end_idx = min(idx + length, total_samples)
        audio[idx:end_idx] += tone[:end_idx - idx]

    def add_chime(t_sec):
        idx = int(t_sec * sample_rate)
        length = int(3.0 * sample_rate)
        t = np.linspace(0, 3.0, length, endpoint=False)
        chord_freqs = [523.25, 659.25, 783.99, 1046.50]  # C Major
        tone = np.zeros(length, dtype=np.float32)
        for i, f in enumerate(chord_freqs):
            env = np.exp(-t * (1.1 + i * 0.35))
            tone += (0.24 / len(chord_freqs)) * np.sin(2 * np.pi * f * t) * env
            tone += (0.07 / len(chord_freqs)) * np.sin(2 * np.pi * (f * 2) * t) * (env ** 1.6)
        end_idx = min(idx + length, total_samples)
        audio[idx:end_idx] += tone[:end_idx - idx]

    for t, sfx_type in sfx_times:
        if sfx_type == "swipe":
            add_swipe(t)
        elif sfx_type == "undo":
            add_undo(t)
        elif sfx_type == "win":
            add_chime(t)

    audio = np.clip(audio, -1.0, 1.0)
    audio_int16 = (audio * 32767).astype(np.int16)
    with wave.open(TEMP_WAV, "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        wf.writeframes(audio_int16.tobytes())

def draw_vector_star(draw, cx, cy, r_outer, r_inner, fill_color, outline_color, halo_color=None):
    if halo_color:
        for hr in range(int(r_outer * 1.5), int(r_outer), -3):
            alpha = int(45 * (1.0 - (hr - r_outer) / (r_outer * 0.5)))
            draw.ellipse([cx - hr, cy - hr, cx + hr, cy + hr], fill=(halo_color[0], halo_color[1], halo_color[2], alpha))
            
    points = []
    for i in range(10):
        r = r_outer if i % 2 == 0 else r_inner
        angle = -math.pi / 2 + i * (math.pi / 5)
        points.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    draw.polygon(points, fill=fill_color, outline=outline_color, width=3)

# Render frame
def render_frame(f_idx):
    t_sec = f_idx / FPS
    # In-game authentic background #040C3A
    img = Image.new("RGBA", (WIDTH, HEIGHT), (4, 12, 58, 255))
    draw = ImageDraw.Draw(img)

    # Ambient deep sapphire and cyan glows
    for r in range(500, 0, -40):
        alpha = int(18 * (1.0 - (r / 500)))
        draw.ellipse([WIDTH // 2 - r, 780 - r, WIDTH // 2 + r, 780 + r], fill=(13, 31, 75, alpha))
    for r in range(260, 0, -25):
        alpha = int(22 * (1.0 - (r / 260)))
        draw.ellipse([WIDTH // 2 - r, 780 - r, WIDTH // 2 + r, 780 + r], fill=(0, 229, 255, alpha))

    # Top Hook Banner (TikTok engagement driver)
    hook_bg_y = 70
    if t_sec < 4.2:
        hook_line1 = "LEVEL 38 HAS ONLY 7 MOVES."
        hook_line2 = "95% fail on move 2."
        hook_col = (251, 191, 36)  # Amber
    elif t_sec < 7.2:
        hook_line1 = "TRAP: Greedy move ruin other pieces!"
        hook_line2 = "Hit UNDO and stage first..."
        hook_col = (248, 113, 113)  # Red warning
    elif t_sec < 13.0:
        hook_line1 = "STEP 1-3: CORNER PINION STAGING"
        hook_line2 = "Line up rows before columns"
        hook_col = (56, 189, 248)  # Cyan
    elif t_sec < 17.5:
        hook_line1 = "TOROIDAL CASCADE LOCK"
        hook_line2 = "Wrap Row 0 left twice!"
        hook_col = (168, 85, 247)  # Purple
    else:
        hook_line1 = "ALL 4 PIECES SYNCHRONIZED!"
        hook_line2 = "Perfect 3-Star Authoritative Par"
        hook_col = (16, 185, 129)  # Emerald

    # Draw Hook banner card
    draw.rounded_rectangle([60, hook_bg_y, WIDTH - 60, hook_bg_y + 115], radius=20, fill=(15, 23, 42, 230), outline=(hook_col[0], hook_col[1], hook_col[2], 180), width=2)
    b1 = FONT_HOOK_BIG.getbbox(hook_line1)
    b2 = FONT_HOOK_BIG.getbbox(hook_line2)
    draw.text(((WIDTH - (b1[2] - b1[0])) // 2, hook_bg_y + 12), hook_line1, font=FONT_HOOK_BIG, fill=(255, 255, 255, 255))
    draw.text(((WIDTH - (b2[2] - b2[0])) // 2, hook_bg_y + 60), hook_line2, font=FONT_HOOK_BIG, fill=hook_col)

    # In-Game Top Header (GameHeader.dart)
    hdr_y = 220
    draw.text((70, hdr_y), "LEVEL 38", font=FONT_LEVEL_NUM, fill=(56, 189, 248, 255))  # Cyan Color(0xFF38BDF8)
    draw.text((70, hdr_y + 36), "Clockwork", font=FONT_LEVEL_NAME, fill=(255, 255, 255, 255))
    draw.text((70, hdr_y + 88), "Optimal Par: 7 moves", font=FONT_PAR, fill=(148, 163, 184, 255))

    # Sound icon circle
    snd_x = WIDTH - 270
    draw.ellipse([snd_x, hdr_y + 18, snd_x + 48, hdr_y + 66], fill=(30, 41, 59, 200), outline=(51, 65, 85, 255), width=2)
    # Speaker shape
    draw.polygon([(snd_x + 16, hdr_y + 36), (snd_x + 22, hdr_y + 36), (snd_x + 30, hdr_y + 28), (snd_x + 30, hdr_y + 56), (snd_x + 22, hdr_y + 48), (snd_x + 16, hdr_y + 48)], fill=(148, 163, 184, 255))

    # Calculate Move Count based on script timeline
    # 0.0 - 4.2s: moves = 0
    # 4.2 - 5.5s: Greedy Move 1 (Row 0 right) -> moves = 1
    # 5.5 - 7.0s: UNDO -> moves = 0
    # 7.0 - 8.4s: Move 1 (Col 1 UP) -> moves = 1
    # 8.4 - 9.8s: Move 2 (Col 3 UP) -> moves = 2
    # 9.8 - 11.2s: Move 3 (Col 3 UP) -> moves = 3
    # 11.2 - 12.6s: Move 4 (Row 4 LEFT) -> moves = 4
    # 12.6 - 14.0s: Move 5 (Row 0 LEFT) -> moves = 5
    # 14.0 - 15.4s: Move 6 (Row 0 LEFT) -> moves = 6
    # 15.4 - 17.0s: Move 7 (Col 1 UP) -> moves = 7
    # 17.0 - 24.0s: WIN! moves = 7
    if t_sec < 4.4:
        display_moves = 0
    elif t_sec < 5.8:
        display_moves = 1  # Greedy
    elif t_sec < 7.2:
        display_moves = 0  # Undone
    elif t_sec < 8.6:
        display_moves = 1
    elif t_sec < 10.0:
        display_moves = 2
    elif t_sec < 11.4:
        display_moves = 3
    elif t_sec < 12.8:
        display_moves = 4
    elif t_sec < 14.2:
        display_moves = 5
    elif t_sec < 15.6:
        display_moves = 6
    else:
        display_moves = 7

    # Moves Pill Container (exact GameHeader.dart)
    pill_x = WIDTH - 200
    pill_w = 135
    pill_h = 62
    draw.rounded_rectangle([pill_x, hdr_y + 12, pill_x + pill_w, hdr_y + 12 + pill_h], radius=14, fill=(30, 41, 59, 255), outline=(51, 65, 85, 255), width=2)
    draw.text((pill_x + 14, hdr_y + 18), "Moves", font=FONT_PAR, fill=(148, 163, 184, 255))
    m_text = f"{display_moves}/7"
    bm = FONT_MOVES.getbbox(m_text)
    draw.text((pill_x + pill_w - 14 - (bm[2] - bm[0]), hdr_y + 36), m_text, font=FONT_MOVES, fill=(56, 189, 248, 255))

    # In-Game Hint text
    hint_y = 356
    draw.text((70, hint_y), "Synchronize four corner pinions with precision timing.", font=FONT_HINT, fill=(100, 116, 139, 255))

    # Board layout: 5x5 Grid
    grid_size = 760
    cell_gap = 18
    cell_w = (grid_size - cell_gap * 4) / 5  # ~137.6px
    grid_x0 = (WIDTH - grid_size) // 2
    grid_y0 = 420

    # Board outer frame
    draw.rounded_rectangle(
        [grid_x0 - 24, grid_y0 - 24, grid_x0 + grid_size + 24, grid_y0 + grid_size + 24],
        radius=30,
        fill=(10, 18, 42, 240),
        outline=(26, 42, 78, 255),
        width=3
    )

    # Level 38 Targets:
    # Emerald: (0, 1)
    # Amber:   (0, 3)
    # Rose:    (4, 1)
    # Violet:  (4, 3)
    targets = {
        (0, 1): "emerald",
        (0, 3): "amber",
        (4, 1): "rose",
        (4, 3): "violet",
    }

    # Piece positions state interpolation:
    # Initial:
    # Emerald: (2, 1)
    # Amber:   (0, 0)
    # Rose:    (2, 3)
    # Violet:  (4, 4)
    em_r, em_c = 2.0, 1.0
    am_r, am_c = 0.0, 0.0
    ro_r, ro_c = 2.0, 3.0
    vi_r, vi_c = 4.0, 4.0

    active_row = None
    active_col = None
    finger_pos = None

    # Easing helper
    def ease(p):
        return 0.5 - 0.5 * math.cos(p * math.pi)

    if 4.4 <= t_sec < 5.4:
        # GREEDY BLUNDER: Row 0 RIGHT by 1
        active_row = 0
        p = ease(min(1.0, (t_sec - 4.4) / 0.8))
        am_c = 0.0 + p * 3.0  # naively slide Amber right toward target
        finger_pos = (grid_x0 + am_c * (cell_w + cell_gap) + cell_w / 2, grid_y0 + 0 * (cell_w + cell_gap) + cell_w / 2)
    elif 5.4 <= t_sec < 5.8:
        active_row = 0
        am_c = 3.0
    elif 5.8 <= t_sec < 6.8:
        # UNDO! Rewind back to 0,0
        active_row = 0
        p = ease(min(1.0, (t_sec - 5.8) / 0.7))
        am_c = 3.0 - p * 3.0
    elif 6.8 <= t_sec < 7.2:
        am_c = 0.0

    if 7.2 <= t_sec:
        # Move 1: Col 1 UP by 1 (t=7.2 to 8.4). Emerald at 2,1 moves to 1,1.
        if t_sec < 8.4:
            active_col = 1
            p = ease(min(1.0, (t_sec - 7.2) / 0.8))
            em_r = 2.0 - p * 1.0
            finger_pos = (grid_x0 + 1 * (cell_w + cell_gap) + cell_w / 2, grid_y0 + em_r * (cell_w + cell_gap) + cell_w / 2)
        else:
            em_r = 1.0

    if 8.6 <= t_sec:
        # Move 2: Col 3 UP by 1 (t=8.6 to 9.8). Rose at 2,3 moves to 1,3.
        if t_sec < 9.8:
            active_col = 3
            p = ease(min(1.0, (t_sec - 8.6) / 0.8))
            ro_r = 2.0 - p * 1.0
            finger_pos = (grid_x0 + 3 * (cell_w + cell_gap) + cell_w / 2, grid_y0 + ro_r * (cell_w + cell_gap) + cell_w / 2)
        else:
            ro_r = 1.0

    if 10.0 <= t_sec:
        # Move 3: Col 3 UP by 1 (t=10.0 to 11.2). Rose at 1,3 moves to 0,3 (staged).
        if t_sec < 11.2:
            active_col = 3
            p = ease(min(1.0, (t_sec - 10.0) / 0.8))
            ro_r = 1.0 - p * 1.0
            finger_pos = (grid_x0 + 3 * (cell_w + cell_gap) + cell_w / 2, grid_y0 + ro_r * (cell_w + cell_gap) + cell_w / 2)
        else:
            ro_r = 0.0

    if 11.4 <= t_sec:
        # Move 4: Row 4 LEFT by 1 (t=11.4 to 12.6). Violet at 4,4 moves to 4,3 (TARGET!).
        if t_sec < 12.6:
            active_row = 4
            p = ease(min(1.0, (t_sec - 11.4) / 0.8))
            vi_c = 4.0 - p * 1.0
            finger_pos = (grid_x0 + vi_c * (cell_w + cell_gap) + cell_w / 2, grid_y0 + 4 * (cell_w + cell_gap) + cell_w / 2)
        else:
            vi_c = 3.0

    if 12.8 <= t_sec:
        # Move 5: Row 0 LEFT by 1 (t=12.8 to 14.0).
        # Row 0 contains: Amber at (0,0), Rose at (0,3).
        # Shifting LEFT: Amber wraps toroidally from col 0 to col 4! Rose moves from col 3 to col 2.
        if t_sec < 14.0:
            active_row = 0
            p = ease(min(1.0, (t_sec - 12.8) / 0.8))
            am_c = 0.0 - p * 1.0
            ro_c = 3.0 - p * 1.0
            finger_pos = (grid_x0 + 1 * (cell_w + cell_gap) + cell_w / 2 - p * cell_w, grid_y0 + 0 * (cell_w + cell_gap) + cell_w / 2)
        else:
            am_c = 4.0
            ro_c = 2.0

    if 14.2 <= t_sec:
        # Move 6: Row 0 LEFT by 1 (t=14.2 to 15.4).
        # Row 0 contains: Amber at (0,4), Rose at (0,2).
        # Shifting LEFT: Amber moves from col 4 to col 3 (TARGET!). Rose moves from col 2 to col 1.
        if t_sec < 15.4:
            active_row = 0
            p = ease(min(1.0, (t_sec - 14.2) / 0.8))
            am_c = 4.0 - p * 1.0
            ro_c = 2.0 - p * 1.0
            finger_pos = (grid_x0 + 2 * (cell_w + cell_gap) + cell_w / 2 - p * cell_w, grid_y0 + 0 * (cell_w + cell_gap) + cell_w / 2)
        else:
            am_c = 3.0
            ro_c = 1.0

    if 15.6 <= t_sec:
        # Move 7: Col 1 UP by 1 (t=15.6 to 16.8).
        # Col 1 contains: Rose at (0,1), Emerald at (1,1).
        # Shifting UP:
        # Rose at (0,1) wraps toroidally to (4,1) (TARGET!)
        # Emerald at (1,1) moves to (0,1) (TARGET!)
        # ALL 4 PIECES SOLVED!
        if t_sec < 16.8:
            active_col = 1
            p = ease(min(1.0, (t_sec - 15.6) / 0.8))
            ro_r = 0.0 - p * 1.0
            em_r = 1.0 - p * 1.0
            finger_pos = (grid_x0 + 1 * (cell_w + cell_gap) + cell_w / 2, grid_y0 + (1.0 - p) * (cell_w + cell_gap) + cell_w / 2)
        else:
            ro_r = 4.0
            em_r = 0.0

    # Draw Highlight Track if active
    if active_row is not None:
        ry = grid_y0 + active_row * (cell_w + cell_gap)
        draw.rounded_rectangle([grid_x0 - 12, ry - 6, grid_x0 + grid_size + 12, ry + cell_w + 6], radius=16, fill=(56, 189, 248, 25), outline=(56, 189, 248, 120), width=2)
    elif active_col is not None:
        cx = grid_x0 + active_col * (cell_w + cell_gap)
        draw.rounded_rectangle([cx - 6, grid_y0 - 12, cx + cell_w + 6, grid_y0 + grid_size + 12], radius=16, fill=(56, 189, 248, 25), outline=(56, 189, 248, 120), width=2)

    # Draw Base Grid Cells & Target Rings
    for r in range(5):
        for c in range(5):
            x = grid_x0 + c * (cell_w + cell_gap)
            y = grid_y0 + r * (cell_w + cell_gap)
            # Base dark slot
            draw.rounded_rectangle([x, y, x + cell_w, y + cell_w], radius=22, fill=(15, 23, 42, 220), outline=(30, 41, 59, 240), width=2)

            # Check if this cell is a target
            if (r, c) in targets:
                tt = targets[(r, c)]
                cx_c, cy_c = x + cell_w / 2, y + cell_w / 2
                pulse = 1.0 + 0.06 * math.sin(t_sec * 5.0)

                if tt == "emerald":  # Hexagon at (0, 1)
                    sz = 28 * pulse
                    hex_pts = []
                    for i in range(6):
                        ang = i * (math.pi / 3)
                        hex_pts.append((cx_c + sz * math.cos(ang), cy_c + sz * math.sin(ang)))
                    draw.polygon(hex_pts, outline=(16, 185, 129, 240), width=3)
                elif tt == "amber":  # Diamond at (0, 3)
                    sz = 26 * pulse
                    draw.polygon([(cx_c, cy_c - sz), (cx_c + sz, cy_c), (cx_c, cy_c + sz), (cx_c - sz, cy_c)], outline=(245, 158, 11, 240), width=3)
                elif tt == "rose":  # Square at (4, 1)
                    sz = 24 * pulse
                    draw.rectangle([cx_c - sz, cy_c - sz, cx_c + sz, cy_c + sz], outline=(244, 63, 94, 240), width=3)
                elif tt == "violet":  # Triangle at (4, 3)
                    sz = 27 * pulse
                    draw.polygon([(cx_c, cy_c - sz), (cx_c + sz * 0.9, cy_c + sz * 0.8), (cx_c - sz * 0.9, cy_c + sz * 0.8)], outline=(168, 85, 247, 240), width=3)

    # Function to draw piece with authentic geometry & toroidal wrap-around
    def draw_board_piece(row_val, col_val, ptype):
        # Toroidal instances
        r_instances = [row_val]
        if row_val > 4.0:
            r_instances.append(row_val - 5.0)
        elif row_val < 0.0:
            r_instances.append(row_val + 5.0)

        c_instances = [col_val]
        if col_val > 4.0:
            c_instances.append(col_val - 5.0)
        elif col_val < 0.0:
            c_instances.append(col_val + 5.0)

        for rv in r_instances:
            for cv in c_instances:
                px = grid_x0 + cv * (cell_w + cell_gap)
                py = grid_y0 + rv * (cell_w + cell_gap)

                if px < grid_x0 - cell_w or px > grid_x0 + grid_size + cell_w:
                    continue
                if py < grid_y0 - cell_w or py > grid_y0 + grid_size + cell_w:
                    continue

                cx_p = px + cell_w / 2
                cy_p = py + cell_w / 2

                if ptype == "emerald":
                    # Green Hexagon
                    sz = cell_w * 0.38
                    pts = []
                    for i in range(6):
                        ang = i * (math.pi / 3)
                        pts.append((cx_p + sz * math.cos(ang), cy_p + sz * math.sin(ang)))
                    # Halo
                    draw.polygon(pts, fill=(16, 185, 129, 255), outline=(255, 255, 255, 220), width=3)
                    # Inner core
                    draw.ellipse([cx_p - 14, cy_p - 14, cx_p + 14, cy_p + 14], fill=(255, 255, 255, 230))
                elif ptype == "amber":
                    # Orange Diamond
                    sz = cell_w * 0.40
                    poly = [(cx_p, cy_p - sz), (cx_p + sz, cy_p), (cx_p, cy_p + sz), (cx_p - sz, cy_p)]
                    draw.polygon(poly, fill=(245, 158, 11, 255), outline=(255, 255, 200, 240), width=3)
                    draw.ellipse([cx_p - 12, cy_p - 12, cx_p + 12, cy_p + 12], fill=(255, 255, 255, 230))
                elif ptype == "rose":
                    # Rose Rounded Square
                    sz = cell_w * 0.36
                    draw.rounded_rectangle([cx_p - sz, cy_p - sz, cx_p + sz, cy_p + sz], radius=16, fill=(244, 63, 94, 255), outline=(255, 220, 230, 240), width=3)
                    draw.ellipse([cx_p - 12, cy_p - 12, cx_p + 12, cy_p + 12], fill=(255, 255, 255, 230))
                elif ptype == "violet":
                    # Violet Triangle
                    sz = cell_w * 0.40
                    poly = [(cx_p, cy_p - sz), (cx_p + sz * 0.9, cy_p + sz * 0.8), (cx_p - sz * 0.9, cy_p + sz * 0.8)]
                    draw.polygon(poly, fill=(168, 85, 247, 255), outline=(255, 230, 255, 240), width=3)
                    draw.ellipse([cx_p - 12, cy_p - 2, cx_p + 12, cy_p + 22], fill=(255, 255, 255, 230))

    draw_board_piece(em_r, em_c, "emerald")
    draw_board_piece(am_r, am_c, "amber")
    draw_board_piece(ro_r, ro_c, "rose")
    draw_board_piece(vi_r, vi_c, "violet")

    # Animated finger cursor during moves
    if finger_pos is not None:
        fx, fy = finger_pos
        draw.ellipse([fx - 24, fy - 24, fx + 24, fy + 24], fill=(255, 255, 255, 170), outline=(56, 189, 248, 255), width=3)

    # In-Game Bottom GameControls.dart
    ctrl_y = 1240
    # Center controls bar
    bar_w = 420
    bar_x = (WIDTH - bar_w) // 2
    draw.rounded_rectangle([bar_x, ctrl_y, bar_x + bar_w, ctrl_y + 80], radius=24, fill=(15, 23, 42, 240), outline=(30, 41, 59, 255), width=2)
    # Icons: Prev, Undo, Reset, Next
    icons_x = [bar_x + 55, bar_x + 145, bar_x + 245, bar_x + 345]
    
    # Prev arrow
    draw.polygon([(icons_x[0] + 4, ctrl_y + 40), (icons_x[0] + 16, ctrl_y + 30), (icons_x[0] + 16, ctrl_y + 50)], fill=(148, 163, 184, 255))
    
    # Undo icon (highlighted during undo at t=5.8 to 7.0)
    undo_col = (56, 189, 248, 255) if (5.5 <= t_sec < 7.2) else (148, 163, 184, 255)
    ux = icons_x[1]
    draw.arc([ux - 14, ctrl_y + 26, ux + 14, ctrl_y + 54], start=45, end=270, fill=undo_col, width=3)
    draw.polygon([(ux - 18, ctrl_y + 38), (ux - 10, ctrl_y + 30), (ux - 10, ctrl_y + 46)], fill=undo_col)

    # Restart icon
    rx = icons_x[2]
    draw.arc([rx - 14, ctrl_y + 26, rx + 14, ctrl_y + 54], start=0, end=300, fill=(148, 163, 184, 255), width=3)
    draw.polygon([(rx + 6, ctrl_y + 24), (rx + 16, ctrl_y + 32), (rx + 16, ctrl_y + 16)], fill=(148, 163, 184, 255))

    # Next arrow
    draw.polygon([(icons_x[3] + 16, ctrl_y + 40), (icons_x[3] + 4, ctrl_y + 30), (icons_x[3] + 4, ctrl_y + 50)], fill=(148, 163, 184, 255))

    # Authentic In-Game WinDialog (drops in at t=17.0s)
    if t_sec >= 17.0:
        pop_p = min(1.0, (t_sec - 17.0) / 0.5)
        # Elastic scale
        scale = 0.4 + 0.6 * math.sin(pop_p * math.pi / 2)

        # Modal overlay dim
        dim = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, int(185 * pop_p)))
        img = Image.alpha_composite(img, dim)
        draw = ImageDraw.Draw(img)

        # Dialog Box Dimensions (matching WinDialog.dart: Color(0xFF0F172A), border Color(0xFFFBBF24))
        dw = int(780 * scale)
        dh = int(680 * scale)
        dx0 = (WIDTH - dw) // 2
        dy0 = (HEIGHT - dh) // 2

        # Outer Golden Halo
        for gr in range(40, 0, -8):
            draw.rounded_rectangle([dx0 - gr, dy0 - gr, dx0 + dw + gr, dy0 + dh + gr], radius=32, fill=(251, 191, 36, int(8 * (1.0 - gr / 40))))

        # Win Card
        draw.rounded_rectangle([dx0, dy0, dx0 + dw, dy0 + dh], radius=28, fill=(15, 23, 42, 255), outline=(251, 191, 36, 230), width=3)

        if scale > 0.85:
            # Top circular celebration icon badge
            badge_r = 38
            bcx, bcy = WIDTH // 2, dy0 + 70
            draw.ellipse([bcx - badge_r, bcy - badge_r, bcx + badge_r, bcy + badge_r], fill=(251, 191, 36, 40), outline=(251, 191, 36, 180), width=2)
            # Sparkle star in badge
            draw_vector_star(draw, bcx, bcy, 22, 10, (251, 191, 36), (255, 255, 255))

            # 'LEVEL COMPLETE' text
            lc_text = "LEVEL COMPLETE"
            bb_lc = FONT_WIN_TITLE.getbbox(lc_text)
            draw.text(((WIDTH - (bb_lc[2] - bb_lc[0])) // 2, dy0 + 130), lc_text, font=FONT_WIN_TITLE, fill=(255, 255, 255, 255))

            # 3 High-Resolution Geometric 5-Pointed Gold Stars
            # Star animation: sequential pop
            star_base_y = dy0 + 225
            star_centers = [WIDTH // 2 - 110, WIDTH // 2, WIDTH // 2 + 110]
            star_delays = [17.4, 17.7, 18.0]
            
            for s_idx in range(3):
                scx = star_centers[s_idx]
                s_time = star_delays[s_idx]
                if t_sec >= s_time:
                    s_prog = min(1.0, (t_sec - s_time) / 0.3)
                    # bounce scale
                    s_scale = 1.0 + 0.35 * math.sin(s_prog * math.pi)
                    r_out = int((44 if s_idx == 1 else 36) * s_scale)
                    r_in = int(r_out * 0.48)
                    draw_vector_star(
                        draw, scx, star_base_y, r_out, r_in,
                        fill_color=(251, 191, 36, 255),
                        outline_color=(255, 245, 180, 255),
                        halo_color=(251, 191, 36)
                    )
                else:
                    # Empty slate star outline
                    r_out = 36 if s_idx != 1 else 44
                    r_in = int(r_out * 0.48)
                    draw_vector_star(draw, scx, star_base_y, r_out, r_in, fill_color=(30, 41, 59, 255), outline_color=(51, 65, 85, 255))

            # 'PERFECT!' rating label
            r_text = "PERFECT!"
            bb_r = FONT_RATING.getbbox(r_text)
            draw.text(((WIDTH - (bb_r[2] - bb_r[0])) // 2, dy0 + 295), r_text, font=FONT_RATING, fill=(251, 191, 36, 255))

            # Move stats
            m_stat = "Moves: 7"
            bb_ms = FONT_WIN_SUB.getbbox(m_stat)
            draw.text(((WIDTH - (bb_ms[2] - bb_ms[0])) // 2, dy0 + 348), m_stat, font=FONT_WIN_SUB, fill=(255, 255, 255, 255))

            opt_stat = "Optimal: 7 moves"
            bb_os = FONT_HINT.getbbox(opt_stat)
            draw.text(((WIDTH - (bb_os[2] - bb_os[0])) // 2, dy0 + 386), opt_stat, font=FONT_HINT, fill=(148, 163, 184, 255))

            # In-Game Next Level Button (Color(0xFF38BDF8) Sky Blue)
            btn_w = 540
            btn_h = 76
            bx = (WIDTH - btn_w) // 2
            by = dy0 + 440
            draw.rounded_rectangle([bx, by, bx + btn_w, by + btn_h], radius=18, fill=(56, 189, 248, 255))
            btn_txt = "NEXT LEVEL"
            bb_bt = FONT_BTN.getbbox(btn_txt)
            draw.text(((WIDTH - (bb_bt[2] - bb_bt[0])) // 2, by + 22), btn_txt, font=FONT_BTN, fill=(4, 12, 58, 255))

            # Replay Button (Secondary)
            rbtn_y = dy0 + 535
            draw.rounded_rectangle([bx, rbtn_y, bx + btn_w, rbtn_y + 60], radius=16, fill=(30, 41, 59, 200), outline=(51, 65, 85, 255), width=2)
            r_txt = "REPLAY"
            bb_rt = FONT_PAR.getbbox(r_txt)
            draw.text(((WIDTH - (bb_rt[2] - bb_rt[0])) // 2, rbtn_y + 16), r_txt, font=FONT_PAR, fill=(148, 163, 184, 255))

            # CTA text at bottom of dialog
            draw.text(((WIDTH - 420) // 2, dy0 + 620), "Free Standalone APK • shiftpuzzle.app", font=FONT_PAR, fill=(56, 189, 248, 255))

    # Persistent Bottom Watermark / CTA
    draw.text((WIDTH // 2 - 250, 1830), "Shift Puzzle • 150 Levels • Link in Bio 📲", font=FONT_FOOTER, fill=(100, 116, 139, 240))

    return img.convert("RGB")

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    ffmpeg_exe = imageio_ffmpeg.get_ffmpeg_exe()
    duration_sec = TOTAL_FRAMES / FPS
    print(f"Generating Level 38 'Clockwork' TikTok video ({TOTAL_FRAMES} frames, {duration_sec:.1f}s at {FPS} FPS)...")

    # SFX events:
    sfx_events = [
        (4.4, "swipe"),  # Greedy
        (5.8, "undo"),   # Undo!
        (7.2, "swipe"),  # Move 1
        (8.6, "swipe"),  # Move 2
        (10.0, "swipe"), # Move 3
        (11.4, "swipe"), # Move 4
        (12.8, "swipe"), # Move 5
        (14.2, "swipe"), # Move 6
        (15.6, "swipe"), # Move 7
        (17.0, "win")    # Victory Chime!
    ]
    print("Synthesizing audio track with synchronized swipes, undo, and victory chord...")
    generate_audio(duration_sec, sfx_events)

    temp_video_no_audio = "/tmp/tiktok_video_no_audio.mp4"
    writer = imageio_ffmpeg.write_frames(
        temp_video_no_audio,
        (WIDTH, HEIGHT),
        fps=FPS,
        codec="libx264",
        pix_fmt_in="rgb24",
        ffmpeg_log_level="error",
        quality=8
    )
    writer.send(None)

    for i in range(TOTAL_FRAMES):
        if i % 90 == 0:
            print(f"Rendering frame {i}/{TOTAL_FRAMES} ({i / TOTAL_FRAMES * 100:.0f}%)...")
        frame_img = render_frame(i)
        writer.send(np.array(frame_img))

    writer.close()
    print("Video frames encoded. Merging video and audio...")

    cmd = (
        f"{ffmpeg_exe} -y -i {temp_video_no_audio} -i {TEMP_WAV} "
        f"-c:v copy -c:a aac -b:a 192k -shortest {OUTPUT_VIDEO}"
    )
    res = os.system(cmd)
    if res == 0:
        print(f"\n🎉 SUCCESS! Generated {OUTPUT_VIDEO} ({os.path.getsize(OUTPUT_VIDEO) / 1024 / 1024:.2f} MB)")
    else:
        print("Audio merge failed, saving video only.")
        os.rename(temp_video_no_audio, OUTPUT_VIDEO)

if __name__ == "__main__":
    main()
