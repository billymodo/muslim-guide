from pathlib import Path

import numpy as np
import soundfile as sf


def main() -> None:
    sample_rate = 44_100
    duration = 8.0
    time = np.linspace(
        0,
        duration,
        int(sample_rate * duration),
        endpoint=False,
    )
    audio = np.zeros_like(time)

    for start in (0, 2.5, 5.0):
        active = (time >= start) & (time < start + 0.8)
        audio[active] = 0.3 * np.sin(2 * np.pi * 440 * time[active])

    output_path = (
        Path(__file__).resolve().parents[1]
        / "assets"
        / "audio"
        / "adhan_placeholder.ogg"
    )
    sf.write(output_path, audio, sample_rate, format="OGG", subtype="VORBIS")
    print(f"Generated: {output_path} ({duration}s, {sample_rate}Hz)")


if __name__ == "__main__":
    main()
