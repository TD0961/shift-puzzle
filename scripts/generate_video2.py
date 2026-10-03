#!/usr/bin/env python3
"""
Generate second viral, highly-engaging YouTube Short / TikTok video:
Level 35 ("Interlock") — Concept: "The Rules Have Changed"
- Showcases the signature 5x5 toroidal sliding mechanic and multi-axis interlocking logic
- Humanised, conversational neural voiceover (Christopher)
- High-impact neon cyber-glass aesthetic matching in-game shaders:
  * Radiant electric blue board halo
  * 3D tactile luminous sapphire blue pads with glowing electric blue rims
  * Shifting laser tracks with kinetic center beams
- Cyan Circle, Emerald Hexagon, and Violet Triangle pieces & targets
- High-contrast dynamic on-screen typography / modern viral subtitles
- Exact 6-move optimal solution achieving a flawless 3-star par
- Authentic WinDialog with 3 bouncing gold stars and clear Android download CTA
"""

import math
import os
import subprocess
import wave
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import imageio_ffmpeg

OUTPUT_DIR = "assets/branding/social"
OUTPUT_VIDEO = os.path.join(OUTPUT_DIR, "youtube_short_interlock.mp4")
TEMP_WAV = "/tmp/video2_audio.wav"
VOICE_DIR = "/tmp/video2_voice_clips"

WIDTH, HEIGHT = 1080, 1920
FPS = 30
TOTAL_FRAMES = 1035  # 34.5 seconds

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
    aura_draw.rounded_rectangle(
        [BX0 - 15, BY0 - 15, BX1 + 15, BY1 + 15],
        radius=36,
        fill=(0, 102, 255, 160),
        outline=(0, 229, 255, 220),
        width=8
    )
    aura_blur = aura_img.filter(ImageFilter.GaussianBlur(28))

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
FONT_SUBTITLE = get_font(30, bold=True)
FONT_SUBTITLE_HIGHLIGHT = get_font(32, bold=True)
FONT_HERO_TAG = get_font(22, bold=True)
FONT_HERO_TITLE = get_font(54, bold=True)
FONT_HERO_SUB = get_font(26, bold=False)
FONT_HERO_PILL = get_font(26, bold=True)
FONT_HERO_BTN = get_font(32, bold=True)
FONT_HERO_BTN_SUB = get_font(22, bold=False)
FONT_HERO_CTA = get_font(28, bold=True)

def load_app_icon():
    icon_path = "assets/branding/app_icon/shift_puzzle_icon_512.png"
    if os.path.exists(icon_path):
        icon = Image.open(icon_path).convert("RGBA")
        icon = icon.resize((220, 220), Image.Resampling.LANCZOS)
        mask = Image.new("L", (220, 220), 0)
        md = ImageDraw.Draw(mask)
        md.rounded_rectangle([0, 0, 220, 220], radius=50, fill=255)
        icon.putalpha(mask)
        return icon
    return None

APP_ICON_220 = load_app_icon()

def create_icon_aura():
    aura = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    ad = ImageDraw.Draw(aura)
    cx, cy = WIDTH // 2, 540
    ad.rounded_rectangle(
        [cx - 125, cy - 125, cx + 125, cy + 125],
        radius=58,
        fill=(0, 102, 255, 150),
        outline=(0, 229, 255, 240),
        width=6
    )
    return aura.filter(ImageFilter.GaussianBlur(30))

ICON_AURA_LAYER = create_icon_aura()

