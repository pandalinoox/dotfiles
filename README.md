## Screenshots

![Desktop](/assets/screenshots/screenshot1.png)

![Hyprlock screen](/assets/screenshots/screenshot2.png)

![Rofi](/assets/screenshots/screenshot3.png)

![Apps](/assets/screenshots/screenshot4.png)

## Contents

- `.config/` - application configs (hypr, waybar, rofi, kitty, btop, cava, swaync, wlogout, fastfetch, gh, gh-dash, lazygit, posting, nwg-look, gtk-3.0, gtk-4.0)
- `.zshrc`, `.tmux.conf` - shell and terminal config
- `assets/` - wallpapers and fastfetch images
- `extras/grub_theme/` - custom GRUB theme

## Requirements

- GNU Stow
- The individual applications you want configs for (hyprland, waybar, rofi, kitty, btop, cava, etc.)

## Installation

Clone the repo into your home directory:

```
git clone https://github.com/pandalinoox/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Symlink everything with Stow:

```
stow .
```

This links `.zshrc`, `.tmux.conf`, and everything under `.config/` into `$HOME`, respecting `.stow-local-ignore` (which excludes `extras/` and `assets/` from stowing directly).

To remove the symlinks:

```
stow -D .
```

## GRUB theme

The GRUB theme lives in `extras/grub_theme/dracula_custom` and is not stowed automatically.

1. Copy the theme into GRUB's theme directory:

   ```
   sudo cp -r extras/grub_theme/dracula_custom /boot/grub/themes/dracula_custom
   ```

2. Edit `/etc/default/grub` and set:

   ```
   GRUB_THEME="/boot/grub/themes/dracula_custom/theme.txt"
   ```

3. Regenerate the GRUB config:

   ```
   sudo grub-mkconfig -o /boot/grub/grub.cfg
   ```

   (On some distros this is `sudo update-grub` instead.)

## Wallpapers

Wallpapers live in `assets/wallpapers/`. Point your wallpaper tool (e.g. `swaybg`, `hyprpaper`) at the one you want.
