"""Frames raw simulator captures (tool/store_screenshots.sh) as App Store images: a headline in
Pretendard over a dark backdrop tinted from the screen's own colours, the screen below with
rounded corners and a shadow. Output is the input size (1320 x 2868 for 6.9-inch).

    python3 tool/compose_store.py <raw dir> <out dir> <locale> [WxH]

WxH sets the canvas (Google Play wants at most 2:1, e.g. 1080x1920); the screen is fitted in.
"""
import glob, os, sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont

CAPTIONS = {
    'en': {'1-home': ('K-pop radio,', 'live and free'), '2-player': ('Every song,', 'full screen'),
           '3-lyrics': ('Lyrics that', 'sing along'), '4-genres': ('Twelve stations,', 'one tap away'),
           '5-charts': ('See what’s hot', 'this week'), '6-request': ('You choose', 'what plays next')},
    'ko': {'1-home': ('라이브로, 무료로', '듣는 K-pop 라디오'), '2-player': ('모든 곡을', '화면 가득하게'),
           '3-lyrics': ('따라 부르는', '실시간 가사'), '4-genres': ('열두 개 채널을', '한 번의 탭으로'),
           '5-charts': ('이번 주 인기곡을', '한눈에'), '6-request': ('다음 곡은', '여러분이 골라요')},
}
FONT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'fonts', 'PretendardVariable.ttf')


def font(size, weight):
    f = ImageFont.truetype(FONT, size)
    f.set_variation_by_axes([weight])
    return f


def tint(im):
    """The screen's most colourful region, darkened for a backdrop."""
    small = im.convert('RGB').resize((24, 52))
    best, score = (40, 40, 48), -1
    for px in small.getdata():
        r, g, b = px
        mx, mn = max(px), min(px)
        s = (mx - mn) / 255 * (1 - abs((mx + mn) / 510 - 0.5))
        if s > score:
            best, score = px, s
    return tuple(int(c * 0.42) for c in best)


def compose(src, dst, top, bottom, size=None):
    shot = Image.open(src).convert('RGB')
    W, H = size or shot.size
    base = tint(shot)
    canvas = Image.new('RGB', (W, H), (10, 10, 11))
    # Backdrop: the tint glowing down from the top.
    glow = Image.new('RGB', (W, H), base)
    mask = Image.linear_gradient('L').resize((W, H)).transpose(Image.FLIP_TOP_BOTTOM)
    canvas.paste(glow, (0, 0), mask)
    d = ImageDraw.Draw(canvas)
    # Headline: two lines, the second a touch lighter.
    f1, f2 = font(int(min(W, H / 2.17) * 0.082), 800), font(int(min(W, H / 2.17) * 0.082), 800)
    y = int(H * 0.055)
    for text, colour in ((top, (255, 255, 255)), (bottom, (255, 255, 255, 170))):
        f = f1 if colour[-1] == 255 and len(colour) == 3 else f2
        w = d.textlength(text, font=f)
        d.text(((W - w) / 2, y), text, font=f, fill=colour[:3] if len(colour) == 3 else (215, 215, 220))
        y += int(min(W, H / 2.17) * 0.1)
    # The screen, scaled into the lower part, rounded, with a soft shadow.
    # Fit the screen into the space under the headline, keeping its aspect.
    room_h = H - (y + int(H * 0.035)) - int(H * 0.02)
    k = min(W * 0.8 / shot.width, room_h / shot.height) if size else 0.8 * W / shot.width
    sw, sh = int(shot.width * k), int(shot.height * k)
    screen = shot.resize((sw, sh), Image.LANCZOS)
    radius = int(sw * 0.11)
    round_mask = Image.new('L', (sw, sh), 0)
    ImageDraw.Draw(round_mask).rounded_rectangle((0, 0, sw, sh), radius=radius, fill=255)
    x, top_y = (W - sw) // 2, y + int(H * 0.035)
    shadow = Image.new('L', (W, H), 0)
    ImageDraw.Draw(shadow).rounded_rectangle((x, top_y + 30, x + sw, top_y + sh + 30), radius=radius, fill=170)
    shadow = shadow.filter(ImageFilter.GaussianBlur(60))
    canvas.paste((0, 0, 0), (0, 0), shadow)
    canvas.paste(screen, (x, top_y), round_mask)
    # A hairline edge so dark screens don't melt into the backdrop.
    ImageDraw.Draw(canvas).rounded_rectangle((x, top_y, x + sw, top_y + sh), radius=radius, outline=(255, 255, 255, 40), width=3)
    canvas.save(dst, optimize=True)


if __name__ == '__main__':
    raw, out, loc = sys.argv[1], sys.argv[2], sys.argv[3]
    size = tuple(int(v) for v in sys.argv[4].split('x')) if len(sys.argv) > 4 else None
    os.makedirs(out, exist_ok=True)
    for src in sorted(glob.glob(os.path.join(raw, f'{loc}-*.png'))):
        key = os.path.basename(src)[len(loc) + 1:-4]
        top, bottom = CAPTIONS[loc][key]
        compose(src, os.path.join(out, os.path.basename(src)), top, bottom, size)
        print('composed', os.path.basename(src))
