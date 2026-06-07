#!/usr/bin/env python3
"""Compose a custom 'Jimothy' LPC walk sheet by stacking modular layers.

Layers are pre-aligned 576x256 sheets (9 frames x 4 directions, 64x64 cells).
We composite back-to-front and recolour the hair to black.
"""
from PIL import Image
import os

SRC = "/Users/cliftonbaggerman/Repos/lpc/spritesheets"
OUT = "/Users/cliftonbaggerman/Repos/Jimothy/Jimothy/Resources/Sprites/jimothy_walk.png"

# Back-to-front draw order. (path, recolor mode: None | "black" | "brown")
LAYERS = [
    ("body/bodies/male/walk.png", None),
    ("eyes/human/adult/default/walk.png", "brown"),
    ("eyes/eyebrows/thick/adult/walk.png", "black"),
    ("legs/pantaloons/male/walk.png", None),
    ("feet/boots/fold/male/walk.png", None),
    ("torso/clothes/longsleeve/longsleeve2/male/walk.png", None),
    ("torso/armour/leather/male/walk.png", None),
    ("torso/waist/belt_leather/male/walk.png", None),
    ("arms/bracers/male/walk.png", None),
    ("hair/plain/adult/walk.png", "black"),
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
