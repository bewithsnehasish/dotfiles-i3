#!/usr/bin/env bash

# Set the configuration file path
config_file="$HOME/.config/i3/battery_notify.conf"

# Function to create default configuration
create_default_config() {
    mkdir -p "$(dirname "$config_file")"
    cat > "$config_file" <<EOF
# Battery thresholds
battery_full_threshold=100
battery_critical_threshold=5
unplug_charger_threshold=80
battery_low_threshold=20

# Timers and intervals
timer=120
notify=1140
interval=5

# Actions to execute
execute_critical="systemctl suspend"
execute_low="notify-send 'Battery Low' 'Please connect the charger'"
execute_unplug="notify-send 'Battery Charged' 'You can unplug the charger'"
execute_charging="notify-send 'Charging' 'Battery is now charging'"
execute_discharging="notify-send 'Discharging' 'Battery is now discharging'"

# Other variables
mnt=60
EOF
    echo "Created default configuration file at $config_file"
}

# Check if config file exists, if not, create it
if [ ! -f "$config_file" ]; then
    create_default_config
fi

# Load configuration
source "$config_file"

# Function to display configuration information
config_info() {
    cat <<EOF

Configuration file: $config_file

      STATUS      THRESHOLD    INTERVAL
      Full        $battery_full_threshold          $notify Minutes
      Critical    $battery_critical_threshold           $timer Seconds then '$execute_critical'
      Low         $battery_low_threshold           $interval Percent    then '$execute_low'
      Unplug      $unplug_charger_threshold          $interval Percent   then '$execute_unplug'

      Charging: $execute_charging
      Discharging: $execute_discharging
EOF
}

# Check if the system is a laptop
is_laptop() {
    if grep -q "Battery" /sys/class/power_supply/BAT*/type; then
        return 0  # It's a laptop
    else
        echo "No battery detected. If you think this is an error, please report it."
        exit 0  # It's not a laptop
    fi
}

# Function for verbose output
fn_verbose() {
    if $verbose; then
        cat << VERBOSE
=============================================
        Battery Status: $battery_status
        Battery Percentage: $battery_percentage
=============================================
VERBOSE
    fi
}

# Function to send notifications
fn_notify() {
    notify-send -a "Power" $1 -u $2 "$3" "$4" -p
}

# Function to handle battery percentage notifications
fn_percentage() {
    if [[ "$battery_percentage" -ge "$unplug_charger_threshold" ]] && [[ "$battery_status" != "Discharging" ]] && [[ "$battery_status" != "Full" ]] && (( (battery_percentage - last_notified_percentage) >= $interval )); then
        fn_notify "-t 5000 " "CRITICAL" "Battery Charged" "Battery is at $battery_percentage%. You can unplug the charger!"
        last_notified_percentage=$battery_percentage
    elif [[ "$battery_percentage" -le "$battery_critical_threshold" ]]; then
        count=$(( timer > $mnt ? timer : $mnt ))
        while [ $count -gt 0 ] && [[ $battery_status == "Discharging"* ]]; do
            for battery in /sys/class/power_supply/BAT*; do battery_status=$(< "$battery/status"); done
            if [[ $battery_status != "Discharging" ]]; then break; fi
            fn_notify "-t 5000 -r 69 " "CRITICAL" "Battery Critically Low" "$battery_percentage% is critically low. Device will execute $execute_critical in $((count/60)):$((count%60))."
            count=$((count-1))
            sleep 1
        done
        [ $count -eq 0 ] && fn_action
    elif [[ "$battery_percentage" -le "$battery_low_threshold" ]] && [[ "$battery_status" == "Discharging" ]] && (( (last_notified_percentage - battery_percentage) >= $interval )); then
        fn_notify "-t 5000 " "CRITICAL" "Battery Low" "Battery is at $battery_percentage%. Connect the charger."
        last_notified_percentage=$battery_percentage
    fi
}

