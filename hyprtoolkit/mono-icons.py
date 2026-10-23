#!/usr/bin/env python3
"""Build the SRD Mono icon theme: greyscale copies of the app icons the launcher shows (stdlib only).

  python -I hyprtoolkit/mono-icons.py [--out ~/.local/share/icons/SRD-Mono] [--source breeze,hicolor]

For every Icon= name in the installed .desktop files, the best source icon (scalable SVG first,
else the largest PNG) is wrapped in an SVG that embeds it as a data: URI and draws it through a
zero-saturation colour matrix, the same idea as the greyscale jars in LINES. librsvg (used by
hyprtoolkit) renders the filter. Originals are never modified; the output folder is rebuilt.
"""
import argparse
import base64
import os
import re
import shutil
from pathlib import Path

HOME = Path.home()
APP_DIRS = [Path("/usr/share/applications"), HOME / ".local/share/applications"]
ICON_ROOTS = [HOME / ".local/share/icons", Path("/usr/share/icons")]
PIXMAPS = Path("/usr/share/pixmaps")

WRAPPER = """<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="256" height="256" viewBox="0 0 256 256">
<filter id="mono"><feColorMatrix type="saturate" values="0"/></filter>
<image width="256" height="256" filter="url(#mono)" xlink:href="data:{mime};base64,{data}"/>
</svg>
"""


def icon_names():
    names = set()
    for d in APP_DIRS:
        for f in d.glob("*.desktop") if d.is_dir() else []:
            for line in f.read_text(errors="replace").splitlines():
                if line.startswith("Icon="):
                    name = line[5:].strip()
                    if name and "/" not in name:
                        names.add(name)
                    break
    return sorted(names)


def size_of(path):
    m = re.search(r"/(\d+)(?:x\d+)?(?:@\d+x)?/", str(path))
    return int(m.group(1)) if m else 0


def find_icon(name, themes):
    for theme in themes:
        for root in ICON_ROOTS:
            base = root / theme
            if not base.is_dir():
                continue
            hits = [p for ext in ("svg", "png") for p in base.rglob(f"{name}.{ext}")]
            hits = [p for p in hits if "/apps" in str(p) or "/scalable/" in str(p)] or hits
            svgs = [p for p in hits if p.suffix == ".svg"]
            if svgs:
                return max(svgs, key=size_of)
            if hits:
                return max(hits, key=size_of)
    for ext in ("svg", "png"):
        if (PIXMAPS / f"{name}.{ext}").is_file():
            return PIXMAPS / f"{name}.{ext}"
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=str(HOME / ".local/share/icons/SRD-Mono"))
    ap.add_argument("--source", default="breeze,hicolor", help="themes searched, in order")
    args = ap.parse_args()
    out = Path(args.out).expanduser()
    if out.exists():
        shutil.rmtree(out)
    apps = out / "scalable/apps"
    apps.mkdir(parents=True)
    done, missing = 0, []
    for name in icon_names():
        src = find_icon(name, args.source.split(","))
        if src is None:
            missing.append(name)
            continue
        mime = "image/svg+xml" if src.suffix == ".svg" else "image/png"
        data = base64.b64encode(src.resolve().read_bytes()).decode()
        (apps / f"{name}.svg").write_text(WRAPPER.format(mime=mime, data=data))
        done += 1
    (out / "index.theme").write_text(
        "[Icon Theme]\nName=SRD Mono\nComment=Greyscale app icons for the SRD Monochrome desktop\n"
        "Inherits=breeze-dark,hicolor\nDirectories=scalable/apps\n\n"
        "[scalable/apps]\nSize=256\nMinSize=8\nMaxSize=512\nType=Scalable\nContext=Applications\n")
    print(f"{done} icons written to {out}; {len(missing)} not found: {', '.join(missing) or '-'}")


if __name__ == "__main__":
    main()
