# Change Gnome power profile on laptop plug/unplug

This service is adapted from https://kobusvs.co.za/blog/power-profile-switching/ - full credit to the original author Kobus van Schoor.

I've just put it here for my convenience and in case anyone finds it useful for their specific use case. My use case is with Fedora and an ASUS G14 2022 model (so, using https://gitlab.com/asus-linux/asusctl to control fans).

## What it does

When you unplug the laptop:
- Sets the power profile to `power-saver`
- Resets the fan curves via `asusctl`
- Reduces the display refresh rate as specified in preferences

When you plug it back in:
- Sets the profile to `performance`
- Resets fan curves via `asusctl`
- Increases display refresh rate as specified in preferences

You can adjust all of these settings by configuring the variables in `~/.local/bin/power-monitor.sh`

```bash
# configure your preferences
LOW_BAT_PERCENT=20              # recommended between 10 and 30
BAT_CHG_LIMIT=70                # use 100, unless you've configured a battery charge limit

AC_PROFILE="performance"        # "performance" or "balanced"
BAT_PROFILE="power-saver"       # "balanced" or "power-saver"
LOW_BAT_PROFILE="power-saver"   # "balanced" or "power-saver"

CHANGE_REFRESH="True"
MONITOR_NAME="eDP-1"		# Use `gnome-monitor-config list` to find
LOW_REFRESH_RATE="59.987"       # must be precise
HIGH_REFRESH_RATE="165.040"     # must be precise
```

## Prerequisites

If you have an ASUS notebook, start by following the guides at https://asus-linux.org to install your OS. This provides the best support and will set up `asusctl`.

## Installing

Install dependencies for the script:
`dnf install inotify-tools gnome-monitor-config`

Copy the two files to their respective folders then make the script executable:
```bash
git clone https://github.com/sammilucia/power-monitor
cd power-monitor
cp .local/bin/power-monitor.sh ~/.local/bin/      # or to ~/.local/sbin/ if you prefer
cp .config/systemd/user/power-monitor.service ~/.config/systemd/user/
chmod +x ~/.local/bin/power-monitor.sh
```

Configure your preferences in `~/.local/bin/power-monitor.sh` per the instructions.

Start the service:

`systemctl --user enable --now power-monitor.service`

## Using

To use simply unplug your laptop. There are a few scenarios when you unplug:
1. If the battery is within 1% of the charge limit (by default), nothing will happen
2. When the battery falls 1% below the charge limit, it will switch to power-saver (or whatever you chose), reduce the refresh rate, and switch fan curves.

When you plug back in:
1. It will switch to performance (or whatever you chose), increase screen refresh rate, and switch fans.

You can get status of the service with:
`systemctl --user status power-monitor.service`

When you change anything in `power-monitor.sh`, you need to restart the service:
`systemctl --user restart power-monitor.service`

## Uninstalling

```bash
systemctl --user disable --now power-monitor.service
dnf remove gnome-monitor-config inotify-tools
rm ~/.local/bin/power-monitor.sh ~/.config/systemd/user/power-monitor.service
```
