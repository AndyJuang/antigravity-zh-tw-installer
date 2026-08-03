#!/usr/bin/env python3
"""Generate per-cue Chinese TTS with kokoro-onnx + misaki zh G2P (bypasses espeak zh/cmn naming issue)."""
import json, os, sys
import soundfile as sf
from misaki import zh
from kokoro_onnx import Kokoro

BASE = os.path.dirname(os.path.abspath(__file__))
MODEL = os.path.expanduser('~/.cache/hyperframes/tts/models/kokoro-v1.0.onnx')
VOICES = os.path.expanduser('~/.cache/hyperframes/tts/voices/voices-v1.0.bin')
VOICE = 'zf_xiaobei'

req = json.load(open(os.path.join(BASE, 'audio_request.json'), encoding='utf-8'))
lines = req['lines']
if len(sys.argv) > 1:  # test mode: only first N lines
    lines = lines[:int(sys.argv[1])]

g2p = zh.ZHG2P()
kokoro = Kokoro(MODEL, VOICES)
os.makedirs(os.path.join(BASE, 'assets', 'voice'), exist_ok=True)

voices_meta = []
for line in lines:
    ps, _ = g2p(line['text'])
    samples, sr = kokoro.create(ps, voice=VOICE, speed=1.0, is_phonemes=True)
    rel = f"assets/voice/{line['id']}.wav"
    sf.write(os.path.join(BASE, rel), samples, sr)
    dur = len(samples) / sr
    voices_meta.append({'id': line['id'], 'path': rel, 'duration_s': round(dur, 3), 'words': []})
    print(f"cue {line['id']}: {dur:.2f}s  phonemes={ps[:40]!r}", flush=True)

meta = {'tts_provider': 'kokoro-direct', 'voice_id': VOICE, 'bgm': None,
        'voices': voices_meta, 'sfx': [],
        'total_duration_s': round(sum(v['duration_s'] for v in voices_meta), 3)}
json.dump(meta, open(os.path.join(BASE, 'audio_meta.json'), 'w', encoding='utf-8'),
          ensure_ascii=False, indent=1)
print(f"wrote audio_meta.json with {len(voices_meta)} voices")
