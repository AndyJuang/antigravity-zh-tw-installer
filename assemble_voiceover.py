#!/usr/bin/env python3
"""Assemble per-cue TTS clips into a single voiceover wav aligned to chinese.srt.

Placement: each clip starts at its cue time, or right after the previous clip
if that one ran long (no overlapping speech). Clips longer than their window
get mild atempo speed-up (cap 1.5x). Drift is reported per cue.
"""
import json, subprocess, os
import numpy as np
import soundfile as sf

BASE = os.path.dirname(os.path.abspath(__file__))
meta = json.load(open(os.path.join(BASE, 'audio_meta.json'), encoding='utf-8'))
cues = json.load(open(os.path.join(BASE, 'cues.json'), encoding='utf-8'))
voices = {v['id']: v for v in meta['voices']}

VIDEO_DUR = 57.167
MAX_TEMPO = 1.5
GAP = 0.06      # min silence between consecutive clips
SR = 24000

total = int(VIDEO_DUR * SR)
buf = np.zeros(total, dtype=np.float64)
report = ['# 中文旁白時間軸對齊報告（Kokoro + misaki 重生成）', '',
          '| Cue | 文字 | 字幕開始 (s) | 實際開始 (s) | TTS 長度 (s) | 加速倍率 | 延遲 (s) |',
          '| --- | --- | --- | --- | --- | --- | --- |']
problems, prev_end = [], 0.0

for i, cue in enumerate(cues):
    cid, start = cue['id'], cue['start']
    next_start = cues[i + 1]['start'] if i + 1 < len(cues) else VIDEO_DUR
    v = voices.get(cid)
    if not v:
        problems.append(cid)
        continue
    data, sr = sf.read(os.path.join(BASE, v['path']), dtype='float64')
    if data.ndim > 1:
        data = data.mean(axis=1)
    dur = len(data) / sr

    place = max(start, prev_end + GAP)
    window = next_start - place
    tempo = 1.0
    if dur > window and window > 0.3:
        tempo = min(dur / window, MAX_TEMPO)
        tmp = os.path.join(BASE, 'assets', 'voice', f'tempo_{cid}.wav')
        subprocess.run(['ffmpeg', '-y', '-v', 'error', '-i',
                        os.path.join(BASE, v['path']),
                        '-af', f'atempo={tempo:.4f}', '-ar', str(SR), tmp], check=True)
        data, sr = sf.read(tmp, dtype='float64')
        if data.ndim > 1:
            data = data.mean(axis=1)
        dur = len(data) / sr
    if sr != SR:
        idx = np.linspace(0, len(data) - 1, int(len(data) * SR / sr))
        data = np.interp(idx, np.arange(len(data)), data)

    s = int(place * SR)
    e = min(s + len(data), total)
    if e <= s:
        problems.append(cid)
        continue
    buf[s:e] += data[:e - s]
    prev_end = place + dur
    delay = place - start
    if delay > 0.8:
        problems.append(cid)
    report.append(f"| {cid} | {cue['text']} | {start:.2f} | {place:.2f} | "
                  f"{dur:.2f} | {tempo:.2f} | {delay:+.2f} |")

peak = np.abs(buf).max()
if peak > 0.98:
    buf *= 0.98 / peak
sf.write(os.path.join(BASE, 'chinese_voiceover.wav'), buf.astype(np.float32), SR, subtype='PCM_16')
report.append('')
report.append(f'總長 {total/SR:.2f}s，最後一句結束於 {prev_end:.2f}s，'
              f'需注意的 cue：{"、".join(problems) if problems else "無"}')
open(os.path.join(BASE, 'alignment_report.md'), 'w', encoding='utf-8').write('\n'.join(report) + '\n')
print(f'done. last_end={prev_end:.2f}s peak={peak:.3f} problems={problems or "none"}')