# Generate synchronized audio: voiceover + tactile swipes + lock chimes + victory chord
def generate_audio(duration_sec):
    sample_rate = 44100
    total_samples = int(sample_rate * duration_sec)
    audio = np.zeros(total_samples, dtype=np.float32)

    ffmpeg_exe = imageio_ffmpeg.get_ffmpeg_exe()

    # Voiceover clips timeline
    voice_timeline = [
        (0.2, "clip1.mp3"),
        (6.0, "clip2.mp3"),
        (11.0, "clip3.mp3"),
        (17.5, "clip4.mp3"),
        (22.4, "clip5.mp3"),
        (27.1, "clip6.mp3")
    ]

    for start_t, fname in voice_timeline:
        fpath = os.path.join(VOICE_DIR, fname)
        if not os.path.exists(fpath):
            continue
        wav_tmp = f"/tmp/v2_{fname}.wav"
        subprocess.run([ffmpeg_exe, "-y", "-i", fpath, "-ar", "44100", "-ac", "1", wav_tmp], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if os.path.exists(wav_tmp):
            with wave.open(wav_tmp, "r") as wf:
                data = wf.readframes(wf.getnframes())
                clip_audio = np.frombuffer(data, dtype=np.int16).astype(np.float32) / 32767.0
                idx = int(start_t * sample_rate)
                end_idx = min(idx + len(clip_audio), total_samples)
                audio[idx:end_idx] += clip_audio[:end_idx - idx] * 0.95

    # Sound effects
    def add_swipe(t_sec):
        idx = int(t_sec * sample_rate)
        length = int(0.09 * sample_rate)
        t = np.linspace(0, 0.09, length, endpoint=False)
        freq = 460.0 - 260.0 * (t / 0.09)
        env = np.exp(-t * 45.0)
        tone = 0.28 * np.sin(2 * np.pi * freq * t) * env
        end_idx = min(idx + length, total_samples)
        audio[idx:end_idx] += tone[:end_idx - idx]

    def add_lock(t_sec, freq=880.0):
        idx = int(t_sec * sample_rate)
        length = int(0.35 * sample_rate)
        t = np.linspace(0, 0.35, length, endpoint=False)
        tone = 0.32 * np.sin(2 * np.pi * freq * t) * np.exp(-t * 10.0)
        tone += 0.20 * np.sin(2 * np.pi * (freq * 1.5) * t) * np.exp(-t * 14.0)
        end_idx = min(idx + length, total_samples)
        audio[idx:end_idx] += tone[:end_idx - idx]

    def add_win_chord(t_sec):
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

    # SFX Events: 6 moves + locks + win chord
    sfx_events = [
        (8.5, "swipe"),
        (11.8, "swipe"),
        (13.8, "swipe"),
        (14.8, "lock"),  # Cyan locks in
        (17.8, "swipe"),
        (19.3, "swipe"),
        (20.2, "lock"),  # Emerald locks in
        (20.8, "swipe"),
        (21.8, "lock"),      # Violet locks in
        (22.4, "win"),       # Victory chord
        (26.8, "end_card")   # Hero End Card reveal shimmer
    ]

    def add_end_card_chime(t_sec):
        idx = int(t_sec * sample_rate)
        length = int(1.2 * sample_rate)
        t = np.linspace(0, 1.2, length, endpoint=False)
        tones = [587.33, 880.00, 1174.66, 1760.00]
        tone = np.zeros(length, dtype=np.float32)
        for i, f in enumerate(tones):
            env = np.exp(-t * (1.8 + i * 0.4))
            tone += (0.16 / len(tones)) * np.sin(2 * np.pi * f * t) * env
        end_idx = min(idx + length, total_samples)
        audio[idx:end_idx] += tone[:end_idx - idx]

    for t, stype in sfx_events:
        if stype == "swipe":
            add_swipe(t)
        elif stype == "lock":
            add_lock(t, 987.77)
        elif stype == "win":
            add_win_chord(t)
        elif stype == "end_card":
            add_end_card_chime(t)

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
    # Background: pure midnight navy matching real smartphone display (#020617)
    img = Image.new("RGBA", (WIDTH, HEIGHT), (2, 6, 23, 255))
    draw = ImageDraw.Draw(img)

    # 1. Android Top Status Bar (5:07 AM, 4G, 58%)
    stat_y = 35
    draw.text((60, stat_y), "5:07 AM", font=FONT_STATUS, fill=(240, 245, 255, 230))
    stat_r_x = WIDTH - 260
    draw.text((stat_r_x, stat_y), "0.00 K/s  4G  58%", font=FONT_STATUS, fill=(240, 245, 255, 210))

    # 2. In-Game GameHeader: 'LEVEL 35 ☷' & 'Interlock'
    hdr_y = 110
    draw.text((60, hdr_y), "LEVEL 35", font=FONT_LEVEL_TAG, fill=(56, 189, 248, 255))
    # 4-square grid icon
    gx = 188
    gy = hdr_y + 4
    for ro in [0, 8]:
        for co in [0, 8]:
            draw.rectangle([gx + co, gy + ro, gx + co + 6, gy + ro + 6], fill=(56, 189, 248, 255))

    draw.text((60, hdr_y + 38), "Interlock", font=FONT_TITLE, fill=(255, 255, 255, 255))

    # Speaker icon
    snd_x = 440
    snd_y = hdr_y + 46
    draw.polygon([(snd_x, snd_y), (snd_x + 8, snd_y), (snd_x + 18, snd_y - 10), (snd_x + 18, snd_y + 18), (snd_x + 8, snd_y + 8), (snd_x, snd_y + 8)], fill=(148, 163, 184, 255))
    draw.arc([snd_x + 16, snd_y - 8, snd_x + 28, snd_y + 16], start=-45, end=45, fill=(148, 163, 184, 255), width=2)

    # Dynamic Moves Calculation:
    # 0.0 - 8.5s: 0 moves
    # 8.5 - 11.8s: Move 1 (Row 1 left) -> 1
    # 11.8 - 13.8s: Move 2 (Col 1 up) -> 2
    # 13.8 - 17.8s: Move 3 (Col 1 up) -> 3
    # 17.8 - 19.3s: Move 4 (Col 2 down) -> 4
    # 19.3 - 20.8s: Move 5 (Col 2 down) -> 5
    # 20.8 - 34.5s: Move 6 (Row 1 left) -> 6 (SOLVED!)
    if t_sec < 8.5:
        cur_moves = 0
    elif t_sec < 11.8:
        cur_moves = 1
    elif t_sec < 13.8:
        cur_moves = 2
    elif t_sec < 17.8:
        cur_moves = 3
    elif t_sec < 19.3:
        cur_moves = 4
    elif t_sec < 20.8:
        cur_moves = 5
    else:
        cur_moves = 6

    # Moves Card (exact match from screenshot)
    card_x = WIDTH - 340
    card_y = hdr_y
    card_w = 280
    card_h = 115
    draw.rounded_rectangle([card_x, card_y, card_x + card_w, card_y + card_h], radius=22, fill=(30, 41, 59, 240), outline=(51, 65, 85, 200), width=2)
    m_lbl = "Moves: "
    bb_ml = FONT_MOVES_LBL.getbbox(m_lbl)
    ml_w = bb_ml[2] - bb_ml[0]
    n_str = str(cur_moves)
    bb_ns = FONT_MOVES_NUM.getbbox(n_str)
    ns_w = bb_ns[2] - bb_ns[0]
    s_str = " / 6"
    bb_ss = FONT_MOVES_LBL.getbbox(s_str)
    ss_w = bb_ss[2] - bb_ss[0]

    tot_w = ml_w + ns_w + ss_w
    sx = card_x + (card_w - tot_w) // 2
    draw.text((sx, card_y + 18), m_lbl, font=FONT_MOVES_LBL, fill=(148, 163, 184, 255))
    draw.text((sx + ml_w, card_y + 14), n_str, font=FONT_MOVES_NUM, fill=(255, 255, 255, 255))
    draw.text((sx + ml_w + ns_w, card_y + 18), s_str, font=FONT_MOVES_LBL, fill=(148, 163, 184, 255))
    lim_str = f"Limit: {cur_moves} / 8"
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

    # Initial Piece Positions for Level 35 Interlock:
    # Cyan Circle: at (4, 1) -> Target (2, 1)
    # Emerald Hexagon: at (0, 2) -> Target (2, 2)
    # Violet Triangle: at (1, 4) -> Target (1, 2)
    c_r, c_c = 4.0, 1.0
    e_r, e_c = 0.0, 2.0
    v_r, v_c = 1.0, 4.0

    active_row = None
    active_col = None
    finger_pos = None

    def ease(p):
        return 0.5 - 0.5 * math.cos(p * math.pi)

    # Move 1 (t = 8.5 to 9.8s): Row 1 left by 1
    # Violet at (1, 4) moves left to (1, 3)
    if 8.5 <= t_sec < 9.8:
        active_row = 1
        p = ease(min(1.0, (t_sec - 8.5) / 0.8))
        v_c = 4.0 - p * 1.0
        finger_pos = (GRID_X0 + (4.0 - p) * (CELL_W + CELL_GAP) + CELL_W / 2, GRID_Y0 + 1 * (CELL_W + CELL_GAP) + CELL_W / 2)
    elif 9.8 <= t_sec:
        v_c = 3.0

    # Move 2 (t = 11.8 to 13.0s): Col 1 up by 1
    # Cyan at (4, 1) moves up to (3, 1)
    if 11.8 <= t_sec < 13.0:
        active_col = 1
        p = ease(min(1.0, (t_sec - 11.8) / 0.8))
        c_r = 4.0 - p * 1.0
        finger_pos = (GRID_X0 + 1 * (CELL_W + CELL_GAP) + CELL_W / 2, GRID_Y0 + (4.0 - p) * (CELL_W + CELL_GAP) + CELL_W / 2)
    elif 13.0 <= t_sec:
        c_r = 3.0

    # Move 3 (t = 13.8 to 15.0s): Col 1 up by 1
    # Cyan at (3, 1) moves up to (2, 1) [LOCKED!]
    if 13.8 <= t_sec < 15.0:
        active_col = 1
        p = ease(min(1.0, (t_sec - 13.8) / 0.8))
        c_r = 3.0 - p * 1.0
        finger_pos = (GRID_X0 + 1 * (CELL_W + CELL_GAP) + CELL_W / 2, GRID_Y0 + (3.0 - p) * (CELL_W + CELL_GAP) + CELL_W / 2)
    elif 15.0 <= t_sec:
        c_r = 2.0

    # Move 4 (t = 17.8 to 18.9s): Col 2 down by 1
    # Emerald at (0, 2) moves down to (1, 2)
    if 17.8 <= t_sec < 18.9:
        active_col = 2
        p = ease(min(1.0, (t_sec - 17.8) / 0.7))
        e_r = 0.0 + p * 1.0
        finger_pos = (GRID_X0 + 2 * (CELL_W + CELL_GAP) + CELL_W / 2, GRID_Y0 + (0.0 + p) * (CELL_W + CELL_GAP) + CELL_W / 2)
    elif 18.9 <= t_sec:
        e_r = 1.0

    # Move 5 (t = 19.3 to 20.4s): Col 2 down by 1
    # Emerald at (1, 2) moves down to (2, 2) [LOCKED!]
    if 19.3 <= t_sec < 20.4:
        active_col = 2
        p = ease(min(1.0, (t_sec - 19.3) / 0.7))
        e_r = 1.0 + p * 1.0
        finger_pos = (GRID_X0 + 2 * (CELL_W + CELL_GAP) + CELL_W / 2, GRID_Y0 + (1.0 + p) * (CELL_W + CELL_GAP) + CELL_W / 2)
    elif 20.4 <= t_sec:
        e_r = 2.0

    # Move 6 (t = 20.8 to 22.0s): Row 1 left by 1
    # Violet at (1, 3) snaps left to (1, 2) [ALL 3 LOCKED!]
    if 20.8 <= t_sec < 22.0:
        active_row = 1
        p = ease(min(1.0, (t_sec - 20.8) / 0.7))
        v_c = 3.0 - p * 1.0
        finger_pos = (GRID_X0 + (3.0 - p) * (CELL_W + CELL_GAP) + CELL_W / 2, GRID_Y0 + 1 * (CELL_W + CELL_GAP) + CELL_W / 2)
    elif 22.0 <= t_sec:
        v_c = 2.0

    # Laser Shift Beam Behind Active Row / Column
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

    # 4. Draw 5x5 Tactile 3D Luminous Sapphire Blue Pads & Targets
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

            # Target Rendering for Level 35 Interlock:
            cx_c, cy_c = x + CELL_W / 2, y + CELL_W / 2
            pulse = 1.0 + 0.05 * math.sin(t_sec * 5.0)

            # (2, 1): Cyan Target — concentric nested cyan rings + glowing center dot
            if r == 2 and c == 1:
                r1 = 34 * pulse
                r2 = 22 * pulse
                draw.ellipse([cx_c - r1, cy_c - r1, cx_c + r1, cy_c + r1], outline=(56, 189, 248, 240), width=3)
                draw.ellipse([cx_c - r2, cy_c - r2, cx_c + r2, cy_c + r2], outline=(125, 211, 252, 200), width=2)
                draw.ellipse([cx_c - 4, cy_c - 4, cx_c + 4, cy_c + 4], fill=(224, 242, 254, 255))

            # (2, 2): Emerald Hexagon Target — concentric green hexagons + center dot
            elif r == 2 and c == 2:
                r_hex = 36 * pulse
                poly_hex = []
                for i in range(6):
                    ang = (i * 60 - 30) * math.pi / 180
                    poly_hex.append((cx_c + r_hex * math.cos(ang), cy_c + r_hex * math.sin(ang)))
                draw.polygon(poly_hex, outline=(0, 230, 118, 240), width=3)
                poly_in = []
                r_in = 22 * pulse
                for i in range(6):
                    ang = (i * 60 - 30) * math.pi / 180
                    poly_in.append((cx_c + r_in * math.cos(ang), cy_c + r_in * math.sin(ang)))
                draw.polygon(poly_in, outline=(185, 246, 202, 200), width=2)
                draw.ellipse([cx_c - 4, cy_c - 4, cx_c + 4, cy_c + 4], fill=(232, 245, 233, 255))

            # (1, 2): Violet Target — violet triangle outline + center dot
            elif r == 1 and c == 2:
                sz = 34 * pulse
                poly = [(cx_c, cy_c - sz * 0.9), (cx_c + sz * 0.9, cy_c + sz * 0.7), (cx_c - sz * 0.9, cy_c + sz * 0.7)]
                draw.polygon(poly, outline=(192, 38, 211, 240), width=3)
                draw.ellipse([cx_c - 4, cy_c + 2, cx_c + 4, cy_c + 10], fill=(245, 190, 255, 255))

    # 5. Draw Game Pieces with Exact Visual Parity & Toroidal Wrap-Around
    def draw_piece(row_val, col_val, ptype):
        r_inst = [row_val]
        if row_val > 4.0: r_inst.append(row_val - 5.0)
        elif row_val < 0.0: r_inst.append(row_val + 5.0)

        c_inst = [col_val]
        if col_val > 4.0: c_inst.append(col_val - 5.0)
        elif col_val < 0.0: c_inst.append(col_val + 5.0)

        for rv in r_inst:
            for cv in c_inst:
                px = GRID_X0 + cv * (CELL_W + CELL_GAP)
                py = GRID_Y0 + rv * (CELL_W + CELL_GAP)
                if px < GRID_X0 - CELL_W or px > GRID_X0 + GRID_SIZE + CELL_W: continue
                if py < GRID_Y0 - CELL_W or py > GRID_Y0 + GRID_SIZE + CELL_W: continue

                cx_p = px + CELL_W / 2
                cy_p = py + CELL_W / 2

                if ptype == "cyan":
                    r_sphere = CELL_W * 0.38
                    draw.ellipse([cx_p - r_sphere - 4, cy_p - r_sphere - 4, cx_p + r_sphere + 4, cy_p + r_sphere + 4], fill=(0, 229, 255, 40))
                    draw.ellipse([cx_p - r_sphere, cy_p - r_sphere, cx_p + r_sphere, cy_p + r_sphere], fill=(14, 165, 233, 255), outline=(56, 189, 248, 255), width=3)
                    bx, by = cx_p - r_sphere * 0.35, cy_p - r_sphere * 0.35
                    draw.ellipse([bx - 10, by - 10, bx + 10, by + 10], fill=(255, 255, 255, 240))

                elif ptype == "emerald":
                    r_hex = CELL_W * 0.40
                    poly_hex = []
                    for i in range(6):
                        ang = (i * 60 - 30) * math.pi / 180
                        poly_hex.append((cx_p + r_hex * math.cos(ang), cy_p + r_hex * math.sin(ang)))
                    draw.polygon(poly_hex, fill=(0, 230, 118, 255), outline=(185, 246, 202, 255), width=3)
                    poly_in = []
                    r_in = r_hex * 0.55
                    for i in range(6):
                        ang = (i * 60 - 30) * math.pi / 180
                        poly_in.append((cx_p + r_in * math.cos(ang), cy_p + r_in * math.sin(ang)))
                    draw.polygon(poly_in, outline=(255, 255, 255, 220), width=2)
                    draw.ellipse([cx_p - 5, cy_p - 5, cx_p + 5, cy_p + 5], fill=(255, 255, 255, 240))

                elif ptype == "violet":
                    sz = CELL_W * 0.42
                    poly = [(cx_p, cy_p - sz * 0.85), (cx_p + sz * 0.88, cy_p + sz * 0.75), (cx_p - sz * 0.88, cy_p + sz * 0.75)]
                    draw.polygon(poly, fill=(192, 38, 211, 255), outline=(245, 208, 254, 255), width=3)
                    sz_in = sz * 0.6
                    poly_in = [(cx_p, cy_p - sz_in * 0.75), (cx_p + sz_in * 0.8, cy_p + sz_in * 0.75), (cx_p - sz_in * 0.8, cy_p + sz_in * 0.75)]
                    draw.polygon(poly_in, outline=(255, 255, 255, 220), width=2)

    # Draw all 3 pieces
    draw_piece(c_r, c_c, "cyan")
    draw_piece(e_r, e_c, "emerald")
    draw_piece(v_r, v_c, "violet")

    # Animated tactile finger indicator during touch moves
    if finger_pos is not None:
        fx, fy = finger_pos
        ripple_r = 30 + int(10 * math.sin(t_sec * 14.0))
        draw.ellipse([fx - ripple_r, fy - ripple_r, fx + ripple_r, fy + ripple_r], outline=(56, 189, 248, 140), width=2)
        draw.ellipse([fx - 22, fy - 22, fx + 22, fy + 22], fill=(255, 255, 255, 130), outline=(0, 229, 255, 230), width=2)
        draw.ellipse([fx - 7, fy - 7, fx + 7, fy + 7], fill=(255, 255, 255, 250), outline=(255, 255, 255, 255), width=1)

    # 6. Bottom GameControls
    ctrl_y = 1350
    draw.polygon([(100, ctrl_y + 36), (112, ctrl_y + 24), (112, ctrl_y + 48)], fill=(148, 163, 184, 255))
    draw.arc([190, ctrl_y + 20, 224, ctrl_y + 54], start=45, end=270, fill=(148, 163, 184, 255), width=3)
    draw.polygon([(186, ctrl_y + 36), (196, ctrl_y + 26), (196, ctrl_y + 44)], fill=(148, 163, 184, 255))

    hint_btn_x = 285
    hint_btn_w = 260
    hint_btn_h = 74
    draw.rounded_rectangle([hint_btn_x, ctrl_y, hint_btn_x + hint_btn_w, ctrl_y + hint_btn_h], radius=24, fill=(35, 26, 15, 255), outline=(217, 119, 6), width=2)
    lb_cx, lb_cy = hint_btn_x + 36, ctrl_y + 37
    draw.ellipse([lb_cx - 10, lb_cy - 12, lb_cx + 10, lb_cy + 8], fill=(251, 191, 36, 255))
    draw.rectangle([lb_cx - 5, lb_cy + 6, lb_cx + 5, lb_cy + 13], fill=(217, 119, 6, 255))
    draw.text((hint_btn_x + 62, ctrl_y + 22), "Need a hint?", font=FONT_HINT_BTN, fill=(251, 191, 36, 255))

    rst_btn_x = 575
    rst_btn_w = 250
    draw.rounded_rectangle([rst_btn_x, ctrl_y, rst_btn_x + rst_btn_w, ctrl_y + hint_btn_h], radius=24, fill=(30, 41, 59, 255), outline=(51, 65, 85, 200), width=2)
    rcx, rcy = rst_btn_x + 40, ctrl_y + 37
    draw.arc([rcx - 14, rcy - 14, rcx + 14, rcy + 14], start=0, end=300, fill=(240, 245, 255, 230), width=3)
    draw.polygon([(rcx + 8, rcy - 16), (rcx + 18, rcy - 6), (rcx + 18, rcy - 24)], fill=(240, 245, 255, 230))
    draw.text((rst_btn_x + 72, ctrl_y + 22), "Restart", font=FONT_HINT_BTN, fill=(240, 245, 255, 240))

    draw.polygon([(WIDTH - 112, ctrl_y + 36), (WIDTH - 124, ctrl_y + 24), (WIDTH - 124, ctrl_y + 48)], fill=(148, 163, 184, 255))

    # 7. Android Bottom Navigation Bar (|||  O  <)
    nav_y = 1860
    draw.line([250, nav_y + 6, 250, nav_y + 26], fill=(148, 163, 184, 200), width=3)
    draw.line([258, nav_y + 6, 258, nav_y + 26], fill=(148, 163, 184, 200), width=3)
    draw.line([266, nav_y + 6, 266, nav_y + 26], fill=(148, 163, 184, 200), width=3)
    draw.ellipse([WIDTH // 2 - 14, nav_y + 4, WIDTH // 2 + 14, nav_y + 32], outline=(148, 163, 184, 200), width=3)
    draw.line([WIDTH - 250, nav_y + 6, WIDTH - 264, nav_y + 18], fill=(148, 163, 184, 200), width=3)
    draw.line([WIDTH - 264, nav_y + 18, WIDTH - 250, nav_y + 30], fill=(148, 163, 184, 200), width=3)

    # 8. Dynamic High-Impact Modern TikTok Subtitles / Captions
    sub_y = 310
    if 0.2 <= t_sec < 6.0:
        # Hook caption
        cap_line1 = "NORMAL PUZZLE GAMES: DRAG ONE BY ONE"
        cap_line2 = "SHIFT PUZZLE CHANGES THE RULES!"
        bb1 = FONT_SUBTITLE.getbbox(cap_line1)
        bb2 = FONT_SUBTITLE_HIGHLIGHT.getbbox(cap_line2)
        w_pill = max(bb1[2] - bb1[0], bb2[2] - bb2[0]) + 60
        draw.rounded_rectangle([(WIDTH - w_pill) // 2, sub_y - 12, (WIDTH + w_pill) // 2, sub_y + 78], radius=20, fill=(15, 23, 42, 230), outline=(56, 189, 248, 200), width=2)
        draw.text(((WIDTH - (bb1[2] - bb1[0])) // 2, sub_y), cap_line1, font=FONT_SUBTITLE, fill=(203, 213, 225, 255))
        draw.text(((WIDTH - (bb2[2] - bb2[0])) // 2, sub_y + 40), cap_line2, font=FONT_SUBTITLE_HIGHLIGHT, fill=(56, 189, 248, 255))

    elif 6.0 <= t_sec < 11.0:
        cap_line1 = "SHIFT ENTIRE ROWS & COLUMNS"
        cap_line2 = "5x5 CONTINUOUS TOROIDAL MATRIX"
        bb1 = FONT_SUBTITLE.getbbox(cap_line1)
        bb2 = FONT_SUBTITLE_HIGHLIGHT.getbbox(cap_line2)
        w_pill = max(bb1[2] - bb1[0], bb2[2] - bb2[0]) + 60
        draw.rounded_rectangle([(WIDTH - w_pill) // 2, sub_y - 12, (WIDTH + w_pill) // 2, sub_y + 78], radius=20, fill=(15, 23, 42, 230), outline=(0, 229, 255, 200), width=2)
        draw.text(((WIDTH - (bb1[2] - bb1[0])) // 2, sub_y), cap_line1, font=FONT_SUBTITLE, fill=(240, 245, 255, 255))
        draw.text(((WIDTH - (bb2[2] - bb2[0])) // 2, sub_y + 40), cap_line2, font=FONT_SUBTITLE_HIGHLIGHT, fill=(0, 229, 255, 255))

    elif 11.0 <= t_sec < 17.5:
        cap_line1 = "DRIVE COLUMN 1 UP TWICE..."
        cap_line2 = "CYAN CORE LOCKED!"
        bb1 = FONT_SUBTITLE.getbbox(cap_line1)
        bb2 = FONT_SUBTITLE_HIGHLIGHT.getbbox(cap_line2)
        w_pill = max(bb1[2] - bb1[0], bb2[2] - bb2[0]) + 60
        draw.rounded_rectangle([(WIDTH - w_pill) // 2, sub_y - 12, (WIDTH + w_pill) // 2, sub_y + 78], radius=20, fill=(15, 23, 42, 230), outline=(56, 189, 248, 220), width=2)
        draw.text(((WIDTH - (bb1[2] - bb1[0])) // 2, sub_y), cap_line1, font=FONT_SUBTITLE, fill=(240, 245, 255, 255))
        draw.text(((WIDTH - (bb2[2] - bb2[0])) // 2, sub_y + 40), cap_line2, font=FONT_SUBTITLE_HIGHLIGHT, fill=(56, 189, 248, 255))

    elif 17.5 <= t_sec < 22.4:
        cap_line1 = "COLUMN 2 DOWN TWICE..."
        cap_line2 = "SNAP ROW 1 LEFT INTO TARGET!"
        bb1 = FONT_SUBTITLE.getbbox(cap_line1)
        bb2 = FONT_SUBTITLE_HIGHLIGHT.getbbox(cap_line2)
        w_pill = max(bb1[2] - bb1[0], bb2[2] - bb2[0]) + 60
        draw.rounded_rectangle([(WIDTH - w_pill) // 2, sub_y - 12, (WIDTH + w_pill) // 2, sub_y + 78], radius=20, fill=(15, 23, 42, 230), outline=(0, 230, 118, 220), width=2)
        draw.text(((WIDTH - (bb1[2] - bb1[0])) // 2, sub_y), cap_line1, font=FONT_SUBTITLE, fill=(240, 245, 255, 255))
        draw.text(((WIDTH - (bb2[2] - bb2[0])) // 2, sub_y + 40), cap_line2, font=FONT_SUBTITLE_HIGHLIGHT, fill=(0, 230, 118, 255))

    # 9. Authentic WinDialog (from Screenshot 2) — drops in at t=22.4s
    if 22.4 <= t_sec < 27.5:
        pop_prog = min(1.0, (t_sec - 22.4) / 0.5)
        scale = 0.5 + 0.5 * math.sin(pop_prog * math.pi / 2)

        dim = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, int(195 * pop_prog)))
        img = Image.alpha_composite(img, dim)
        draw = ImageDraw.Draw(img)

        dw = int(800 * scale)
        dh = int(760 * scale)
        dx0 = (WIDTH - dw) // 2
        dy0 = (HEIGHT - dh) // 2

        for gr in range(30, 0, -6):
            draw.rounded_rectangle([dx0 - gr, dy0 - gr, dx0 + dw + gr, dy0 + dh + gr], radius=32, fill=(56, 189, 248, int(8 * (1.0 - gr / 30))))

        draw.rounded_rectangle([dx0, dy0, dx0 + dw, dy0 + dh], radius=30, fill=(15, 23, 42, 255), outline=(56, 189, 248, 200), width=3)

        if scale > 0.85:
            badge_r = 46
            bcx, bcy = WIDTH // 2, dy0 + 95
            draw.ellipse([bcx - badge_r, bcy - badge_r, bcx + badge_r, bcy + badge_r], fill=(30, 58, 95, 255), outline=(56, 189, 248, 240), width=3)
            # Checkmark ✓ in Cyan
            draw.line([bcx - 18, bcy + 2, bcx - 6, bcy + 16], fill=(56, 189, 248, 255), width=5)
            draw.line([bcx - 6, bcy + 16, bcx + 18, bcy - 14], fill=(56, 189, 248, 255), width=5)

            # 'LEVEL COMPLETE'
            lc_text = "LEVEL COMPLETE"
            bb_lc = FONT_WIN_TITLE.getbbox(lc_text)
            draw.text(((WIDTH - (bb_lc[2] - bb_lc[0])) // 2, dy0 + 175), lc_text, font=FONT_WIN_TITLE, fill=(255, 255, 255, 255))

            # 3 Large 5-Pointed Clean Gold Stars
            star_base_y = dy0 + 280
            star_centers = [WIDTH // 2 - 110, WIDTH // 2, WIDTH // 2 + 110]
            star_times = [22.8, 23.2, 23.6]

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
                    r_out = 42
                    r_in = int(r_out * 0.48)
                    draw_vector_gold_star(
                        draw, scx, star_base_y, r_out, r_in,
                        fill_color=(20, 30, 52, 255),
                        outline_color=(51, 65, 85, 255)
                    )

            # 'PERFECT!'
            r_text = "PERFECT!"
            bb_r = FONT_WIN_RATING.getbbox(r_text)
            draw.text(((WIDTH - (bb_r[2] - bb_r[0])) // 2, dy0 + 355), r_text, font=FONT_WIN_RATING, fill=(56, 189, 248, 255))

            # Move Stats: 'Moves: 6'
            m_stat = "Moves: 6"
            bb_ms = FONT_WIN_STAT.getbbox(m_stat)
            draw.text(((WIDTH - (bb_ms[2] - bb_ms[0])) // 2, dy0 + 410), m_stat, font=FONT_WIN_STAT, fill=(255, 255, 255, 255))

            # 'Optimal: 6 moves'
            opt_stat = "Optimal: 6 moves"
            bb_os = FONT_WIN_OPT.getbbox(opt_stat)
            draw.text(((WIDTH - (bb_os[2] - bb_os[0])) // 2, dy0 + 456), opt_stat, font=FONT_WIN_OPT, fill=(148, 163, 184, 255))

            # Buttons Row: [ Replay ]  [ Next Level ]
            btn_w = 260
            btn_h = 80
            btn_y = dy0 + 520
            # Left: Replay Button (#1E293B, rounded 20)
            draw.rounded_rectangle([dx0 + 45, btn_y, dx0 + 45 + btn_w, btn_y + btn_h], radius=22, fill=(30, 41, 59, 255), outline=(51, 65, 85, 200), width=2)
            bb_rep = FONT_WIN_BTN.getbbox("Replay")
            draw.text((dx0 + 45 + (btn_w - (bb_rep[2] - bb_rep[0])) // 2, btn_y + 24), "Replay", font=FONT_WIN_BTN, fill=(240, 245, 255, 240))

            # Right: Next Level Button (Solid bright Cyan #38BDF8 with glow)
            nl_x = dx0 + dw - 45 - btn_w
            for gr in range(16, 0, -4):
                draw.rounded_rectangle([nl_x - gr, btn_y - gr, nl_x + btn_w + gr, btn_y + btn_h + gr], radius=24, fill=(56, 189, 248, int(18 * (1.0 - gr / 16))))
            draw.rounded_rectangle([nl_x, btn_y, nl_x + btn_w, btn_y + btn_h], radius=22, fill=(56, 189, 248, 255))
            bb_nl = FONT_WIN_BTN.getbbox("Next Level")
            draw.text((nl_x + (btn_w - (bb_nl[2] - bb_nl[0])) // 2, btn_y + 24), "Next Level", font=FONT_WIN_BTN, fill=(15, 23, 42, 255))

            # Bottom Call-To-Action Banner inside Dialog
            cta_txt = "Free Standalone APK • shiftpuzzle.app • Link in Bio"
            bb_cta = FONT_STATUS.getbbox(cta_txt)
            draw.text(((WIDTH - (bb_cta[2] - bb_cta[0])) // 2, dy0 + 640), cta_txt, font=FONT_STATUS, fill=(56, 189, 248, 255))

    # 10. Hero App Download Showcase (t >= 26.8s)
    if t_sec >= 26.8:
        fade_in = min(1.0, (t_sec - 26.8) / 0.45)
        hero_canvas = Image.new("RGBA", (WIDTH, HEIGHT), (3, 7, 18, int(252 * fade_in)))
        hero_canvas = Image.alpha_composite(hero_canvas, ICON_AURA_LAYER)
        hdraw = ImageDraw.Draw(hero_canvas)

        # Floating radiant particles
        for p_i in range(18):
            px = int((p_i * 61 + (t_sec * 25)) % WIDTH)
            py = int(HEIGHT - ((t_sec * 35 + p_i * 95) % HEIGHT))
            p_sz = 3 + (p_i % 3) * 2
            p_alpha = int((85 + 35 * math.sin(t_sec * 3 + p_i)) * fade_in)
            hdraw.ellipse([px - p_sz, py - p_sz, px + p_sz, py + p_sz], fill=(0, 229, 255, p_alpha))

        # Top Badge
        top_badge_y = 350
        top_tag = "OFFICIAL ANDROID RELEASE"
        bb_tag = FONT_HERO_TAG.getbbox(top_tag)
        tw = bb_tag[2] - bb_tag[0]
        hdraw.rounded_rectangle([(WIDTH - tw) // 2 - 24, top_badge_y - 10, (WIDTH + tw) // 2 + 24, top_badge_y + 36], radius=16, fill=(15, 23, 42, int(220 * fade_in)), outline=(0, 229, 255, int(200 * fade_in)), width=2)
        hdraw.text(((WIDTH - tw) // 2, top_badge_y), top_tag, font=FONT_HERO_TAG, fill=(0, 229, 255, int(255 * fade_in)))

        # App Icon at (WIDTH//2, 540)
        icon_cx, icon_cy = WIDTH // 2, 540
        if APP_ICON_220 is not None:
            hero_canvas.paste(APP_ICON_220, (icon_cx - 110, icon_cy - 110), APP_ICON_220)
        hdraw.rounded_rectangle([icon_cx - 110, icon_cy - 110, icon_cx + 110, icon_cy + 110], radius=50, outline=(0, 229, 255, int(240 * fade_in)), width=3)

        # App Title
        title_y = 690
        app_title = "SHIFT PUZZLE"
        bb_title = FONT_HERO_TITLE.getbbox(app_title)
        hdraw.text(((WIDTH - (bb_title[2] - bb_title[0])) // 2, title_y), app_title, font=FONT_HERO_TITLE, fill=(255, 255, 255, int(255 * fade_in)))

        # Subtitle
        sub_y = 765
        sub_text = "Mind-Bending Toroidal Logic"
        bb_sub = FONT_HERO_SUB.getbbox(sub_text)
        hdraw.text(((WIDTH - (bb_sub[2] - bb_sub[0])) // 2, sub_y), sub_text, font=FONT_HERO_SUB, fill=(148, 163, 184, int(255 * fade_in)))

        # 3 Feature Pills
        features = [
            ("150 HANDCRAFTED LEVELS", (56, 189, 248)),
            ("100% FREE & ZERO ADS", (0, 230, 118)),
            ("OFFLINE PLAY (NO WI-FI)", (192, 132, 252))
        ]
        feat_start_y = 840
        pill_h = 66
        for f_idx, (f_txt, f_color) in enumerate(features):
            fy = feat_start_y + f_idx * (pill_h + 16)
            bb_f = FONT_HERO_PILL.getbbox(f_txt)
            fw = bb_f[2] - bb_f[0] + 60
            fx0 = (WIDTH - fw) // 2
            fx1 = fx0 + fw
            hdraw.rounded_rectangle([fx0, fy, fx1, fy + pill_h], radius=20, fill=(15, 23, 42, int(230 * fade_in)), outline=(*f_color, int(180 * fade_in)), width=2)
            hdraw.text(((WIDTH - (bb_f[2] - bb_f[0])) // 2, fy + 16), f_txt, font=FONT_HERO_PILL, fill=(*f_color, int(255 * fade_in)))

        # Hero Download Button (CTA)
        btn_w = 760
        btn_h = 110
        btn_x0 = (WIDTH - btn_w) // 2
        btn_y0 = 1150
        pulse_cta = 0.5 + 0.5 * math.sin(t_sec * 6.0)
        for gr in range(24, 0, -6):
            hdraw.rounded_rectangle([btn_x0 - gr, btn_y0 - gr, btn_x0 + btn_w + gr, btn_y0 + btn_h + gr], radius=32, fill=(0, 229, 255, int(15 * (1.0 - gr / 24) * pulse_cta * fade_in)))

        hdraw.rounded_rectangle([btn_x0, btn_y0, btn_x0 + btn_w, btn_y0 + btn_h], radius=28, fill=(0, 145, 234, int(255 * fade_in)), outline=(0, 229, 255, int(240 * fade_in)), width=3)

        cta_main = "DOWNLOAD FREE ON ANDROID"
        bb_cm = FONT_HERO_BTN.getbbox(cta_main)
        hdraw.text(((WIDTH - (bb_cm[2] - bb_cm[0])) // 2, btn_y0 + 20), cta_main, font=FONT_HERO_BTN, fill=(255, 255, 255, int(255 * fade_in)))

        cta_sub = "shiftpuzzle.app • Standalone APK"
        bb_cs = FONT_HERO_BTN_SUB.getbbox(cta_sub)
        hdraw.text(((WIDTH - (bb_cs[2] - bb_cs[0])) // 2, btn_y0 + 64), cta_sub, font=FONT_HERO_BTN_SUB, fill=(224, 247, 250, int(240 * fade_in)))

        # Bouncing Vector Arrow & Link Indicator
        bounce_y = int(8 * math.sin(t_sec * 8.0))
        arrow_y = 1320 + bounce_y
        hdraw.polygon([(WIDTH // 2 - 16, arrow_y), (WIDTH // 2 + 16, arrow_y), (WIDTH // 2, arrow_y + 18)], fill=(56, 189, 248, int(255 * fade_in)))

        link_txt = "TAP LINK IN BIO & DESCRIPTION"
        bb_lt = FONT_HERO_CTA.getbbox(link_txt)
        hdraw.text(((WIDTH - (bb_lt[2] - bb_lt[0])) // 2, arrow_y + 30), link_txt, font=FONT_HERO_CTA, fill=(56, 189, 248, int(255 * fade_in)))

        domain_txt = "Available Free at: shiftpuzzle.app"
        bb_dom = FONT_HERO_SUB.getbbox(domain_txt)
        hdraw.text(((WIDTH - (bb_dom[2] - bb_dom[0])) // 2, arrow_y + 76), domain_txt, font=FONT_HERO_SUB, fill=(148, 163, 184, int(255 * fade_in)))

        img = Image.alpha_composite(img, hero_canvas)

    return img

def main():
    print(f"Generating Level 35 'Interlock' viral YouTube Short (1035 frames, 34.5s at 30 FPS)...")
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print("Synthesizing audio: neural voiceover + tactile swipes + lock chimes + victory chord...")
    generate_audio(TOTAL_FRAMES / FPS)

    temp_video = "/tmp/video2_no_audio.mp4"
    ffmpeg_exe = imageio_ffmpeg.get_ffmpeg_exe()

    writer = imageio_ffmpeg.write_frames(
        temp_video,
        (WIDTH, HEIGHT),
        fps=FPS,
        codec="libx264",
        pix_fmt_in="rgba",
        quality=8,
        macro_block_size=8
    )
    writer.send(None)

    for f in range(TOTAL_FRAMES):
        frame_img = render_frame(f)
        writer.send(np.ascontiguousarray(np.array(frame_img)))
        if f % 100 == 0 or f == TOTAL_FRAMES - 1:
            print(f"Rendering frame {f}/{TOTAL_FRAMES} ({int(f/TOTAL_FRAMES*100)}%)...")

    writer.close()
    print("Video frames encoded. Merging video with neural voiceover and audio...")

    # Multiplex video and audio via ffmpeg
    cmd = [
        ffmpeg_exe, "-y",
        "-i", temp_video,
        "-i", TEMP_WAV,
        "-c:v", "copy",
        "-c:a", "aac",
        "-b:a", "192k",
        "-shortest",
        OUTPUT_VIDEO
    ]
    subprocess.run(cmd, check=True)
    size_mb = os.path.getsize(OUTPUT_VIDEO) / (1024 * 1024)
    print(f"\n🎉 SUCCESS! Generated {OUTPUT_VIDEO} ({size_mb:.2f} MB)")

if __name__ == "__main__":
    main()
