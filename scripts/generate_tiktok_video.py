#!/usr/bin/env python3
"""
Generate authentic, high-retention 9:16 TikTok / YouTube Shorts / Reels video:
Level 24 ("Toroidal Bypass") — matching the EXACT in-game UI from player screenshot:
- Android top status bar (5:07 AM, 4G, 58%)
- GameHeader: 'LEVEL 24 ☷', 'Toroidal Bypass', 'Moves: X / 7', 'Limit: X / 9'
- 5x5 board with exact 3D beveled tiles & targets (Amber diamond, Violet triangle, Cyan concentric rings, Rose square)
- Interactive '💡 Need a hint?' button with contextual guidance
- Exact 7-move optimal solution with authentic toroidal sliding physics
- Exact WinDialog from Screenshot 2: circular checkmark badge, 3 glowing 5-pointed gold stars, 'PERFECT!', 'Moves: 7', 'Replay' and glowing Cyan 'Next Level' button
- Mixed with neural voiceover (Christopher) and synchronized game sound effects
"""

import math
import os
import subprocess
import wave
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import imageio_ffmpeg

OUTPUT_DIR = "assets/branding/social"
OUTPUT_VIDEO = os.path.join(OUTPUT_DIR, "tiktok_promo_video.mp4")
TEMP_WAV = "/tmp/tiktok_audio.wav"
VOICE_DIR = "/tmp/tiktok_voice_clips"

WIDTH, HEIGHT = 1080, 1920
FPS = 30
TOTAL_FRAMES = 945  # 31.5 seconds

# Board Layout Geometry matching in-game specifications
GRID_SIZE = 800
CELL_GAP = 18
CELL_W = (GRID_SIZE - CELL_GAP * 4) / 5  # 145.6px
GRID_X0 = (WIDTH - GRID_SIZE) // 2
GRID_Y0 = 430
BOARD_PAD = 22
BX0 = GRID_X0 - BOARD_PAD
BY0 = GRID_Y0 - BOARD_PAD
BX1 = GRID_X0 + GRID_SIZE + BOARD_PAD
BY1 = GRID_Y0 + GRID_SIZE + BOARD_PAD

# Precompute Radiant Neon Board Aura (Skia MaskFilter.blur match: Color(0xFF0066FF) + Color(0xFF00E5FF))
def create_board_aura():
    aura_img = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    aura_draw = ImageDraw.Draw(aura_img)
    # Deep wide electric blue aura (Color(0xFF0066FF))
    aura_draw.rounded_rectangle(
        [BX0 - 15, BY0 - 15, BX1 + 15, BY1 + 15],
        radius=36,
        fill=(0, 102, 255, 160),
        outline=(0, 229, 255, 220),
        width=8
    )
    aura_blur = aura_img.filter(ImageFilter.GaussianBlur(28))

    # Secondary tight electric cyan aura
    aura_tight = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    tight_draw = ImageDraw.Draw(aura_tight)
    tight_draw.rounded_rectangle(
        [BX0 - 4, BY0 - 4, BX1 + 4, BY1 + 4],
        radius=32,
        outline=(0, 229, 255, 230),
        width=6
    )
    aura_tight_blur = aura_tight.filter(ImageFilter.GaussianBlur(10))

    return Image.alpha_composite(aura_blur, aura_tight_blur)

BOARD_AURA_LAYER = create_board_aura()

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

FONT_STATUS = get_font(22, bold=True)
FONT_LEVEL_TAG = get_font(26, bold=True)
FONT_TITLE = get_font(38, bold=True)
FONT_MOVES_NUM = get_font(28, bold=True)
FONT_MOVES_LBL = get_font(22, bold=False)
FONT_HINT_BTN = get_font(24, bold=True)
FONT_WIN_TITLE = get_font(36, bold=True)
FONT_WIN_RATING = get_font(26, bold=True)
FONT_WIN_STAT = get_font(28, bold=True)
FONT_WIN_OPT = get_font(22, bold=False)
FONT_WIN_BTN = get_font(26, bold=True)
FONT_HINT_POPUP = get_font(24, bold=True)

