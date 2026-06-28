from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]

MINT = '#22C7A5'
MINT_DARK = '#0F766E'
TEAL_DARK = '#075E54'
BG_LIGHT = '#F8FFFC'
BG_DARK = '#071F1A'
WHITE = '#FFFFFF'
LEAF = '#12B981'
LEAF_DARK = '#0F9F75'


def _hex_to_rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip('#')
    return tuple(int(value[i:i + 2], 16) for i in (0, 2, 4))


def _lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def _gradient(size: int, top: str, bottom: str) -> Image.Image:
    top_rgb = _hex_to_rgb(top)
    bottom_rgb = _hex_to_rgb(bottom)
    image = Image.new('RGB', (size, size), top_rgb)
    pixels = image.load()
    for y in range(size):
        t = y / max(size - 1, 1)
        color = tuple(_lerp(top_rgb[i], bottom_rgb[i], t) for i in range(3))
        for x in range(size):
            pixels[x, y] = color
    return image


def _draw_rotated_leaf(
    canvas: Image.Image,
    center: tuple[int, int],
    size: tuple[int, int],
    angle: float,
    fill: str,
) -> None:
    w, h = size
    leaf = Image.new('RGBA', (w * 2, h * 2), (0, 0, 0, 0))
    draw = ImageDraw.Draw(leaf)
    draw.ellipse((w // 2, h // 2, w // 2 + w, h // 2 + h), fill=fill)
    rotated = leaf.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)
    x = center[0] - rotated.width // 2
    y = center[1] - rotated.height // 2
    canvas.alpha_composite(rotated, (x, y))


def _draw_camera_mark(
    canvas: Image.Image,
    box: tuple[int, int, int, int],
    *,
    shadow: bool,
) -> None:
    x0, y0, x1, y1 = box
    w = x1 - x0
    h = y1 - y0
    unit = w / 584
    draw = ImageDraw.Draw(canvas)

    body = (
        x0 + int(0 * unit),
        y0 + int(62 * unit),
        x0 + int(584 * unit),
        y0 + int(478 * unit),
    )
    body_radius = int(130 * unit)
    bump = (
        x0 + int(106 * unit),
        y0 + int(0 * unit),
        x0 + int(292 * unit),
        y0 + int(118 * unit),
    )
    bump_radius = int(50 * unit)

    if shadow:
        shadow_layer = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
        shadow_draw = ImageDraw.Draw(shadow_layer)
        offset = int(24 * unit)
        shadow_draw.rounded_rectangle(
            (body[0], body[1] + offset, body[2], body[3] + offset),
            radius=body_radius,
            fill=(5, 73, 64, 58),
        )
        shadow_draw.rounded_rectangle(
            (bump[0], bump[1] + offset, bump[2], bump[3] + offset),
            radius=bump_radius,
            fill=(5, 73, 64, 46),
        )
        canvas.alpha_composite(shadow_layer.filter(ImageFilter.GaussianBlur(int(22 * unit))))

    draw.rounded_rectangle(body, radius=body_radius, fill=WHITE)
    draw.rounded_rectangle(bump, radius=bump_radius, fill=WHITE)

    flash = (
        x0 + int(438 * unit),
        y0 + int(160 * unit),
        x0 + int(506 * unit),
        y0 + int(228 * unit),
    )
    draw.ellipse(flash, fill='#DFFBF5')

    lens_outer = (
        x0 + int(174 * unit),
        y0 + int(158 * unit),
        x0 + int(410 * unit),
        y0 + int(394 * unit),
    )
    lens_ring = (
        x0 + int(202 * unit),
        y0 + int(186 * unit),
        x0 + int(382 * unit),
        y0 + int(366 * unit),
    )
    lens_inner = (
        x0 + int(232 * unit),
        y0 + int(216 * unit),
        x0 + int(352 * unit),
        y0 + int(336 * unit),
    )
    draw.ellipse(lens_outer, fill=TEAL_DARK)
    draw.ellipse(lens_ring, fill='#E9FFFA')
    draw.ellipse(lens_inner, fill='#F7FFFC')

    cx = x0 + int(292 * unit)
    cy = y0 + int(276 * unit)
    stem_width = max(3, int(8 * unit))
    draw.line(
        (cx, cy + int(38 * unit), cx, cy - int(34 * unit)),
        fill=LEAF_DARK,
        width=stem_width,
    )
    _draw_rotated_leaf(
        canvas,
        (cx - int(24 * unit), cy - int(6 * unit)),
        (int(62 * unit), int(34 * unit)),
        136,
        LEAF,
    )
    _draw_rotated_leaf(
        canvas,
        (cx + int(26 * unit), cy - int(30 * unit)),
        (int(58 * unit), int(32 * unit)),
        42,
        LEAF_DARK,
    )

    corner_color = '#BDF4E8'
    line_w = max(5, int(10 * unit))
    length = int(52 * unit)
    inset = int(70 * unit)
    for sx, sy in ((1, 1), (-1, 1), (1, -1), (-1, -1)):
        ox = cx + sx * inset
        oy = cy + sy * inset
        draw.line((ox, oy, ox - sx * length, oy), fill=corner_color, width=line_w)
        draw.line((ox, oy, ox, oy - sy * length), fill=corner_color, width=line_w)


def create_app_icon() -> Image.Image:
    size = 1024
    base = _gradient(size, '#2DD4BF', '#14B8A6').convert('RGBA')
    _draw_camera_mark(base, (220, 272, 804, 750), shadow=True)
    return base.convert('RGB')


def create_foreground() -> Image.Image:
    image = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))
    _draw_camera_mark(image, (220, 272, 804, 750), shadow=False)
    return image


