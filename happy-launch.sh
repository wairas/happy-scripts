#!/bin/bash
# inspired by: https://www.baeldung.com/linux/shell-script-simple-select-menu

function envi_viewer()
{
  echo "ENVI Viewer..."
  ~/happy/bin/happy-envi-viewer --autodetect_channels --redis_connect &
  clear
  exit 0
}

function data_viewer()
{
  echo "Data Viewer..."
  ~/happy/bin/happy-data-viewer &
  clear
  exit 0
}

function raw_checker()
{
  echo "Raw checker..."
  ~/happy/bin/happy-raw-checker &
  clear
  exit 0
}

function adams()
{
  echo "ADAMS..."
  ~/adams/bin/start_gui.sh &
  clear
  exit 0
}

function start_sam()
{
  echo "Starting SAM..."
  ~/sam/start.sh &
  clear
  exit 0
}

function stop_sam()
{
  echo "Stopping SAM..."
  ~/sam/stop.sh &
  clear
  exit 0
}

function start_sam_hq()
{
  echo "Starting SAM-HQ..."
  ~/sam-hq/start.sh &
  clear
  exit 0
}

function stop_sam_hq()
{
  echo "Stopping SAM-HQ..."
  ~/sam-hq/stop.sh &
  clear
  exit 0
}

# do we have dialog installed?
if [ ! -x "/usr/bin/dialog" ]
then
  echo "This script requires the 'dialog' tool, which is currently not installed."
  echo "Press ENTER to install it or CTRL+C to exit."
  read
  sudo apt update && \
    sudo apt install -y dialog
fi

# menu loop
items=(1 "ENVI Viewer"
       2 "HAPPy Data Viewer"
       3 "Raw checker"
       4 "ADAMS"
       5 "Start SAM"
       6 "Stop SAM"
       7 "Start SAM-HQ"
       8 "Stop SAM-HQ")

num_items=${#items[@]}
height=$(($num_items/2+7))
width=40

while choice=$(dialog --title "HAPPy Tools" \
                 --ok-label "Launch" \
                 --cancel-label "Exit" \
                 --menu "Please select" $height $width $num_items "${items[@]}" \
                 2>&1 >/dev/tty)
    do
    case $choice in
        1) envi_viewer;;
        2) data_viewer;;
        3) raw_checker;;
        4) adams;;
        5) start_sam;;
        6) stop_sam;;
        7) start_sam_hq;;
        8) stop_sam_hq;;
    esac
done

# clear after user pressed Cancel
clear
