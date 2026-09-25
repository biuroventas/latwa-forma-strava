#!/usr/bin/env python3
"""App Store Connect IAP assets per Apple In-App Purchase information spec."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
OUT_REVIEW = ROOT / "app_review_screenshot_1290x2796.png"
OUT_PROMO = ROOT / "promotional_1024x1024.png"
ICON = ROOT.parent / "play_icon_512.png"

W, H = 1290, 2796
GREEN = (46, 155, 58)
GREEN_DARK = (30, 120, 42)
GREEN_SOFT = (232, 245, 233)
BG = (245, 247, 245)
WHITE = (255, 255, 255)
TEXT = (28, 28, 30)
MUTED = (90, 90, 95)
ORANGE = (245, 140, 20)
CARD_BORDER = (210, 220, 210)

FONT_REG = "/System/Library/Fonts/Supplemental/Arial.ttf"
FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT_BOLD if bold else FONT_REG, size)


def rounded_rect(draw, xy, r, fill, outline=None, width=2):
    draw.rounded_rectangle(xy, radius=r, fill=fill, outline=outline, width=width)


def main() -> None:
    img = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(img)

    # Status bar
    d.rectangle((0, 0, W, 88), fill=GREEN)
    d.text((64, 28), "9:41", font=font(36, True), fill=WHITE)
    d.text((W - 280, 28), "••••  100%", font=font(32, True), fill=WHITE)

    # App bar
    d.rectangle((0, 88, W, 220), fill=GREEN)
    d.text((48, 128), "‹", font=font(56, True), fill=WHITE)
    title = "Łatwa Forma Premium"
    tw = d.textlength(title, font=font(40, True))
    d.text(((W - tw) / 2, 138), title, font=font(40, True), fill=WHITE)

    y = 260

    # Hero
    rounded_rect(d, (48, y, W - 48, y + 280), 28, WHITE)
    d.ellipse((W / 2 - 48, y + 28, W / 2 + 48, y + 124), outline=GREEN, width=6)
    d.polygon(
        [(W / 2, y + 48), (W / 2 + 22, y + 104), (W / 2 - 22, y + 104)],
        fill=GREEN,
    )
    hero = "Odblokuj pełny potencjał"
    hw = d.textlength(hero, font=font(44, True))
    d.text(((W - hw) / 2, y + 150), hero, font=font(44, True), fill=TEXT)
    sub = "Subskrypcja Premium w aplikacji"
    sw = d.textlength(sub, font=font(30),)
    d.text(((W - sw) / 2, y + 210), sub, font=font(30), fill=MUTED)
    y += 320

    features = [
        "Przeglądanie historii innych dni niż dziś",
        "Podgląd makroskładników na dashboardzie",
        "Porada AI (limit 100 dziennie)",
        "Analiza AI posiłku ze zdjęcia",
        "Dodawanie posiłku ze składników",
        "Dodawanie posiłku „na mieście”",
        "Integracje Strava i Garmin bez limitów",
        "Eksport raportów do PDF",
    ]
    for label in features:
        d.ellipse((64, y + 10, 100, y + 46), fill=GREEN_SOFT, outline=GREEN, width=2)
        d.text((80, y + 8), "✓", font=font(28, True), fill=GREEN_DARK)
        d.text((128, y + 8), label, font=font(30), fill=TEXT)
        y += 56

    y += 16
    d.text((64, y), "Wybierz plan", font=font(36, True), fill=TEXT)
    y += 64

    # Monthly card
    rounded_rect(d, (48, y, W - 48, y + 150), 24, WHITE, CARD_BORDER, 3)
    d.ellipse((80, y + 50, 128, y + 98), outline=(180, 180, 180), width=4)
    d.text((168, y + 28), "Miesięcznie", font=font(34, True), fill=TEXT)
    d.text((168, y + 78), "69,99 zł  •  premium_monthly", font=font(28), fill=MUTED)
    y += 166

    # Yearly card (selected)
    rounded_rect(d, (48, y, W - 48, y + 190), 24, GREEN)
    d.ellipse((80, y + 58, 128, y + 106), outline=WHITE, width=4)
    d.ellipse((90, y + 68, 118, y + 96), fill=WHITE)
    d.text((168, y + 24), "Rocznie", font=font(34, True), fill=WHITE)
    badge = "Oszczędzasz ~17%"
    bw = d.textlength(badge, font=font(22, True))
    rounded_rect(d, (420, y + 24, 420 + bw + 28, y + 64), 12, (36, 130, 48))
    d.text((434, y + 30), badge, font=font(22, True), fill=WHITE)
    d.text((168, y + 84), "194,99 zł  •  premium_yearly", font=font(28), fill=WHITE)
    d.text((168, y + 128), "w przeliczeniu ok. 16,25 zł / mies. (płatność raz na rok)", font=font(24), fill=(230, 245, 230))
    y += 220

    # CTA
    rounded_rect(d, (48, y, W - 48, y + 108), 28, GREEN)
    cta = "Wykup Premium"
    cw = d.textlength(cta, font=font(38, True))
    d.text(((W - cw) / 2, y + 32), cta, font=font(38, True), fill=WHITE)
    y += 128

    rounded_rect(d, (48, y, W - 48, y + 88), 24, WHITE, GREEN, 3)
    restore = "Przywróć zakupy"
    rw = d.textlength(restore, font=font(32, True))
    d.text(((W - rw) / 2, y + 24), restore, font=font(32, True), fill=GREEN_DARK)
    y += 112

    note = (
        "Płatność przez App Store. Plan miesięczny i roczny odnawiają się\n"
        "automatycznie za cenę pokazaną powyżej, aż anulujesz\n"
        "w Ustawieniach → Apple ID → Subskrypcje.\n"
        "Po opłaceniu konto Premium aktywuje się automatycznie."
    )
    for i, line in enumerate(note.split("\n")):
        lw = d.textlength(line, font=font(24))
        d.text(((W - lw) / 2, y + i * 36), line, font=font(24), fill=MUTED)

    img.save(OUT_REVIEW, "PNG", optimize=True)
    print(f"wrote {OUT_REVIEW} {img.size} {img.mode}")

    promo = Image.open(ICON).convert("RGB").resize((1024, 1024), Image.Resampling.LANCZOS)
    promo.save(OUT_PROMO, "PNG", optimize=True, dpi=(72, 72))
    print(f"wrote {OUT_PROMO} {promo.size} {promo.mode}")


if __name__ == "__main__":
    main()
