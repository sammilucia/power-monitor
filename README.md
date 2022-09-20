# Change Gnome power profile on laptop plug/unplug

This service is adapted from https://kobusvs.co.za/blog/power-profile-switching/ - full credit to the original author Kobus van Schoor.

I've just put it here for my convenience and in case anyone finds it useful for their specific use case. My use case is with Fedora and an ASUS G14 2022 model (so, using https://gitlab.com/asus-linux/asusctl to control fans).

## What it does

When you unplug the laptop:
- Sets the power profile to `power-saver`
- Resets the fan curves
- Reduces the display refresh to 60 Hz

When you plug it back in:
- Sets the profile to `performance`
- Resets fan curves
- Increases display profile to 120 Hz

You can adjust all of these settings by configuring the variables in `~/.local/bin/power-monitor.sh`

```
# configure your preferences
LOW_BAT_PERCENT=20              # recommended between 10 and 30
BAT_CHG_LIMIT=80                # use 100, unless you've configured a battery charge limit

AC_PROFILE="performance"        # "performance" or "balanced"
BAT_PROFILE="power-saver"       # "balanced" or "power-saver"
LOW_BAT_PROFILE="power-saver"   # "balanced" or "power-saver"

LOW_REFRESH_RATE=60             # decimal (check your display supports it)
HIGH_REFRESH_RATE=120           # decimal (check your display supports it)
```

## Prerequisites

If you have an ASUS notebook, start by following the guides at https://asus-linux.org to install your OS. This provides the best support and will set up `asusctl`.

Then install dependencies for this script with:
`dnf install inotify-tools gnome-monitor-config`

## Installing

Copy the two files to their respective folders then make the script executable:
`chmod +x ~/.local/bin/power-monitor.sh`

Start the service:
`systemctl --user enable --now power-monitor.service`