def create_splash_logo() -> Image.Image:
    size = 600
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    shadow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle((90, 104, 510, 524), radius=132, fill=(5, 73, 64, 34))
    image.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(18)))
    draw.rounded_rectangle((90, 90, 510, 510), radius=132, fill=MINT)
    _draw_camera_mark(image, (154, 170, 446, 409), shadow=False)
    return image


def create_splash_background(size: tuple[int, int], dark: bool = False) -> Image.Image:
    color = BG_DARK if dark else BG_LIGHT
    image = Image.new('RGB', size, color)
    draw = ImageDraw.Draw(image)
    if not dark:
        draw.rectangle((0, size[1] - 10, size[0], size[1]), fill='#D8FFF6')
    return image


def create_full_splash() -> Image.Image:
    size = (1284, 2778)
    image = create_splash_background(size).convert('RGBA')
    logo = create_splash_logo()
    image.alpha_composite(logo, ((size[0] - logo.width) // 2, (size[1] - logo.height) // 2 - 80))
    return image.convert('RGB')


def save_scaled(source: Image.Image, path: Path, size: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    source.resize((size, size), Image.Resampling.LANCZOS).save(path)


def main() -> None:
    app_icon = create_app_icon()
    foreground = create_foreground()
    splash_logo = create_splash_logo()

    (ROOT / 'assets/icons').mkdir(parents=True, exist_ok=True)
    (ROOT / 'assets/images').mkdir(parents=True, exist_ok=True)

    app_icon.save(ROOT / 'assets/icons/app_icon.png')
    foreground.save(ROOT / 'assets/icons/app_icon_foreground.png')
    create_splash_background((1242, 2688)).save(ROOT / 'assets/images/splash_background.png')
    create_splash_background((1242, 2688), dark=True).save(ROOT / 'assets/images/splash_background_dark.png')
    splash_logo.save(ROOT / 'assets/images/splash_logo.png')
    create_full_splash().save(ROOT / 'assets/images/splash.png')

    for size in (192, 512):
        save_scaled(app_icon, ROOT / f'web/icons/Icon-{size}.png', size)
        save_scaled(app_icon, ROOT / f'web/icons/Icon-maskable-{size}.png', size)
    save_scaled(app_icon, ROOT / 'web/favicon.png', 32)

    for size in (16, 32, 64, 128, 256, 512, 1024):
        save_scaled(
            app_icon,
            ROOT / f'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_{size}.png',
            size,
        )

    ico_sizes = [16, 24, 32, 48, 64, 128, 256]
    ico_images = [app_icon.resize((size, size), Image.Resampling.LANCZOS) for size in ico_sizes]
    ico_path = ROOT / 'windows/runner/resources/app_icon.ico'
    ico_path.parent.mkdir(parents=True, exist_ok=True)
    ico_images[-1].save(ico_path, sizes=[(size, size) for size in ico_sizes])


if __name__ == '__main__':
    main()
