#!/usr/bin/env python3
"""Generates the synthesized sounds of the library.

Python standard library only, plus `ffmpeg` (with libmp3lame) to encode the longer sounds to mp3.

    python3 tool/generate_sounds.py            # writes to assets/sounds/
    python3 tool/generate_sounds.py click_ish  # only the sounds whose name contains the text

The sounds are original: sums of sine waves with exponential decays, plus a little filtered noise. They share a
pentatonic palette, so any two can play at the same time without clashing, and they are normalized to the level of the
sounds that were recorded earlier (average level about -17.5 dB, peaks never above -2 dB). Sounds under about 0.25 s stay wav, because an mp3 adds a short gap at the start.
"""

import math
import random
import shutil
import struct
import subprocess
import sys
import tempfile
import wave
from pathlib import Path

RATE = 44100
PEAK_DB = -2.0  # the older sounds peak between -1 and -3 dB
RMS_DB = -17.5  # and their average level is between -16 and -23 dB; new sounds sit a little above the middle

# A pentatonic palette (C major pentatonic, plus a few lower notes).
C4, D4, E4, G4, A4 = 261.63, 293.66, 329.63, 392.00, 440.00
C5, D5, E5, G5, A5 = 523.25, 587.33, 659.25, 783.99, 880.00
C6, D6, E6, G6 = 1046.50, 1174.66, 1318.51, 1567.98
B5 = 987.77
BB3, DB4 = 233.08, 277.18

ROOT = Path(__file__).resolve().parent.parent / "assets" / "sounds"


def silence(seconds):
    return [0.0] * int(RATE * seconds)


def tone(freq, seconds, decay=8.0, attack=0.004, partials=((1, 1.0),), vibrato=0.0):
    """A note: partials of `freq` with an exponential decay, a short attack and a short release."""
    n = int(RATE * seconds)
    out = []
    for i in range(n):
        t = i / RATE
        env = math.exp(-decay * t)
        if t < attack:
            env *= t / attack
        release = min(1.0, (seconds - t) / 0.01)  # avoids a click at the end
        f = freq * (1 + vibrato * math.sin(2 * math.pi * 5 * t))
        sample = sum(amp * math.sin(2 * math.pi * f * mult * t) for mult, amp in partials)
        out.append(sample * env * release)
    return out


BELL = ((1, 1.0), (2.76, 0.35), (5.4, 0.12))  # inharmonic partials make it ring like a bell
SOFT = ((1, 1.0), (2, 0.25), (3, 0.08))  # sine with a little body
HOLLOW = ((1, 1.0), (3, 0.30), (5, 0.12))  # odd harmonics, like a soft square
BUZZ = ((1, 1.0), (2, 0.5), (3, 0.33), (4, 0.25), (5, 0.2))  # sawtooth-ish, for the negative sounds


def chirp(f0, f1, seconds, decay=6.0):
    """A sine that glides from f0 to f1."""
    n = int(RATE * seconds)
    out, phase = [], 0.0
    for i in range(n):
        t = i / RATE
        f = f0 + (f1 - f0) * (t / seconds)
        phase += 2 * math.pi * f / RATE
        env = math.exp(-decay * t) * min(1.0, t / 0.005) * min(1.0, (seconds - t) / 0.01)
        out.append(math.sin(phase) * env)
    return out


def noise_burst(seconds, decay, cutoff, seed=1):
    """A short burst of low-passed noise, like a soft key press."""
    rng = random.Random(seed)
    a = math.exp(-2 * math.pi * cutoff / RATE)
    n = int(RATE * seconds)
    out, y = [], 0.0
    for i in range(n):
        y = (1 - a) * rng.uniform(-1, 1) + a * y
        out.append(y * math.exp(-decay * i / RATE) * min(1.0, (n - i) / 200))
    return out