# Function to handle critical battery action
fn_action() {
    nohup $execute_critical
}

# Function to handle battery status changes
fn_status() {
    if [[ $battery_percentage -ge $battery_full_threshold ]] && [[ "$battery_status" != *"Discharging"* ]]; then
        battery_status="Full"
    fi
    
    case "$battery_status" in
        "Discharging")
            if [[ "$prev_status" != "Discharging" ]] || [[ "$prev_status" == "Full" ]]; then
                prev_status=$battery_status
                urgency=$([[ $battery_percentage -le "$battery_low_threshold" ]] && echo "CRITICAL" || echo "NORMAL")
                fn_notify "-t 5000 -r 54321 " "$urgency" "Charger Unplugged" "Battery is at $battery_percentage%."
                $execute_discharging
            fi
            fn_percentage
            ;;
        "Not"*|"Charging")
            if [[ "$prev_status" == "Discharging" ]] || [[ "$prev_status" == "Not"* ]]; then
                prev_status=$battery_status
                urgency=$([[ "$battery_percentage" -ge $unplug_charger_threshold ]] && echo "CRITICAL" || echo "NORMAL")
                fn_notify "-t 5000 -r 54321 " "$urgency" "Charger Plugged In" "Battery is at $battery_percentage%."
                $execute_charging
            fi
            fn_percentage
            ;;
        "Full")
            if [[ $battery_status != "Discharging" ]]; then
                now=$(date +%s)
                if [[ "$prev_status" == *"harging"* ]] || ((now - lt >= $((notify*60)) )); then
                    fn_notify "-t 5000 -r 54321" "CRITICAL" "Battery Full" "Please unplug your Charger"
                    prev_status=$battery_status
                    lt=$now
                    $execute_charging
                fi
            fi
            ;;
        *)
            echo "Unknown battery status: $battery_status"
            fn_percentage
            ;;
    esac
}

# Function to get battery information
get_battery_info() {
    total_percentage=0
    battery_count=0
    for battery in /sys/class/power_supply/BAT*; do
        battery_status=$(< "$battery/status")
        battery_percentage=$(< "$battery/capacity")
        total_percentage=$((total_percentage + battery_percentage))
        battery_count=$((battery_count + 1))
    done
    battery_percentage=$((total_percentage / battery_count))
}

# Function to handle status changes
fn_status_change() {
    get_battery_info
    local executed_low=false
    local executed_unplug=false

    if [ "$battery_status" != "$last_battery_status" ] || [ "$battery_percentage" != "$last_battery_percentage" ]; then
        last_battery_status=$battery_status
        last_battery_percentage=$battery_percentage
        fn_verbose
        fn_percentage

        if [[ "$battery_percentage" -le "$battery_low_threshold" ]] && ! $executed_low; then
            $execute_low
            executed_low=true
            executed_unplug=false
        fi
        if [[ "$battery_percentage" -ge "$unplug_charger_threshold" ]] && ! $executed_unplug; then
            $execute_unplug
            executed_unplug=true
            executed_low=false
        fi

        fn_status
    fi
}

# Main function
main() {
    is_laptop
    config_info
    
    get_battery_info
    last_notified_percentage=$battery_percentage
    prev_status=$battery_status
    
    dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',path='$(upower -e | grep battery)'" 2> /dev/null | 
    while read -r battery_status_change; do
        fn_status_change
    done
}

# Parse command line arguments
verbose=false
case "$1" in
    -m|--modify)
        EDITOR="${EDITOR:-nano}"
        $EDITOR "$config_file"
        exit 0
        ;;
    -i|--info)
        config_info
        exit 0
        ;;
    -v|--verbose)
        verbose=true
        ;;
    -h|--help)
        echo "Usage: $0 [-m|--modify] [-i|--info] [-v|--verbose] [-h|--help]"
        exit 0
        ;;
esac

# Run the main function
main
