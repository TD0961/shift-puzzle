#!/usr/bin/env python3
"""
Generate realistic neural voiceover clips for Level 24 'Toroidal Bypass' TikTok video.
"""

import asyncio
import os
import edge_tts

VOICE = "en-US-ChristopherNeural"
OUT_DIR = "/tmp/tiktok_voice_clips"

CLIPS = [
    ("clip1.mp3", "Level 24 looks completely locked. Four pieces, and you only have seven moves to reach par."),
    ("clip2.mp3", "If you get stuck, tap Need a hint? It reveals the Toroidal Bypass."),
    ("clip3.mp3", "Shift row two right to loop around the board. Move column two up, column three down, and lock the cyan core."),
    ("clip4.mp3", "Now align column zero, and double shift column two to drop both targets at once."),
    ("clip5.mp3", "Seven moves, optimal par, perfect three stars! Download Shift Puzzle free on Android, link in bio!")
]

async def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    print("Generating neural voiceover clips with edge-tts...")
    for filename, text in CLIPS:
        path = os.path.join(OUT_DIR, filename)
        comm = edge_tts.Communicate(text, VOICE, rate="+6%")
        await comm.save(path)
        print(f"Generated {filename}: {text[:35]}...")
    print("All voiceover clips generated successfully!")

if __name__ == "__main__":
    asyncio.run(main())
