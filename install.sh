#!/usr/bin/env bash
# Install SRD Monochrome for the current user; no packages are installed. Replaced files are kept
# as <file>.before-srd-<timestamp>, Obsidian themes in <vault>/.obsidian/themes-before-srd-<timestamp>/.
#
#   ./install.sh kitty                 kitty theme (adds an include line to kitty.conf)
#   ./install.sh launcher              hyprtoolkit.conf (hyprlauncher) + greyscale SRD-Mono icons
#   ./install.sh yazi                  yazi file manager theme (theme.toml)
#   ./install.sh waybar                Waybar style.css (replaces it; re-add your own blocks)
#   ./install.sh mako                  mako notification config
#   ./install.sh fish                  fish colours and prompt in conf.d/
#   ./install.sh zed                   Zed theme (pick "SRD Monochrome" in the theme selector)
#   ./install.sh obsidian <vault>      the Obsidian theme into <vault>/.obsidian/themes/
#   ./install.sh all <vault>           all of the above
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
stamp=$(date +%Y%m%d-%H%M%S)
config=${XDG_CONFIG_HOME:-$HOME/.config}

backup() { if [ -e "$1" ]; then cp -a "$1" "$1.before-srd-$stamp"; echo "backed up $1"; fi; }

install_kitty() {
    mkdir -p "$config/kitty"
    backup "$config/kitty/srd-monochrome.conf"
    cp "$here/kitty/srd-monochrome.conf" "$config/kitty/"
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

install_yazi() {
    mkdir -p "$config/yazi"
    backup "$config/yazi/theme.toml"
    cp "$here/yazi/theme.toml" "$config/yazi/theme.toml"
    echo "yazi: done (restart yazi)"
}

install_waybar() {
    mkdir -p "$config/waybar"
    backup "$config/waybar/style.css"
    cp "$here/waybar/style.css" "$config/waybar/style.css"
    pkill -SIGUSR2 -x waybar || true
    echo "waybar: done (reloaded if running)"
}

install_mako() {
    mkdir -p "$config/mako"
    backup "$config/mako/config"
    cp "$here/mako/config" "$config/mako/config"
    makoctl reload 2>/dev/null || true
    echo "mako: done"
}

install_fish() {
    mkdir -p "$config/fish/conf.d"
    backup "$config/fish/conf.d/srd-monochrome.fish"
    cp "$here/fish/srd-monochrome.fish" "$config/fish/conf.d/"
    if grep -qE '^\s*(set .*fish_(pager_)?color_|function fish_prompt)' "$config/fish/config.fish" 2>/dev/null; then
        echo "fish: note: config.fish sets colours or a prompt; it runs after conf.d, so remove those lines"
    fi
    echo "fish: done (open a new shell)"
}

install_zed() {
    mkdir -p "$config/zed/themes"
    backup "$config/zed/themes/srd-monochrome.json"
    cp "$here/zed/srd-monochrome.json" "$config/zed/themes/"
    echo "zed: done (select SRD Monochrome: ctrl+k ctrl+t, or \"theme\" in settings.json)"
}

install_obsidian() {
    local vault=${1:?usage: ./install.sh obsidian <vault>}
    [ -d "$vault/.obsidian" ] || { echo "$vault is not an Obsidian vault" >&2; exit 1; }
    mkdir -p "$vault/.obsidian/themes"
    for t in "SRD Monochrome"; do
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
    yazi) install_yazi ;;
    waybar) install_waybar ;;
    mako) install_mako ;;
    fish) install_fish ;;
    zed) install_zed ;;
    obsidian) install_obsidian "${2:-}" ;;
    all) install_kitty; install_launcher; install_yazi; install_waybar; install_mako; install_fish; install_zed; install_obsidian "${2:-}" ;;
    *) sed -n '2,13p' "$0"; exit 2 ;;
esac
