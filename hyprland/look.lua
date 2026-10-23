-- SRD Monochrome — Hyprland window frames (Hyprland 0.56+ Lua config)
-- Merge these keys into the hl.config({ ... }) call in ~/.config/hypr/hyprland.lua.
-- Not installed by install.sh: hyprland.lua holds keybinds and monitors, so edit it by hand.

hl.config({
    general = {
        border_size = 1,
        col = {
            active_border   = { colors = {"rgba(ffffffff)", "rgba(8a8a8aff)", "rgba(ffffffff)"}, angle = 45 },
            inactive_border = "rgba(3a3a3aaa)",
        },
    },
    decoration = {
        rounding       = 0,   -- square, like the SWITCHBOARD frames
        rounding_power = 2,
        shadow = { enabled = true, range = 4, render_power = 3, color = 0xee1a1a1a },
    },
})
