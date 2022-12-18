#!/usr/bin/env bash

BAT=$(echo /sys/class/power_supply/BAT*)
BAT_STATUS="$BAT/status"
BAT_CAP="$BAT/capacity"

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

# wait a while if needed
[[ -z $STARTUP_WAIT ]] || sleep "$STARTUP_WAIT"

# add error margin to the charge limit
chargeLimit=$BAT_CHG_LIMIT-1

# start the monitor loop
prev=0

# while the battery % is below the charge limit
while true; do

	if [[ $(cat "$BAT_CAP") -lt $chargeLimit ]]; then

	        # read the current state
        	if [[ $(cat "$BAT_STATUS") == "Discharging" ]]; then
                	if [[ $(cat "$BAT_CAP") -gt $LOW_BAT_PERCENT ]]; then
                        	profile=$BAT_PROFILE
				refresh=$LOW_REFRESH_RATE
				fans="Quiet"
        	        else
                	    	profile=$LOW_BAT_PROFILE
				refresh=$LOW_REFRESH_RATE
				fans="Quiet"
	                fi
        	else
            		profile=$AC_PROFILE
			refresh=$HIGH_REFRESH_RATE
			fans="Performance"
        	fi

	        # if the profile is different
        	if [[ $prev != "$profile" ]]; then

                	# set the new profile
	                echo Switching to $profile\.
        	        powerprofilesctl set $profile

	                # set fan curves
			echo Setting fan mode to $fans.
                	asusctl profile -P $fans

			if [[ $CHANGE_REFRESH == "True" ]]; then
				# set internal display refresh rate
				echo Setting refresh rate to $refresh Hz.
				gnome-monitor-config set -Lp -M $MONITOR_NAME -m 2560x1600@$refresh
			fi
		fi

		prev=$profile
	fi

	# wait for the next power change event
	inotifywait -qq "$BAT_STATUS" "$BAT_CAP"
done
