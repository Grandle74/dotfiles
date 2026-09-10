-- #######################################################################################
-- HYPRLAND CONFIGURATION FILE BY GRANDLE.
-- #######################################################################################

local terminal = "kitty"
local fileManager = "nautilus"
local menu = "fuzzel"
local wallpaper_dir = os.getenv("HOME") .. "/Pictures/.HyprPaper/"
local scripts = os.getenv("HOME") .. "/.config/hypr/scripts/"

hl.on("hyprland.start", function()
	hl.exec_cmd("hyprctl setcursor BreezeX-Black 28")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

	-- Launch background daemons
	hl.exec_cmd("waybar &")
	hl.exec_cmd("mako &")
	hl.exec_cmd("hyprpaper &")
	hl.exec_cmd("hypridle &")
	hl.exec_cmd("~/.local/bin/pypr &")

	-- Clipboard daemons
	hl.exec_cmd("wl-paste --type text --watch cliphist store &")
	hl.exec_cmd("wl-paste --type image --watch cliphist store &")

	-- Apply the last wallpaper
	hl.exec_cmd("sleep 1s && " .. scripts .. "wall-switch.sh --restore")

	-- Pre-cache missing color schemes silently in the background
	hl.exec_cmd(
		"for img in "
			.. wallpaper_dir
			.. '*.{jpg,png}; do [ -f "$HOME/.cache/wal/$(basename "$img" | tr \'[:upper:]\' \'[:lower:]\')" ] || wal -i "$img" --backend colorthief -n >/dev/null 2>&1 & done'
	)
end)

-- Correct monitor scaling configuration function
hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "0x0",
	scale = 1.17,
})

-- Default static fallback colors (in case Pywal hasn't run yet)
local border_colors = {
	active = { colors = { "rgba(cba6f7ff)", "rgba(f2cdcdff)" }, angle = 90 },
	inactive = "rgba(6c7086ff)",
}

-- Try to load the dynamically generated Pywal colors
pcall(function()
	border_colors = dofile(os.getenv("HOME") .. "/.cache/wal/hyprland-colors.lua")
end)

hl.config({
	debug = {
		disable_scale_checks = true,
	},

	xwayland = {
		force_zero_scaling = true,
	},

	env = {
		"XCURSOR_THEME,BreezeX-Black",
		"XCURSOR_SIZE,24",
		"HYPRCURSOR_THEME,BreezeX-Black",
		"HYPRCURSOR_SIZE,28",
		"QT_QPA_PLATFORMTHEME,qt5ct",
	},

	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_rules = "",
		kb_options = "ctrl:nocaps",
		follow_mouse = 1,
		touchpad = {
			natural_scroll = true,
		},
		sensitivity = 0,
	},

	general = {
		border_size = 2,
		col = {
			active_border = "rgba("
				.. io.popen("sed -n '3p' $HOME/.cache/wal/colors"):read("*l"):gsub("#", "")
				.. "ff)",
			inactive_border = "rgba(31324466)",
		},
		resize_on_border = true,
		gaps_in = 4,
		gaps_out = 8,
		layout = "dwindle",
		allow_tearing = false,
	},

	decoration = {
		rounding = 5,
		blur = {
			enabled = true,
			size = 6, -- Bumped from 3 for a softer Android blur
			passes = 3, -- Bumped from 1 for smooth frosted glass
			vibrancy = 0.2, -- Color vibrancy boost
		},
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
	},

	animations = {
		enabled = true,
	},

	dwindle = {
		preserve_split = true,
		force_split = 2,
	},

	master = {
		new_status = "slave",
		orientation = "left",
	},

	misc = { disable_hyprland_logo = true, force_default_wallpaper = 0, focus_on_activate = true },

	device = {
		{
			name = "epic-mouse-v1",
			sensitivity = -0.5,
		},
	},

	windowrule = {
		"suppress_event maximize, match:class .*",
		"animation slide 80%, match:class fuzzel",
	},

	layerrule = {
		"blur, waybar",
		"ignorezero, waybar",
		"blur, notifications",
		"ignorealpha 0.2, notifications",
		"animation slide right, notifications",
		"blur, wlogout",
		"ignorezero, wlogout",
		"blur, fuzzel",
		"ignorezero, fuzzel",
	},
})

