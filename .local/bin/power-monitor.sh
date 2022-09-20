#! /bin/bash

BAT=$(echo /sys/class/power_supply/BAT*)
BAT_STATUS="$BAT/status"
BAT_CAP="$BAT/capacity"
LOW_BAT_PERCENT=20
BAT_CHG_LIMIT=80

AC_PROFILE="performance"
BAT_PROFILE="power-saver"
LOW_BAT_PROFILE="power-saver"

LOW_REFRESH_RATE=60
HIGH_REFRESH_RATE=120

# wait a while if needed
[[ -z $STARTUP_WAIT ]] || sleep "$STARTUP_WAIT"

# add error margin to the charge limit
chargeLimit=$BAT_CHG_LIMIT-2

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
        	        else
                	    	profile=$LOW_BAT_PROFILE
				refresh=$LOW_REFRESH_RATE
	                fi
        	else
            		profile=$AC_PROFILE
			refresh=$HIGH_REFRESH_RATE
        	fi

	        # if the profile is different
        	if [[ $prev != "$profile" ]]; then

                	# set the new profile
	                echo Switching to $profile\.
        	        powerprofilesctl set $profile

	                # reset the fan curves
			echo Resetting fans.
                	asusctl fan-curve -m "balanced" -f cpu -D "20c:0%,40c:0%,50c:0%,60c:5%,70c:15%,80c:40%,90c:70%,100c:80%"
	                asusctl fan-curve -m "balanced" -f gpu -D "20c:0%,40c:0%,50c:0%,60c:5%,70c:15%,80c:40%,90c:70%,100c:80%"

			# set internal display refresh rate
			echo Setting refresh rate to $refresh Hz.
			gnome-monitor-config set -Lp -M eDP-2 -m 2560x1600@$refresh &>/dev/null
		fi

		prev=$profile
	fi

	# wait for the next power change event
	inotifywait -qq "$BAT_STATUS" "$BAT_CAP"
done
