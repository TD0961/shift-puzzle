import asyncio
import os
import wave
import edge_tts
import imageio_ffmpeg
import subprocess

VOICE_DIR = "/tmp/video2_voice_clips"
os.makedirs(VOICE_DIR, exist_ok=True)

VOICE = "en-US-ChristopherNeural"

CLIPS = [
    ("clip1.mp3", "Normal puzzle games let you drag pieces one by one. Shift Puzzle changes the rules."),
    ("clip2.mp3", "You shift entire rows and columns across a 5 by 5 toroidal matrix."),
    ("clip3.mp3", "Watch: Row one left... Column one up twice... Locking the cyan core!"),
    ("clip4.mp3", "Column two down twice... And snap row one left into target!"),
    ("clip5.mp3", "Six moves! Optimal par, clean three stars!"),
    ("clip6.mp3", "150 handcrafted levels, zero ads. Download free on Android — link in bio!")
]

async def generate():
    ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
    for fname, text in CLIPS:
        out_path = os.path.join(VOICE_DIR, fname)
        for attempt in range(4):
            try:
                communicate = edge_tts.Communicate(text, VOICE, rate="+16%", pitch="+0Hz")
                await communicate.save(out_path)
                wav_path = out_path.replace(".mp3", ".wav")
                subprocess.run([ffmpeg, "-y", "-i", out_path, wav_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                with wave.open(wav_path, "r") as wf:
                    dur = wf.getnframes() / wf.getframerate()
                print(f"Generated {fname}: {dur:.2f}s")
                break
            except Exception as e:
                print(f"Retry {attempt+1} for {fname}: {e}")
                await asyncio.sleep(2)

if __name__ == "__main__":
    asyncio.run(generate())