# Generate combined audio: voiceover clips + game sound effects
def generate_audio(duration_sec):
    sample_rate = 44100
    total_samples = int(sample_rate * duration_sec)
    audio = np.zeros(total_samples, dtype=np.float32)

    ffmpeg_exe = imageio_ffmpeg.get_ffmpeg_exe()

    # 1. Overlay voiceover clips at designated start times
    voice_timeline = [
        (0.2, "clip1.mp3"),
        (5.8, "clip2.mp3"),
        (11.3, "clip3.mp3"),
        (18.6, "clip4.mp3"),
        (23.8, "clip5.mp3")
    ]

    for start_t, fname in voice_timeline:
        fpath = os.path.join(VOICE_DIR, fname)
        if not os.path.exists(fpath):
            continue
        # Convert mp3 to raw pcm via ffmpeg
        wav_tmp = f"/tmp/{fname}.wav"
        subprocess.run([ffmpeg_exe, "-y", "-i", fpath, "-ar", "44100", "-ac", "1", wav_tmp], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if os.path.exists(wav_tmp):
            with wave.open(wav_tmp, "r") as wf:
                data = wf.readframes(wf.getnframes())
                clip_audio = np.frombuffer(data, dtype=np.int16).astype(np.float32) / 32767.0
                idx = int(start_t * sample_rate)
                end_idx = min(idx + len(clip_audio), total_samples)
                audio[idx:end_idx] += clip_audio[:end_idx - idx] * 0.95

    # 2. Add in-game sound effects (swipe clicks, hint ping, victory chime)
    def add_swipe(t_sec):
        idx = int(t_sec * sample_rate)
        length = int(0.09 * sample_rate)
        t = np.linspace(0, 0.09, length, endpoint=False)
        freq = 460.0 - 260.0 * (t / 0.09)
        env = np.exp(-t * 45.0)
        tone = 0.28 * np.sin(2 * np.pi * freq * t) * env
        end_idx = min(idx + length, total_samples)
        audio[idx:end_idx] += tone[:end_idx - idx]

    def add_hint_ping(t_sec):
        idx = int(t_sec * sample_rate)
        length = int(0.40 * sample_rate)
        t = np.linspace(0, 0.40, length, endpoint=False)
        tone = 0.35 * np.sin(2 * np.pi * 880.0 * t) * np.exp(-t * 8.0)
        tone += 0.25 * np.sin(2 * np.pi * 1760.0 * t) * np.exp(-t * 12.0)
        end_idx = min(idx + length, total_samples)
        audio[idx:end_idx] += tone[:end_idx - idx]

    def add_chime(t_sec):
        idx = int(t_sec * sample_rate)
        length = int(3.5 * sample_rate)
        t = np.linspace(0, 3.5, length, endpoint=False)
        chord_freqs = [523.25, 659.25, 783.99, 1046.50]  # C Major
        tone = np.zeros(length, dtype=np.float32)
        for i, f in enumerate(chord_freqs):
            env = np.exp(-t * (0.9 + i * 0.3))
            tone += (0.28 / len(chord_freqs)) * np.sin(2 * np.pi * f * t) * env
            tone += (0.09 / len(chord_freqs)) * np.sin(2 * np.pi * (f * 2) * t) * (env ** 1.5)
        end_idx = min(idx + length, total_samples)
        audio[idx:end_idx] += tone[:end_idx - idx]

    # Swipe SFX events: 7 moves + hint ping + win
    sfx_events = [
        (6.0, "hint"),
        (11.4, "swipe"),
        (13.0, "swipe"),
        (14.6, "swipe"),
        (16.2, "swipe"),
        (18.6, "swipe"),
        (20.0, "swipe"),
        (21.6, "swipe"),
        (23.5, "win")
    ]

    for t, stype in sfx_events:
        if stype == "swipe":
            add_swipe(t)
        elif stype == "hint":
            add_hint_ping(t)
        elif stype == "win":
            add_chime(t)

    audio = np.clip(audio, -1.0, 1.0)
    audio_int16 = (audio * 32767).astype(np.int16)
    with wave.open(TEMP_WAV, "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        wf.writeframes(audio_int16.tobytes())

def draw_vector_gold_star(draw, cx, cy, r_outer, r_inner, fill_color, outline_color):
    points = []
    for i in range(10):
        r = r_outer if i % 2 == 0 else r_inner
        angle = -math.pi / 2 + i * (math.pi / 5)
        points.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    draw.polygon(points, fill=fill_color, outline=outline_color, width=3)

def render_frame(f_idx):
    t_sec = f_idx / FPS
    # Background: deep midnight navy matching phone screenshot #020617
    img = Image.new("RGBA", (WIDTH, HEIGHT), (2, 6, 23, 255))
    draw = ImageDraw.Draw(img)

    # 1. Android Top Status Bar (from screenshot: 5:07 AM, 4G, 58%)
    stat_y = 35
    draw.text((60, stat_y), "5:07 AM", font=FONT_STATUS, fill=(240, 245, 255, 230))
    # Right status icons
    stat_r_x = WIDTH - 260
    draw.text((stat_r_x, stat_y), "0.00 K/s  4G  58%", font=FONT_STATUS, fill=(240, 245, 255, 210))

    # 2. In-Game GameHeader (matching screenshot)
    hdr_y = 110
    # 'LEVEL 24' in cyan #38BDF8 + 4-grid icon
    draw.text((60, hdr_y), "LEVEL 24", font=FONT_LEVEL_TAG, fill=(56, 189, 248, 255))
    # 4-square grid icon
    gx = 188
    gy = hdr_y + 4
    for ro in [0, 8]:
        for co in [0, 8]:
            draw.rectangle([gx + co, gy + ro, gx + co + 6, gy + ro + 6], fill=(56, 189, 248, 255))

    # 'Toroidal Bypass' title
    draw.text((60, hdr_y + 38), "Toroidal Bypass", font=FONT_TITLE, fill=(255, 255, 255, 255))

    # Speaker icon
    snd_x = 550
    snd_y = hdr_y + 46
    draw.polygon([(snd_x, snd_y), (snd_x + 8, snd_y), (snd_x + 18, snd_y - 10), (snd_x + 18, snd_y + 18), (snd_x + 8, snd_y + 8), (snd_x, snd_y + 8)], fill=(148, 163, 184, 255))
    draw.arc([snd_x + 16, snd_y - 8, snd_x + 28, snd_y + 16], start=-45, end=45, fill=(148, 163, 184, 255), width=2)

    # Dynamic Moves Calculation
    # Moves timeline:
    # 0.0 - 11.4s: 0 moves
    # 11.4 - 13.0s: Move 1 (Row 2 right) -> 1
    # 13.0 - 14.6s: Move 2 (Col 2 up) -> 2
    # 14.6 - 16.2s: Move 3 (Col 3 down) -> 3
    # 16.2 - 18.6s: Move 4 (Row 2 right) -> 4
    # 18.6 - 20.0s: Move 5 (Col 0 up) -> 5
    # 20.0 - 21.6s: Move 6 (Col 2 up) -> 6
    # 21.6 - 31.5s: Move 7 (Col 2 up) -> 7 (SOLVED!)
    if t_sec < 11.4:
        cur_moves = 0
    elif t_sec < 13.0:
        cur_moves = 1
    elif t_sec < 14.6:
        cur_moves = 2
    elif t_sec < 16.2:
        cur_moves = 3
    elif t_sec < 18.6:
        cur_moves = 4
    elif t_sec < 20.0:
        cur_moves = 5
    elif t_sec < 21.6:
        cur_moves = 6
    else:
        cur_moves = 7

    # Moves Card (exact match from screenshot: rounded #1E293B with 'Moves: X / 7' and 'Limit: X / 9')
    card_x = WIDTH - 340
    card_y = hdr_y
    card_w = 280
    card_h = 115
    draw.rounded_rectangle([card_x, card_y, card_x + card_w, card_y + card_h], radius=22, fill=(30, 41, 59, 240), outline=(51, 65, 85, 200), width=2)
    # Line 1: 'Moves: ' + cur_moves + ' / 7'
    m_lbl = "Moves: "
    bb_ml = FONT_MOVES_LBL.getbbox(m_lbl)
    ml_w = bb_ml[2] - bb_ml[0]
    n_str = str(cur_moves)
    bb_ns = FONT_MOVES_NUM.getbbox(n_str)
    ns_w = bb_ns[2] - bb_ns[0]
    s_str = " / 7"
    bb_ss = FONT_MOVES_LBL.getbbox(s_str)
    ss_w = bb_ss[2] - bb_ss[0]

    tot_w = ml_w + ns_w + ss_w
    sx = card_x + (card_w - tot_w) // 2
    draw.text((sx, card_y + 18), m_lbl, font=FONT_MOVES_LBL, fill=(148, 163, 184, 255))
    draw.text((sx + ml_w, card_y + 14), n_str, font=FONT_MOVES_NUM, fill=(255, 255, 255, 255))
    draw.text((sx + ml_w + ns_w, card_y + 18), s_str, font=FONT_MOVES_LBL, fill=(148, 163, 184, 255))
    # Line 2: 'Limit: X / 9'
    lim_str = f"Limit: {cur_moves} / 9"
    bb_lim = FONT_STATUS.getbbox(lim_str)
    lim_w = bb_lim[2] - bb_lim[0]
    draw.text((card_x + (card_w - lim_w) // 2, card_y + 64), lim_str, font=FONT_STATUS, fill=(100, 116, 139, 255))

    # 3. Main 5x5 Board Layout with Radiant Neon Blue Aura & Double Neon Border
    grid_size = GRID_SIZE
    cell_gap = CELL_GAP
    cell_w = CELL_W
    grid_x0 = GRID_X0
    grid_y0 = GRID_Y0

    img = Image.alpha_composite(img, BOARD_AURA_LAYER)
    draw = ImageDraw.Draw(img)

    # Board Background & Borders (Matching Color(0xFF02071E), Color(0xFF1E60FF), Color(0xFF00E5FF))
    draw.rounded_rectangle(
        [BX0, BY0, BX1, BY1],
        radius=26,
        fill=(2, 7, 30, 255),
        outline=(30, 96, 255, 255),
        width=3
    )
    draw.rounded_rectangle(
        [BX0 + 3, BY0 + 3, BX1 - 3, BY1 - 3],
        radius=23,
        outline=(0, 229, 255, 140),
        width=1
    )

    # Piece position states
    # Initial:
    # Cyan Circle: (1, 3) -> target (2, 4)
    # Amber Diamond: (2, 0) -> target (0, 2)
    # Rose Square: (2, 1) -> target (4, 2)
    # Violet Triangle: (3, 0) -> target (2, 0)
    c_r, c_c = 1.0, 3.0
    a_r, a_c = 2.0, 0.0
    r_r, r_c = 2.0, 1.0
    v_r, v_c = 3.0, 0.0

    active_row = None
    active_col = None
    finger_pos = None

    def ease(p):
        return 0.5 - 0.5 * math.cos(p * math.pi)

    # Moves Timeline
    # Move 1 (t=11.4 to 12.6): Row 2 right by 1
    # Amber at (2,0) moves to (2,1), Rose at (2,1) moves to (2,2)
    if 11.4 <= t_sec < 12.6:
        active_row = 2
        p = ease(min(1.0, (t_sec - 11.4) / 0.8))
        a_c = 0.0 + p * 1.0
        r_c = 1.0 + p * 1.0
        finger_pos = (GRID_X0 + (0.5 + p) * (CELL_W + CELL_GAP), GRID_Y0 + 2 * (CELL_W + CELL_GAP) + CELL_W / 2)
    elif 12.6 <= t_sec:
        a_c = 1.0
        r_c = 2.0

    # Move 2 (t=13.0 to 14.2): Col 2 up by 1
    # Rose at (2,2) moves to (1,2)
    if 13.0 <= t_sec < 14.2:
        active_col = 2
        p = ease(min(1.0, (t_sec - 13.0) / 0.8))
        r_r = 2.0 - p * 1.0
        finger_pos = (GRID_X0 + 2 * (CELL_W + CELL_GAP) + CELL_W / 2, GRID_Y0 + (2.0 - p) * (CELL_W + CELL_GAP) + CELL_W / 2)
    elif 14.2 <= t_sec:
        r_r = 1.0

    # Move 3 (t=14.6 to 15.8): Col 3 down by 1
    # Cyan at (1,3) moves to (2,3)
    if 14.6 <= t_sec < 15.8:
        active_col = 3
        p = ease(min(1.0, (t_sec - 14.6) / 0.8))
        c_r = 1.0 + p * 1.0
        finger_pos = (GRID_X0 + 3 * (CELL_W + CELL_GAP) + CELL_W / 2, GRID_Y0 + (1.0 + p) * (CELL_W + CELL_GAP) + CELL_W / 2)
    elif 15.8 <= t_sec:
        c_r = 2.0

    # Move 4 (t=16.2 to 17.6): Row 2 right by 1
    # Cyan at (2,3) moves to (2,4) [TARGET!]
    # Amber at (2,1) moves to (2,2)
    if 16.2 <= t_sec < 17.6:
        active_row = 2
        p = ease(min(1.0, (t_sec - 16.2) / 0.8))
        c_c = 3.0 + p * 1.0
        a_c = 1.0 + p * 1.0
        finger_pos = (GRID_X0 + (3.0 + p) * (CELL_W + CELL_GAP), GRID_Y0 + 2 * (CELL_W + CELL_GAP) + CELL_W / 2)
    elif 17.6 <= t_sec:
        c_c = 4.0
        a_c = 2.0

    # Move 5 (t=18.6 to 19.6): Col 0 up by 1
    # Violet at (3,0) moves to (2,0) [TARGET!]
    if 18.6 <= t_sec < 19.6:
        active_col = 0
        p = ease(min(1.0, (t_sec - 18.6) / 0.7))
        v_r = 3.0 - p * 1.0
        finger_pos = (GRID_X0 + 0 * (CELL_W + CELL_GAP) + CELL_W / 2, GRID_Y0 + (3.0 - p) * (CELL_W + CELL_GAP) + CELL_W / 2)
    elif 19.6 <= t_sec:
        v_r = 2.0

    # Move 6 (t=20.0 to 21.0): Col 2 up by 1
    # Rose at (1,2) moves to (0,2); Amber at (2,2) moves to (1,2)
    if 20.0 <= t_sec < 21.0:
        active_col = 2
        p = ease(min(1.0, (t_sec - 20.0) / 0.7))
        r_r = 1.0 - p * 1.0
        a_r = 2.0 - p * 1.0
        finger_pos = (GRID_X0 + 2 * (CELL_W + CELL_GAP) + CELL_W / 2, GRID_Y0 + (1.5 - p) * (CELL_W + CELL_GAP) + CELL_W / 2)
    elif 21.0 <= t_sec:
        r_r = 0.0
        a_r = 1.0

    # Move 7 (t=21.6 to 22.8): Col 2 up by 1
    # Amber at (1,2) moves to (0,2) [TARGET!]
    # Rose at (0,2) wraps toroidally up to (4,2) [TARGET!]
    # ALL 4 PIECES IN TARGETS!
    if 21.6 <= t_sec < 22.8:
        active_col = 2
        p = ease(min(1.0, (t_sec - 21.6) / 0.8))
        a_r = 1.0 - p * 1.0
        r_r = 0.0 - p * 1.0
        finger_pos = (GRID_X0 + 2 * (CELL_W + CELL_GAP) + CELL_W / 2, GRID_Y0 + (1.0 - p) * (CELL_W + CELL_GAP) + CELL_W / 2)
    elif 22.8 <= t_sec:
        a_r = 0.0
        r_r = 4.0

    # Draw Laser Shift Beam Behind Active Row / Column
    if active_row is not None:
        ry = GRID_Y0 + active_row * (CELL_W + CELL_GAP)
        draw.rounded_rectangle([GRID_X0 - 14, ry - 5, GRID_X0 + GRID_SIZE + 14, ry + CELL_W + 5], radius=20, fill=(0, 229, 255, 45), outline=(0, 229, 255, 210), width=2)
        midY = ry + CELL_W / 2
        draw.line([GRID_X0, midY, GRID_X0 + GRID_SIZE, midY], fill=(0, 229, 255, 220), width=2)
    elif active_col is not None:
        cx = GRID_X0 + active_col * (CELL_W + CELL_GAP)
        draw.rounded_rectangle([cx - 5, GRID_Y0 - 14, cx + CELL_W + 5, GRID_Y0 + GRID_SIZE + 14], radius=20, fill=(0, 229, 255, 45), outline=(0, 229, 255, 210), width=2)
        midX = cx + CELL_W / 2
        draw.line([midX, GRID_Y0, midX, GRID_Y0 + GRID_SIZE], fill=(0, 229, 255, 220), width=2)

    # 4. Draw 5x5 Tactile 3D Luminous Sapphire Blue Pads & Targets (exact screenshot match)
    cell_radius = 24
    for r in range(5):
        for c in range(5):
            x = GRID_X0 + c * (CELL_W + CELL_GAP)
            y = GRID_Y0 + r * (CELL_W + CELL_GAP)
            is_active_cell = (active_row == r) or (active_col == c)

            if is_active_cell:
                # Active shifting pad (Elevated Electric Cyan #0091EA / #E0F7FA)
                draw.rounded_rectangle([x, y + 6, x + CELL_W, y + CELL_W + 6], radius=cell_radius, fill=(1, 10, 30, 255))
                draw.rounded_rectangle([x, y + 2, x + CELL_W, y + CELL_W + 4], radius=cell_radius, fill=(0, 91, 148, 255))
                draw.rounded_rectangle([x, y, x + CELL_W, y + CELL_W], radius=cell_radius, fill=(0, 145, 234, 255))
                draw.rounded_rectangle([x, y, x + CELL_W, y + CELL_W], radius=cell_radius, outline=(224, 247, 250, 255), width=2)
                draw.line([x + cell_radius * 0.7, y + 1.5, x + CELL_W - cell_radius * 0.7, y + 1.5], fill=(255, 255, 255, 240), width=2)
                draw.line([x + 1.5, y + cell_radius * 0.7, x + 1.5, y + CELL_W - cell_radius * 0.7], fill=(255, 255, 255, 240), width=2)
            else:
                # Tactile 3D Luminous Sapphire Blue Pad (App Icon Match #0C2A78 / #2E75FF)
                draw.rounded_rectangle([x, y + 5, x + CELL_W, y + CELL_W + 5], radius=cell_radius, fill=(3, 10, 32, 255))
                draw.rounded_rectangle([x, y + 2, x + CELL_W, y + CELL_W + 4], radius=cell_radius, fill=(8, 28, 80, 255))
                draw.rounded_rectangle([x, y, x + CELL_W, y + CELL_W], radius=cell_radius, fill=(18, 54, 136, 255))
                draw.rounded_rectangle([x + 3, y + 3, x + CELL_W - 3, y + CELL_W - 3], radius=cell_radius - 2, fill=(14, 45, 118, 255))
                draw.rounded_rectangle([x, y, x + CELL_W, y + CELL_W], radius=cell_radius, outline=(56, 130, 255, 255), width=2)
                draw.line([x + cell_radius * 0.7, y + 1.5, x + CELL_W - cell_radius * 0.7, y + 1.5], fill=(130, 195, 255, 230), width=2)
                draw.line([x + 1.5, y + cell_radius * 0.7, x + 1.5, y + CELL_W - cell_radius * 0.7], fill=(130, 195, 255, 230), width=2)
                draw.line([x + cell_radius * 0.7, y + CELL_W - 1.5, x + CELL_W - cell_radius * 0.7, y + CELL_W - 1.5], fill=(4, 14, 44, 255), width=2)
                draw.line([x + CELL_W - 1.5, y + cell_radius * 0.7, x + CELL_W - 1.5, y + CELL_W - cell_radius * 0.7], fill=(4, 14, 44, 255), width=2)

            # Target Rendering
            cx_c, cy_c = x + CELL_W / 2, y + CELL_W / 2
            pulse = 1.0 + 0.05 * math.sin(t_sec * 5.0)

            # (0, 2): Amber Target — concentric nested gold diamonds + glowing center dot
            if r == 0 and c == 2:
                sz1 = 34 * pulse
                sz2 = 22 * pulse
                draw.polygon([(cx_c, cy_c - sz1), (cx_c + sz1, cy_c), (cx_c, cy_c + sz1), (cx_c - sz1, cy_c)], outline=(245, 158, 11, 240), width=3)
                draw.polygon([(cx_c, cy_c - sz2), (cx_c + sz2, cy_c), (cx_c, cy_c + sz2), (cx_c - sz2, cy_c)], outline=(251, 191, 36, 200), width=2)
                draw.ellipse([cx_c - 4, cy_c - 4, cx_c + 4, cy_c + 4], fill=(255, 235, 150, 255))

            # (2, 0): Violet Target — violet triangle outline
            elif r == 2 and c == 0:
                sz = 34 * pulse
                poly = [(cx_c, cy_c - sz * 0.9), (cx_c + sz * 0.9, cy_c + sz * 0.7), (cx_c - sz * 0.9, cy_c + sz * 0.7)]
                draw.polygon(poly, outline=(192, 38, 211, 240), width=3)
                draw.ellipse([cx_c - 4, cy_c + 2, cx_c + 4, cy_c + 10], fill=(245, 190, 255, 255))

            # (2, 4): Cyan Target — concentric nested cyan rings + glowing center dot
            elif r == 2 and c == 4:
                r1 = 34 * pulse
                r2 = 22 * pulse
                draw.ellipse([cx_c - r1, cy_c - r1, cx_c + r1, cy_c + r1], outline=(56, 189, 248, 240), width=3)
                draw.ellipse([cx_c - r2, cy_c - r2, cx_c + r2, cy_c + r2], outline=(125, 211, 252, 200), width=2)
                draw.ellipse([cx_c - 4, cy_c - 4, cx_c + 4, cy_c + 4], fill=(224, 242, 254, 255))

            # (4, 2): Rose Target — concentric red rounded squares + glowing center dot
            elif r == 4 and c == 2:
                sz1 = 30 * pulse
                sz2 = 18 * pulse
                draw.rounded_rectangle([cx_c - sz1, cy_c - sz1, cx_c + sz1, cy_c + sz1], radius=10, outline=(244, 63, 94, 240), width=3)
                draw.rounded_rectangle([cx_c - sz2, cy_c - sz2, cx_c + sz2, cy_c + sz2], radius=6, outline=(251, 113, 133, 200), width=2)
                draw.ellipse([cx_c - 4, cy_c - 4, cx_c + 4, cy_c + 4], fill=(255, 220, 230, 255))

    # 5. Draw Game Pieces with Exact Visual Fidelity & Toroidal Wrap-Around
    def draw_piece(row_val, col_val, ptype):
        r_inst = [row_val]
        if row_val > 4.0: r_inst.append(row_val - 5.0)
        elif row_val < 0.0: r_inst.append(row_val + 5.0)

        c_inst = [col_val]
        if col_val > 4.0: c_inst.append(col_val - 5.0)
        elif col_val < 0.0: c_inst.append(col_val + 5.0)

        for rv in r_inst:
            for cv in c_inst:
                px = grid_x0 + cv * (cell_w + cell_gap)
                py = grid_y0 + rv * (cell_w + cell_gap)
                if px < grid_x0 - cell_w or px > grid_x0 + grid_size + cell_w: continue
                if py < grid_y0 - cell_w or py > grid_y0 + grid_size + cell_w: continue

                cx_p = px + cell_w / 2
                cy_p = py + cell_w / 2

                if ptype == "cyan":
                    # Cyan Sphere with specular bubble reflection (exact match to screenshot)
                    r_sphere = cell_w * 0.38
                    draw.ellipse([cx_p - r_sphere - 4, cy_p - r_sphere - 4, cx_p + r_sphere + 4, cy_p + r_sphere + 4], fill=(0, 229, 255, 40))
                    draw.ellipse([cx_p - r_sphere, cy_p - r_sphere, cx_p + r_sphere, cy_p + r_sphere], fill=(14, 165, 233, 255), outline=(56, 189, 248, 255), width=3)
                    # Specular bubble reflection highlight
                    bx, by = cx_p - r_sphere * 0.35, cy_p - r_sphere * 0.35
                    draw.ellipse([bx - 10, by - 10, bx + 10, by + 10], fill=(255, 255, 255, 240))

                elif ptype == "amber":
                    # Glowing Amber Diamond with 3D bevel split (exact match)
                    sz = cell_w * 0.40
                    poly = [(cx_p, cy_p - sz), (cx_p + sz, cy_p), (cx_p, cy_p + sz), (cx_p - sz, cy_p)]
                    draw.polygon(poly, fill=(245, 158, 11, 255), outline=(254, 240, 138, 240), width=3)
                    # Upper highlight triangle
                    draw.polygon([(cx_p, cy_p - sz), (cx_p + sz, cy_p), (cx_p - sz, cy_p)], fill=(251, 191, 36, 255))
                    draw.line([cx_p - sz, cy_p, cx_p + sz, cy_p], fill=(255, 255, 255, 180), width=2)

                elif ptype == "rose":
                    # Glossy Ruby Red Rounded Square with specular top pill (exact match)
                    sz = cell_w * 0.36
                    draw.rounded_rectangle([cx_p - sz, cy_p - sz, cx_p + sz, cy_p + sz], radius=16, fill=(225, 29, 72, 255), outline=(253, 164, 175, 240), width=3)
                    # Top glossy pill highlight
                    draw.rounded_rectangle([cx_p - sz + 6, cy_p - sz + 4, cx_p + sz - 6, cy_p - sz + 18], radius=6, fill=(255, 255, 255, 180))

                elif ptype == "violet":
                    # Vibrant Violet Triangle with inner white stroke (exact match)
                    sz = cell_w * 0.42
                    poly = [(cx_p, cy_p - sz * 0.85), (cx_p + sz * 0.88, cy_p + sz * 0.75), (cx_p - sz * 0.88, cy_p + sz * 0.75)]
                    draw.polygon(poly, fill=(192, 38, 211, 255), outline=(245, 208, 254, 255), width=3)
                    # Inner triangle
                    sz_in = sz * 0.6
                    poly_in = [(cx_p, cy_p - sz_in * 0.75), (cx_p + sz_in * 0.8, cy_p + sz_in * 0.75), (cx_p - sz_in * 0.8, cy_p + sz_in * 0.75)]
                    draw.polygon(poly_in, outline=(255, 255, 255, 220), width=2)

    # Draw all 4 pieces
    draw_piece(c_r, c_c, "cyan")
    draw_piece(a_r, a_c, "amber")
    draw_piece(r_r, r_c, "rose")
    draw_piece(v_r, v_c, "violet")

    # Animated finger indicator
    if finger_pos is not None:
        fx, fy = finger_pos
        draw.ellipse([fx - 24, fy - 24, fx + 24, fy + 24], fill=(255, 255, 255, 170), outline=(56, 189, 248, 255), width=3)

    # 6. Bottom GameControls (exact match from screenshot)
    ctrl_y = 1350
    # Left `<` arrow
    draw.polygon([(100, ctrl_y + 36), (112, ctrl_y + 24), (112, ctrl_y + 48)], fill=(148, 163, 184, 255))
    # Undo curved arrow
    draw.arc([190, ctrl_y + 20, 224, ctrl_y + 54], start=45, end=270, fill=(148, 163, 184, 255), width=3)
    draw.polygon([(186, ctrl_y + 36), (196, ctrl_y + 26), (196, ctrl_y + 44)], fill=(148, 163, 184, 255))

    # '💡 Need a hint?' button (amber glowing rounded pill)
    hint_btn_x = 285
    hint_btn_w = 260
    hint_btn_h = 74
    # Amber pulse if active (t=5.4 to 9.0)
    is_hint_active = (5.2 <= t_sec < 10.0)
    h_border_col = (251, 191, 36) if is_hint_active else (217, 119, 6)
    draw.rounded_rectangle([hint_btn_x, ctrl_y, hint_btn_x + hint_btn_w, ctrl_y + hint_btn_h], radius=24, fill=(35, 26, 15, 255), outline=h_border_col, width=2)
    # Lightbulb icon
    lb_cx, lb_cy = hint_btn_x + 36, ctrl_y + 37
    draw.ellipse([lb_cx - 10, lb_cy - 12, lb_cx + 10, lb_cy + 8], fill=(251, 191, 36, 255))
    draw.rectangle([lb_cx - 5, lb_cy + 6, lb_cx + 5, lb_cy + 13], fill=(217, 119, 6, 255))
    draw.text((hint_btn_x + 62, ctrl_y + 22), "Need a hint?", font=FONT_HINT_BTN, fill=(251, 191, 36, 255))

    # '⟳ Restart' button (dark rounded box)
    rst_btn_x = 575
    rst_btn_w = 250
    draw.rounded_rectangle([rst_btn_x, ctrl_y, rst_btn_x + rst_btn_w, ctrl_y + hint_btn_h], radius=24, fill=(30, 41, 59, 255), outline=(51, 65, 85, 200), width=2)
    # Circular restart arrow
    rcx, rcy = rst_btn_x + 40, ctrl_y + 37
    draw.arc([rcx - 14, rcy - 14, rcx + 14, rcy + 14], start=0, end=300, fill=(240, 245, 255, 230), width=3)
    draw.polygon([(rcx + 8, rcy - 16), (rcx + 18, rcy - 6), (rcx + 18, rcy - 24)], fill=(240, 245, 255, 230))
    draw.text((rst_btn_x + 72, ctrl_y + 22), "Restart", font=FONT_HINT_BTN, fill=(240, 245, 255, 240))

    # Right `>` arrow
    draw.polygon([(WIDTH - 112, ctrl_y + 36), (WIDTH - 124, ctrl_y + 24), (WIDTH - 124, ctrl_y + 48)], fill=(148, 163, 184, 255))

    # 7. Android Bottom Navigation Bar (|||  O  <)
    nav_y = 1860
    # Left three vertical bars |||
    draw.line([250, nav_y + 6, 250, nav_y + 26], fill=(148, 163, 184, 200), width=3)
    draw.line([258, nav_y + 6, 258, nav_y + 26], fill=(148, 163, 184, 200), width=3)
    draw.line([266, nav_y + 6, 266, nav_y + 26], fill=(148, 163, 184, 200), width=3)
    # Center circle O
    draw.ellipse([WIDTH // 2 - 14, nav_y + 4, WIDTH // 2 + 14, nav_y + 32], outline=(148, 163, 184, 200), width=3)
    # Right back arrow <
    draw.line([WIDTH - 250, nav_y + 6, WIDTH - 264, nav_y + 18], fill=(148, 163, 184, 200), width=3)
    draw.line([WIDTH - 264, nav_y + 18, WIDTH - 250, nav_y + 30], fill=(148, 163, 184, 200), width=3)

    # 8. Interactive Hint Overlay (appears when user taps 'Need a hint?' at t=5.8 to 10.5s)
    if 5.8 <= t_sec < 10.5:
        p_pop = min(1.0, (t_sec - 5.8) / 0.4)
        pop_w = int(820 * p_pop)
        pop_h = int(120 * p_pop)
        pop_x = (WIDTH - pop_w) // 2
        pop_y = 300
        draw.rounded_rectangle([pop_x, pop_y, pop_x + pop_w, pop_y + pop_h], radius=22, fill=(28, 20, 10, 245), outline=(245, 158, 11, 230), width=2)
        if p_pop > 0.8:
            draw.text((pop_x + 36, pop_y + 24), "💡 TOROIDAL BYPASS HINT:", font=FONT_STATUS, fill=(251, 191, 36, 255))
            draw.text((pop_x + 36, pop_y + 64), "Slingshot Amber around Row 2 to clear Violet's target!", font=FONT_HINT_POPUP, fill=(255, 255, 255, 255))

    # 9. Authentic WinDialog (from Screenshot 2) — drops in at t=23.4s
    if t_sec >= 23.4:
        pop_prog = min(1.0, (t_sec - 23.4) / 0.5)
        scale = 0.5 + 0.5 * math.sin(pop_prog * math.pi / 2)

        # Backdrop Dimming Overlay
        dim = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, int(195 * pop_prog)))
        img = Image.alpha_composite(img, dim)
        draw = ImageDraw.Draw(img)

        # Dialog Box Dimensions (matching Screenshot 2: dark slate #0F172A, rounded border #38BDF8)
        dw = int(800 * scale)
        dh = int(760 * scale)
        dx0 = (WIDTH - dw) // 2
        dy0 = (HEIGHT - dh) // 2

        # Outer subtle cyan glow
        for gr in range(30, 0, -6):
            draw.rounded_rectangle([dx0 - gr, dy0 - gr, dx0 + dw + gr, dy0 + dh + gr], radius=32, fill=(56, 189, 248, int(8 * (1.0 - gr / 30))))

        # Dialog Card
        draw.rounded_rectangle([dx0, dy0, dx0 + dw, dy0 + dh], radius=30, fill=(15, 23, 42, 255), outline=(56, 189, 248, 200), width=3)

        if scale > 0.85:
            # Circular Blue Badge with Checkmark (exact match to Screenshot 2)
            badge_r = 46
            bcx, bcy = WIDTH // 2, dy0 + 95
            draw.ellipse([bcx - badge_r, bcy - badge_r, bcx + badge_r, bcy + badge_r], fill=(30, 58, 95, 255), outline=(56, 189, 248, 240), width=3)
            # Checkmark ✓ in Cyan
            draw.line([bcx - 18, bcy + 2, bcx - 6, bcy + 16], fill=(56, 189, 248, 255), width=5)
            draw.line([bcx - 6, bcy + 16, bcx + 18, bcy - 14], fill=(56, 189, 248, 255), width=5)

            # 'LEVEL COMPLETE' text (bold white, letterSpacing 2.0)
            lc_text = "LEVEL COMPLETE"
            bb_lc = FONT_WIN_TITLE.getbbox(lc_text)
            draw.text(((WIDTH - (bb_lc[2] - bb_lc[0])) // 2, dy0 + 175), lc_text, font=FONT_WIN_TITLE, fill=(255, 255, 255, 255))

            # 3 Large 5-Pointed Rounded Gold Stars (exact match from Screenshot 2, but 3 Stars!)
            star_base_y = dy0 + 280
            star_centers = [WIDTH // 2 - 110, WIDTH // 2, WIDTH // 2 + 110]
            star_times = [23.9, 24.3, 24.7]

            for s_idx in range(3):
                scx = star_centers[s_idx]
                s_t = star_times[s_idx]
                if t_sec >= s_t:
                    sp = min(1.0, (t_sec - s_t) / 0.3)
                    bounce = 1.0 + 0.32 * math.sin(sp * math.pi)
                    r_out = int(42 * bounce)
                    r_in = int(r_out * 0.48)
                    draw_vector_gold_star(
                        draw, scx, star_base_y, r_out, r_in,
                        fill_color=(251, 191, 36, 255),
                        outline_color=(254, 240, 138, 255)
                    )
                else:
                    # Empty slate star outline
                    r_out = 42
                    r_in = int(r_out * 0.48)
                    draw_vector_gold_star(
                        draw, scx, star_base_y, r_out, r_in,
                        fill_color=(20, 30, 52, 255),
                        outline_color=(51, 65, 85, 255)
                    )

            # 'PERFECT!' rating label (exact match in Cyan/Gold)
            r_text = "PERFECT!"
            bb_r = FONT_WIN_RATING.getbbox(r_text)
            draw.text(((WIDTH - (bb_r[2] - bb_r[0])) // 2, dy0 + 355), r_text, font=FONT_WIN_RATING, fill=(56, 189, 248, 255))

            # Move Stats: 'Moves: 7'
            m_stat = "Moves: 7"
            bb_ms = FONT_WIN_STAT.getbbox(m_stat)
            draw.text(((WIDTH - (bb_ms[2] - bb_ms[0])) // 2, dy0 + 410), m_stat, font=FONT_WIN_STAT, fill=(255, 255, 255, 255))

            # 'Optimal: 7 moves'
            opt_stat = "Optimal: 7 moves"
            bb_os = FONT_WIN_OPT.getbbox(opt_stat)
            draw.text(((WIDTH - (bb_os[2] - bb_os[0])) // 2, dy0 + 456), opt_stat, font=FONT_WIN_OPT, fill=(148, 163, 184, 255))

            # Buttons Row: [ Replay ]  [ Next Level ] (exact match from Screenshot 2)
            btn_w = 260
            btn_h = 80
            btn_y = dy0 + 520
            # Left: Replay Button (#1E293B, rounded 20)
            draw.rounded_rectangle([dx0 + 80, btn_y, dx0 + 80 + btn_w, btn_y + btn_h], radius=22, fill=(30, 41, 59, 255), outline=(51, 65, 85, 255), width=2)
            draw.text((dx0 + 80 + 85, btn_y + 24), "Replay", font=FONT_WIN_BTN, fill=(255, 255, 255, 255))

            # Right: Next Level Button (Glowing Cyan #38BDF8, rounded 20, black text)
            nl_x = dx0 + 80 + btn_w + 50
            # Glow
            for bgr in range(16, 0, -4):
                draw.rounded_rectangle([nl_x - bgr, btn_y - bgr, nl_x + btn_w + bgr, btn_y + btn_h + bgr], radius=24, fill=(56, 189, 248, int(15 * (1.0 - bgr / 16))))
            draw.rounded_rectangle([nl_x, btn_y, nl_x + btn_w, btn_y + btn_h], radius=22, fill=(56, 189, 248, 255))
            draw.text((nl_x + 55, btn_y + 24), "Next Level", font=FONT_WIN_BTN, fill=(2, 6, 23, 255))

            # Call to Action Link
            cta_txt = "Free Standalone APK • shiftpuzzle.app • Link in Bio 📲"
            bb_c = FONT_STATUS.getbbox(cta_txt)
            draw.text(((WIDTH - (bb_c[2] - bb_c[0])) // 2, dy0 + 665), cta_txt, font=FONT_STATUS, fill=(56, 189, 248, 255))

    return img.convert("RGB")

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    ffmpeg_exe = imageio_ffmpeg.get_ffmpeg_exe()
    duration_sec = TOTAL_FRAMES / FPS
    print(f"Generating Level 24 'Toroidal Bypass' authentic TikTok video ({TOTAL_FRAMES} frames, {duration_sec:.1f}s at {FPS} FPS)...")

    # Combine audio: voiceover + sound effects
    print("Synthesizing audio: neural voiceover + tactile swipes + hint ping + victory chime...")
    generate_audio(duration_sec)

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
    print("Video frames encoded. Merging video with neural voiceover and audio...")

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
