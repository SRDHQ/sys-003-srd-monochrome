# SYS-003 — SRD Monochrome

The desktop look of SRD (Systems Research & Development): black background, soft white text, a
short ramp of greys, **no hue**, white square frames. It matches the lab's SWITCHBOARD console and its
EXCHANGE display, and covers the terminal, the app launcher, window frames and the notes app.

States are told apart by weight, reverse video, frames and symbols, never by colour alone. Every
text grey has at least 4.5:1 contrast on black (WCAG 1.4.3, measured with the WCAG formula).

| Part | Files | For |
| --- | --- | --- |
| Terminal | `kitty/srd-monochrome.conf` | [kitty](https://sw.kovidgoyal.net/kitty/) |
| Launcher | `hyprtoolkit/hyprtoolkit.conf`, `hyprtoolkit/mono-icons.py` | [hyprlauncher](https://github.com/hyprwm/hyprlauncher) 0.1.6 and other hyprtoolkit 0.6 apps |
| Files | `yazi/theme.toml` (built by `yazi/make-theme.py` from `yazi/srd-base.toml`) | [yazi](https://yazi-rs.github.io/) 26.9 |
| Bar | `waybar/style.css` | Waybar |
| Notifications | `mako/config` | mako |
| Shell | `fish/srd-monochrome.fish` (colours and prompt) | fish 4 |
| Window frames | `hyprland/look.lua` | Hyprland 0.56 (Lua config) |
| Notes | `obsidian/SRD Monochrome/` | Obsidian 1.5+ |

## Palette

| Role | Colour | Contrast on black |
| --- | --- | --- |
| Background | `#000000` | — |
| Text | `#e6e6e6` | 16.83:1 |
| Emphasis, frames | `#ffffff` | 21:1 |
| Secondary text | `#bcbcbc` | 11.06:1 |
| Quiet text | `#8a8a8a` | 6.08:1 |
| Faint text, control borders | `#767676` | 4.62:1 |
| Decorative rules, inactive frames | `#3a3a3a` | (not for text) |

## Install

```bash
./install.sh kitty                 # terminal theme, adds "include srd-monochrome.conf" to kitty.conf
./install.sh launcher              # hyprtoolkit.conf + greyscale icons in ~/.local/share/icons/SRD-Mono
./install.sh yazi                  # yazi theme in ~/.config/yazi/theme.toml
./install.sh waybar                # Waybar style.css (your own additions must be re-added)
./install.sh mako                  # mako notifications; critical ones in reverse video
./install.sh fish                  # fish colours and prompt in ~/.config/fish/conf.d/
./install.sh obsidian ~/my-vault   # Obsidian theme; then pick it in Settings → Appearance
./install.sh all ~/my-vault
```

Every file the script replaces is kept beside it as `<file>.before-srd-<timestamp>`. Window frames
are not installed: copy the keys from `hyprland/look.lua` into your own `hyprland.lua`.

### Launcher notes

- hyprtoolkit draws the launcher frame in `accent` and the selected row as a dimmed copy of it, so
  a white accent gives a white frame and a mid-grey selected row. Reverse video (black text on a
  white row) is not possible: the text colour is the same for every row.
- `mono-icons.py` (Python standard library only) writes one SVG per `Icon=` name in your installed
  `.desktop` files. Each embeds the Breeze or hicolor original and draws it through a
  zero-saturation filter; the originals are not changed. Run it again after installing apps.
  The generated icons are not in this repository because they contain other projects' artwork.
- hyprlauncher keeps running in the background and reads the theme only at start; the installer
  stops it so the next launch picks up the theme.

### yazi notes

- Frames use the double vertical line `║`, the hovered file and dialogs' choices are in reverse
  video, and directories are bold white; file kinds differ by grey level and italics.
- yazi colours its icons with fixed hex values that ignore the terminal palette. `make-theme.py`
  copies the icon rules from the installed yazi binary and turns each colour into a grey of the
  same brightness, between `#767676` and `#e6e6e6`. Run it again after a yazi update, then
  `./install.sh yazi`.
- To open it from the Hyprland file-manager key, set `local fileManager = "kitty --class yazi -e yazi"`
  in `hyprland.lua` (the stock config binds it to SUPER+E).

## Records

Design decisions are kept in SRD's private lab log and cited here by number (D-090 kitty,
D-091 Obsidian, D-096 launcher).

## Licence

MIT, © 2026 SRD (Systems Research & Development). See `LICENSE`.