hl.curve("smooth", { type = "bezier", points = { { 0.16, 1.0 }, { 0.3, 1.0 } } })

hl.animation({ leaf = "borderangle", enabled = true, speed = 50, bezier = "smooth" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "smooth", style = "popin 80%" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "smooth" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

local mainMod = "SUPER"

-- =========================================================
-- SYSTEM & SESSION
-- =========================================================
hl.bind(mainMod .. " + M", hl.dsp.exit(), { description = "Exit Hyprland" })
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("wlogout"), { description = "Power Menu (wlogout)" })
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.exec_cmd("hyprlock"), { description = "Lock Screen" })
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload Hyprland Config" })

-- Native monitor toggles
hl.bind(mainMod .. " + SHIFT + D", function()
	hl.monitor({ output = "eDP-1", disabled = true })
end, { description = "Disable eDP-1 Monitor" })
hl.bind(mainMod .. " + D", function()
	hl.monitor({ output = "eDP-1", disabled = false })
end, { description = "Enable eDP-1 Monitor" })

-- =========================================================
-- APPLICATIONS & UTILITIES
-- =========================================================
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal), { description = "Launch Terminal" })
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu), { description = "Launch App Menu" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("blueman-manager"), { description = "Bluetooth Manager" })
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("~/.local/bin/pypr toggle telegram"), { description = "Toggle Telegram Scratchpad" })
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(scripts .. "pomodoro.sh"), { description = "Toggle Pomodoro" })
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(scripts .. "clipmenu.sh"), { description = "Clipboard Manager" })
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(scripts .. "hypr-network"), { description = "Network Manager" })
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(scripts .. "hypr-sound"), { description = "Sound Settings" })
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd(scripts .. "keybindings.sh"), { description = "Show Keybindings" })

-- =========================================================
-- AUDIO & MEDIA
-- =========================================================
-- Sound through pactl
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(
		"pactl set-sink-volume @DEFAULT_SINK@ +10% && paplay /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga"
	),
	{ description = "Volume Up" }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(
		"pactl set-sink-volume @DEFAULT_SINK@ -10% && paplay /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga"
	),
	{ description = "Volume Down" }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { description = "Toggle Audio Mute" })

-- Brightness through brightnessctl
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { description = "Brightness Up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { description = "Brightness Down" })

-- =========================================================
-- SCREENSHOTS & RECORDING
-- =========================================================
-- Screenshots (with flash effect & instant-release lock)
hl.bind("Print", hl.dsp.exec_cmd(scripts .. "hypr-media screenshot full"), { description = "Screenshot (Full)" })
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(scripts .. "hypr-media screenshot region"), { description = "Screenshot (Region)" })

-- Screen Recording
hl.bind(mainMod .. " + F9", hl.dsp.exec_cmd(scripts .. "hypr-media record full"), { description = "Record Screen (Full)" })
hl.bind(mainMod .. " + SHIFT + F9", hl.dsp.exec_cmd(scripts .. "hypr-media record region"), { description = "Record Screen (Region)" })

-- =========================================================
-- THEME & WALLPAPERS
-- =========================================================
hl.bind(
	mainMod .. " + W",
	hl.dsp.exec_cmd(scripts .. "wall-switch.sh --wall"),
	{ description = "Switch Wallpaper Only" }
)
hl.bind(
	mainMod .. " + SHIFT + W",
	hl.dsp.exec_cmd(scripts .. "wall-switch.sh --theme"),
	{ description = "Switch Color Scheme Only" }
)
hl.bind(
	mainMod .. " + tab",
	hl.dsp.exec_cmd(scripts .. "wall-switch.sh --both"),
	{ description = "Switch Wallpaper and Theme" }
)

