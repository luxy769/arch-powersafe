#!/bin/bash

MAX_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
MIN_FREQ=800000
CURRENT_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)

show_menu() {
    echo ":"
    echo "1) find out the current frequency CPU"
    echo "2) limit frequency to 800Mhz"
    echo "3) restore maximum frequency ($MAX_FREQ)"
    echo "4) total powersafe"
    echo "5) bring everything back"
    echo "6) exit"
    echo -n "choise: "
}

change_freq() {
    local freq=$1
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
        echo $freq | sudo tee $cpu >/dev/null
    done
}

while true; do
    show_menu
    read -r choice

    case $choice in
        1)
            echo "current frequency:"
            cat /proc/cpuinfo | grep "MHz"
            ;;
        2)
            echo "frequency limitation up to..."
            change_freq $MIN_FREQ
            echo "✅ frequency is limited to 800 МГц"
            ;;
        3)
            echo "restore maximum frequency ($MAX_FREQ)..."
            change_freq $MAX_FREQ
            echo "✅ frequency restored to maximum ($MAX_FREQ)"
            ;;
        4)
            echo "make total powersafe..."
            
            echo "turn off swap..."
            sudo swapoff -a

            echo "/etc/fstab..."
            sudo sed -i 's/errors=remount-ro/errors=remount-ro,noatime,nodiratime/g' /etc/fstab

      
            echo "switch the cpu to power saving..."
            for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
                echo "powersave" | sudo tee $cpu >/dev/null
            done

            #iGPU (Intel)
            echo "optimization igpu..."
            echo "options i915 enable_psr=1" | sudo tee /etc/modprobe.d/i915.conf
            sudo update-initramfs -u
            
            echo "✅Full power saving enabled. Restart your system."
            ;;
        5)
            echo "🔄 restore default settings..."

            echo "turn on swap..."
            sudo swapon -a
           
            echo "delete noatime из /etc/fstab..."
            sudo sed -i 's/errors=remount-ro,noatime,nodiratime/errors=remount-ro/g' /etc/fstab

            echo "recovery CPU governor..."
            for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
                echo "performance" | sudo tee $cpu >/dev/null
            done

            echo "delete settings i915..."
            sudo rm -f /etc/modprobe.d/i915.conf
            sudo update-initramfs -u

            echo "✅ recovery complete. reboot system for full application"
            ;;
        6)
            echo "Exit..."
            exit 0
            ;;
        *)
            echo "❌ Invalid input. Please try again.."
            ;;
    esac

    echo -e "\nturn Enter for continue..."
    read
done

