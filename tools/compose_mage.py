#!/usr/bin/env python3
"""Compose a clean LPC mage walk sheet (hand-made pixel art, no AI).

Female body + purple robe + wizard hat + face. Same 576x256 LPC layout as
compose_jimothy.py. Needs the local LPC clone at ~/Repos/lpc.
"""
from PIL import Image
import os

SRC = "/Users/cliftonbaggerman/Repos/lpc/spritesheets"
OUT = "/Users/cliftonbaggerman/Repos/Jimothy/Jimothy/Resources/Sprites/mage_walk.png"

# Back-to-front draw order. (path, recolor mode: None | "black" | "brown")
LAYERS = [
    ("body/bodies/female/walk.png", None),
    ("eyes/human/adult/default/walk.png", "brown"),
    ("eyes/eyebrows/thick/adult/walk.png", "black"),
    ("torso/clothes/robe/female/walk/purple.png", None),
    ("hat/magic/wizard/base/adult/walk.png", "purple"),
]


def recolor(img: Image.Image, mode: str) -> Image.Image:
    img = img.convert("RGBA")
    pixels = img.load()
    width, height = img.size
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
            if mode == "black":
                v = int(lum * 56)
                pixels[x, y] = (v + 8, v + 8, v + 14, a)
            elif mode == "brown":
                pixels[x, y] = (int(45 + lum * 80), int(28 + lum * 50), int(14 + lum * 30), a)
            elif mode == "purple":
                pixels[x, y] = (int(40 + lum * 95), int(22 + lum * 60), int(70 + lum * 120), a)
    return img


def main() -> None:
    base = None
    for rel, mode in LAYERS:
        path = os.path.join(SRC, rel)
        if not os.path.exists(path):
            print(f"skip (missing): {rel}")
            continue
        layer = Image.open(path).convert("RGBA")
        if mode:
            layer = recolor(layer, mode)
        if base is None:
            base = Image.new("RGBA", layer.size, (0, 0, 0, 0))
        base.alpha_composite(layer)

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    base.save(OUT)
    print(f"wrote {OUT}  size={base.size}")


if __name__ == "__main__":
    main()