-- =========================================================
-- WINDOW MANAGEMENT & LAYOUT
-- =========================================================
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "Close Active Window" })
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }), { description = "Toggle Fullscreen" })
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle Floating" })
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pseudo(), { description = "Toggle Pseudo Tiling" })
hl.bind(mainMod .. " + E", hl.dsp.layout("togglesplit"), { description = "Toggle Layout Split" })
hl.bind(mainMod .. " + C", hl.dsp.layout("togglesplit"), { description = "Toggle Layout Split" })

-- Move focus with Win + Arrow Keys
hl.bind(mainMod .. " + Left", hl.dsp.focus({ direction = "l" }), { description = "Focus Left" })
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "r" }), { description = "Focus Right" })
hl.bind(mainMod .. " + Up", hl.dsp.focus({ direction = "u" }), { description = "Focus Up" })
hl.bind(mainMod .. " + Down", hl.dsp.focus({ direction = "d" }), { description = "Focus Down" })

-- Move active window in dwindle tree with Win + J/I/K/L (J=left, I=up, K=down, L=right)
hl.bind(mainMod .. " + j", hl.dsp.window.move({ direction = "l" }), { description = "Move Window Left" })
hl.bind(mainMod .. " + i", hl.dsp.window.move({ direction = "u" }), { description = "Move Window Up" })
hl.bind(mainMod .. " + k", hl.dsp.window.move({ direction = "d" }), { description = "Move Window Down" })
hl.bind(mainMod .. " + l", hl.dsp.window.move({ direction = "r" }), { description = "Move Window Right" })

-- Move/resize windows with mouse bindings
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Drag Window" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize Window" })

-- =========================================================
-- WORKSPACES
-- =========================================================
-- Switch and move workspaces with mainMod + [0-9]
for i = 1, 9 do
	hl.bind(mainMod .. " + " .. tostring(i), hl.dsp.focus({ workspace = tostring(i) }), { description = "Switch to Workspace " .. tostring(i) })
	hl.bind(mainMod .. " + SHIFT + " .. tostring(i), hl.dsp.window.move({ workspace = tostring(i) }), { description = "Move to Workspace " .. tostring(i) })
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "10" }), { description = "Switch to Workspace 10" })
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }), { description = "Move to Workspace 10" })

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Next Workspace" })
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous Workspace" })

-- Native Hyprland Layer Rules for Frosted Glass Effect
hl.layer_rule({ match = { namespace = "waybar" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "wlogout" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true, ignore_alpha = 0.0 })
hl.layer_rule({ match = { namespace = "launcher" }, blur = true, ignore_alpha = 0.0 })
hl.layer_rule({ match = { namespace = "fuzzel" }, blur = true, ignore_alpha = 0.0 })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.2, animation = "slide right" })

-- Force Telegram to always float so Pyprland can manage its scratchpad geometry
hl.window_rule({
	match = { class = "org.telegram.desktop" },
	float = true,
	size = { "25%", "71%" },
	move = { "74%", "44px" },
	workspace = "special:scratch_telegram silent",
})

-- Compact floating Blueman Manager window
hl.window_rule({
	match = { class = ".*blueman-manager.*" },
	float = true,
	center = true,
	size = { "40%", "50%" },
})

-- File Dialog Titles (covers native app dialogs)
hl.window_rule({
	match = { title = "^(Open File|Save File|Select a File|Choose Files|Save As|Open Folder|Browse.*)" },
	float = true,
	center = true,
	size = { "55%", "60%" },
})

-- XDG Desktop Portals (covers 90% of Wayland GTK/KDE/Flatpak pickers)
hl.window_rule({
	match = { class = ".*desktop-portal.*" },
	float = true,
	center = true,
	size = { "55%", "60%" },
})
