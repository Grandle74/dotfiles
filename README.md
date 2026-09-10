
<br>

<div align="center">

![](.preview/screenshot.png)

# grandle's Hyprland Rice

A minimal, Pywal-themed Hyprland setup with dynamic colour schemes, custom menus, and a built-in Pomodoro timer.

**Hyprland · Waybar · Kitty · Fuzzel · Mako · Pywal**

</div>

---

## Dependencies

> [!TIP]
> Package names vary across distributions. If you're unsure what a package is called on your system, ask your AI assistant. For example:
> *"What is the package name for `wf-recorder` on [your distro]?"*
> Also, Check if you have a package installed before installing a dependency.

### Required

| Purpose | Packages |
|---------|----------|
| Compositor | `hyprland` `hyprpaper` `hyprlock` `hypridle` `hyprshot` |
| Output management | `kanshi` |
| Status bar | `waybar` |
| Terminal | `kitty` |
| App launcher & menus | `fuzzel` |
| Notifications | `mako` `libnotify` |
| Theming | `pywal` `python-colorthief` |
| Screenshot & recording | `grim` `slurp` `wf-recorder` `imagemagick` |
| Clipboard | `cliphist` `wl-clipboard` |
| Audio | `pipewire` `wireplumber` `libpulse` |
| Network | `networkmanager` |
| Bluetooth | `bluez` `blueman` |
| Backlight | `brightnessctl` |
| Polkit agent | `polkit-gnome` |
| Scratchpads | `pyprland` |
| Power menu | `wlogout` |
| Recording tray | `yad` |
| Pomodoro sounds | `libcanberra` |
| XDG portals | `xdg-desktop-portal-hyprland` |
| JSON parsing | `jq` |

### Fonts

| Font | Used in |
|------|---------|
| **JetBrains Mono** (Nerd Font variant recommended) | Lock screen clock & date |
| **Hurmit Nerd Font** *(patched Hermit)* | Fuzzel menus — network, sound, clipboard |

> [!NOTE]
> **JetBrains Mono** is widely packaged — search your distro's package manager for `jetbrains-mono` or `ttf-jetbrains-mono-nerd`.

#### Installing Hurmit Nerd Font

**Hurmit** is the Nerd Font patched version of *Hermit*. It may not be in your package manager — install it manually:

1. Download the `Hermit.zip` from the [Nerd Fonts releases page](https://github.com/ryanoasis/nerd-fonts/releases/latest)
2. Unzip and install all font files at once:

```bash
unzip Hermit.zip -d Hurmit
mkdir -p ~/.local/share/fonts
find Hurmit -name "*.otf" -o -name "*.ttf" | xargs cp -t ~/.local/share/fonts/
fc-cache -fv
```

> [!TIP]
> The `find ... | xargs cp -t` pattern works for any Nerd Font zip — just swap out the folder name.

### Cursor

The config uses the **BreezeX-Black** cursor theme — included in this repo under `MouseCursor/`.
See the [Cursor installation](#cursor) section below.

---

## Installation

> [!IMPORTANT]
> Back up your existing configs before applying. `stow --adopt` will overwrite files in your home directory.

### 1. Clone the repo

```bash
git clone https://github.com/Grandle74/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Apply configs with GNU Stow (symlink method)

This symlinks all rice config folders into your home directory.
`Wallpapers`, `MouseCursor`, and `.preview` are excluded — they are handled separately below.

```bash
stow --adopt !(Wallpapers|MouseCursor|.preview|README.md)
```

> [!NOTE]
> The `!(...)` syntax requires `bash` with `extglob` enabled (it is by default in most shells).
> If you get an error, run `shopt -s extglob` first, or list each folder manually:
> ```bash
> stow --adopt Fuzzel Hyprland Kanshi Kitty Mako Pypr Wal Waybar Wlogout
> ```

### 3. Copy wallpapers

Wallpapers should be copied, not symlinked, so Hyprpaper and Pywal can read them reliably.

```bash
mkdir -p ~/Pictures/.HyprPaper
cp -r Wallpapers/Pictures/.HyprPaper/. ~/Pictures/.HyprPaper/
```

### 4. Install the cursor theme <a name="cursor"></a>

The BreezeX-Black cursor is bundled in `MouseCursor/`. Copy it to your local icons directory:

```bash
mkdir -p ~/.local/share/icons
cp -r MouseCursor/.local/share/icons/BreezeX-Black ~/.local/share/icons/
```

---

## Alternative: Direct Copy (no symlinks)

If you prefer to copy files directly instead of using Stow:

```bash
# Config files
cp -r Fuzzel/.config/fuzzel        ~/.config/
cp -r Hyprland/.config/hypr        ~/.config/
cp -r Kanshi/.config/kanshi        ~/.config/
cp -r Kitty/.config/kitty          ~/.config/
cp -r Mako/.config/mako            ~/.config/
cp -r Pypr/.config/pypr            ~/.config/
cp -r Wal/.config/wal              ~/.config/
cp -r Waybar/.config/waybar        ~/.config/
cp -r Wlogout/.config/wlogout      ~/.config/

# Wallpapers
mkdir -p ~/Pictures/.HyprPaper
cp -r Wallpapers/Pictures/.HyprPaper/. ~/Pictures/.HyprPaper/

# Cursor theme
mkdir -p ~/.local/share/icons
cp -r MouseCursor/.local/share/icons/BreezeX-Black ~/.local/share/icons/
```

---

## First Run

After applying the configs, log into a Hyprland session. On first launch:

1. **Generate a colour scheme** — press `Super + Tab` to apply a random wallpaper + theme.
2. **Pywal** needs to run at least once to populate `~/.cache/wal/` before colours apply to Waybar, Fuzzel, Mako, and Kitty.

> [!WARNING]
> If Waybar or Fuzzel appear unstyled on first boot, run `Super + Tab` (wallpaper + theme) to generate the Pywal cache. Hyprland will be reloaded automatically, and if not, reload it manually with `Super + Shift + R`.

---

## Key Bindings (highlights)

> [!TIP]
> Use `Super + Shift + K` to show all keybindings.

---

<div align="center">
<sub>feel free to fork and adapt</sub>
</div>