def mix(*tracks):
    """Overlays tracks. A track can be (offset_seconds, samples)."""
    length = 0
    placed = []
    for track in tracks:
        offset, samples = track if isinstance(track, tuple) else (0.0, track)
        start = int(RATE * offset)
        placed.append((start, samples))
        length = max(length, start + len(samples))
    out = [0.0] * length
    for start, samples in placed:
        for i, s in enumerate(samples):
            out[start + i] += s
    return out


def gain(samples, g):
    return [s * g for s in samples]


def echo(samples, delay, feedback, repeats):
    tracks = [samples]
    for r in range(1, repeats + 1):
        tracks.append((delay * r, gain(samples, feedback**r)))
    return mix(*tracks)


# ---- The sounds. Each returns mono samples. -------------------------------------------------------------------------


def toggle_on():
    return mix(tone(G5, 0.07, 30, partials=SOFT), (0.06, tone(C6, 0.09, 26, partials=SOFT)))


def toggle_off():
    return mix(tone(G5, 0.07, 30, partials=SOFT), (0.06, tone(D5, 0.09, 26, partials=SOFT)))


def select():
    return mix(tone(E6, 0.09, 45, partials=SOFT), gain(noise_burst(0.01, 300, 6000, seed=3), 0.12))


def error():
    return mix(
        tone(E4, 0.24, 7, partials=BUZZ),
        (0.18, tone(C4, 0.34, 6, partials=BUZZ)),
    )


def warning():
    beep = tone(A5, 0.13, 14, partials=HOLLOW)
    return mix(beep, (0.2, beep))


def info():
    return tone(E5, 0.5, 7, partials=BELL)


def notification():
    return mix(tone(G5, 0.5, 8, partials=BELL), (0.13, tone(C6, 0.6, 7, partials=BELL)))


def mention():
    return mix(
        tone(C5, 0.3, 11, partials=SOFT),
        (0.08, tone(E5, 0.3, 11, partials=SOFT)),
        (0.16, tone(G5, 0.45, 8, partials=SOFT)),
    )


def reminder():
    note = mix(tone(A5, 0.5, 8, partials=BELL), (0.17, tone(E6, 0.55, 8, partials=BELL)))
    return echo(note, 0.42, 0.4, 1)


def alarm():
    hi = tone(A5, 0.14, 9, partials=HOLLOW)
    lo = tone(E5, 0.14, 9, partials=HOLLOW)
    tracks = []
    for i in range(4):
        tracks.append((i * 0.34, hi))
        tracks.append((i * 0.34 + 0.17, lo))
    return mix(*tracks)


def message_sent():
    return mix(chirp(520, 1500, 0.16, decay=9), gain(noise_burst(0.02, 150, 5000, seed=5), 0.1))


def message_received():
    return mix(tone(C6, 0.3, 11, partials=SOFT), (0.1, tone(E6, 0.4, 9, partials=SOFT)))


def noise_band(seconds, decay, low, high, seed=1):
    """Noise between two cutoff frequencies (a high-pass after a low-pass), with an exponential decay."""
    rng = random.Random(seed)
    lp = math.exp(-2 * math.pi * high / RATE)
    hp = math.exp(-2 * math.pi * low / RATE)
    n = int(RATE * seconds)
    out, y1, y2 = [], 0.0, 0.0
    for i in range(n):
        y1 = (1 - lp) * rng.uniform(-1, 1) + lp * y1  # low-pass: removes everything above `high`
        y2 = (1 - hp) * y1 + hp * y2  # a slower low-pass, subtracted: removes everything below `low`
        out.append((y1 - y2) * math.exp(-decay * i / RATE) * min(1.0, (n - i) / 200))
    return out


