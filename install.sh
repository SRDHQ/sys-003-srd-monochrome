#!/usr/bin/env bash
# Install SRD Monochrome for the current user; no packages are installed. Replaced files are kept
# as <file>.before-srd-<timestamp>, Obsidian themes in <vault>/.obsidian/themes-before-srd-<timestamp>/.
#
#   ./install.sh kitty                 kitty theme (adds an include line to kitty.conf)
#   ./install.sh launcher              hyprtoolkit.conf (hyprlauncher) + greyscale SRD-Mono icons
#   ./install.sh obsidian <vault>      both Obsidian themes into <vault>/.obsidian/themes/
#   ./install.sh all <vault>           all of the above
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
stamp=$(date +%Y%m%d-%H%M%S)
config=${XDG_CONFIG_HOME:-$HOME/.config}

backup() { if [ -e "$1" ]; then cp -a "$1" "$1.before-srd-$stamp"; echo "backed up $1"; fi; }

install_kitty() {
    mkdir -p "$config/kitty"
    backup "$config/kitty/srd-monochrome.conf"
    cp "$here/kitty/srd-monochrome.conf" "$here/kitty/srd-headquarters.conf" "$config/kitty/"
    if ! grep -qx 'include srd-monochrome.conf' "$config/kitty/kitty.conf" 2>/dev/null; then
        backup "$config/kitty/kitty.conf"
        printf '\ninclude srd-monochrome.conf\n' >> "$config/kitty/kitty.conf"
    fi
    echo "kitty: done (reload with ctrl+shift+f5)"
}

install_launcher() {
    mkdir -p "$config/hypr"
    backup "$config/hypr/hyprtoolkit.conf"
    cp "$here/hyprtoolkit/hyprtoolkit.conf" "$config/hypr/hyprtoolkit.conf"
    python3 -I "$here/hyprtoolkit/mono-icons.py"
    pkill -x hyprlauncher || true
    echo "launcher: done (the next launch reads the theme)"
}

install_obsidian() {
    local vault=${1:?usage: ./install.sh obsidian <vault>}
    [ -d "$vault/.obsidian" ] || { echo "$vault is not an Obsidian vault" >&2; exit 1; }
    mkdir -p "$vault/.obsidian/themes"
    for t in "SRD Monochrome" "SRD Headquarters"; do
        if [ -e "$vault/.obsidian/themes/$t" ]; then
            # Backed up outside themes/ so Obsidian does not list the copy as a theme.
            mkdir -p "$vault/.obsidian/themes-before-srd-$stamp"
            mv "$vault/.obsidian/themes/$t" "$vault/.obsidian/themes-before-srd-$stamp/"
            echo "backed up $t to .obsidian/themes-before-srd-$stamp/"
        fi
        rm -rf "$vault/.obsidian/themes/$t"
        cp -r "$here/obsidian/$t" "$vault/.obsidian/themes/"
    done
    echo "obsidian: done (Settings → Appearance → Themes)"
}

case ${1:-} in
    kitty) install_kitty ;;
    launcher) install_launcher ;;
    obsidian) install_obsidian "${2:-}" ;;
    all) install_kitty; install_launcher; install_obsidian "${2:-}" ;;
    *) sed -n '2,8p' "$0"; exit 2 ;;
esac