def typing():
    """A typewriter key: the type bar hits the paper (sharp click and metal ring), the platen thumps, the bar rebounds."""
    metal = ((1, 1.0), (1.62, 0.7), (2.31, 0.5), (3.08, 0.3))  # inharmonic, like a struck metal bar
    strike = mix(
        gain(noise_band(0.012, 400, 1500, 9000, seed=11), 2.2),  # the sharp attack
        gain(tone(1850, 0.07, 75, attack=0.0005, partials=metal), 0.5),  # the bar ringing
        gain(tone(110, 0.07, 55, attack=0.001), 0.9),  # the platen thump
    )
    rebound = mix(
        gain(noise_band(0.008, 500, 2500, 8000, seed=12), 1.0),
        gain(tone(2600, 0.03, 120, attack=0.0005, partials=metal), 0.25),
    )
    return mix(strike, (0.042, rebound))


def payment_success():
    notes = [C5, E5, G5, C6]
    tracks = [(i * 0.09, tone(f, 0.45 if i < 3 else 0.75, 8 if i < 3 else 5, partials=BELL)) for i, f in enumerate(notes)]
    return mix(*tracks)


def payment_failed():
    return mix(tone(G4, 0.3, 6, partials=BUZZ), (0.2, tone(DB4, 0.45, 5, partials=BUZZ)))


def coin():
    return mix(tone(B5, 0.08, 18, partials=HOLLOW), (0.07, tone(E6, 0.5, 7, partials=HOLLOW)))


# name -> (folder, file name, generator). A `.wav` file is written as is; a `.mp3` is encoded with ffmpeg.
SOUNDS = {
    "toggleOn": ("interaction", "toggle_on.wav", toggle_on),
    "toggleOff": ("interaction", "toggle_off.wav", toggle_off),
    "select": ("interaction", "select.wav", select),
    "error": ("feedback", "error.mp3", error),
    "warning": ("feedback", "warning.mp3", warning),
    "info": ("feedback", "info.mp3", info),
    "notification": ("notification", "notification.mp3", notification),
    "mention": ("notification", "mention.mp3", mention),
    "reminder": ("notification", "reminder.mp3", reminder),
    "alarm": ("notification", "alarm.mp3", alarm),
    "messageSent": ("communication", "message_sent.wav", message_sent),
    "messageReceived": ("communication", "message_received.mp3", message_received),
    "typing": ("communication", "typing.wav", typing),
    "paymentSuccess": ("commerce", "payment_success.mp3", payment_success),
    "paymentFailed": ("commerce", "payment_failed.mp3", payment_failed),
    "coin": ("commerce", "coin.mp3", coin),
}


def normalize(samples):
    """Matches the level of the older sounds: the average level reaches RMS_DB, but never above PEAK_DB."""
    peak = max(abs(s) for s in samples) or 1.0
    rms = math.sqrt(sum(s * s for s in samples) / len(samples)) or 1.0
    scale = min(10 ** (PEAK_DB / 20) / peak, 10 ** (RMS_DB / 20) / rms)
    return [s * scale for s in samples]


def write_wav(path, samples):
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", max(-32768, min(32767, int(s * 32767)))) for s in samples))


def main():
    only = sys.argv[1] if len(sys.argv) > 1 else ""
    ffmpeg = shutil.which("ffmpeg") or "/opt/homebrew/bin/ffmpeg"
    with tempfile.TemporaryDirectory() as tmp:
        for name, (folder, file, generate) in SOUNDS.items():
            if only and only.lower() not in name.lower():
                continue
            samples = normalize(generate())
            target = ROOT / folder / file
            target.parent.mkdir(parents=True, exist_ok=True)
            if file.endswith(".wav"):
                write_wav(target, samples)
            else:
                source = Path(tmp) / f"{name}.wav"
                write_wav(source, samples)
                subprocess.run(
                    [ffmpeg, "-y", "-loglevel", "error", "-i", str(source), "-codec:a", "libmp3lame", "-b:a", "128k",
                     "-ar", str(RATE), "-ac", "1", str(target)],
                    check=True,
                )
            print(f"{folder}/{file}: {len(samples) / RATE:.2f}s")


if __name__ == "__main__":
    main()
