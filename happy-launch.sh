#!/bin/bash
# inspired by: https://www.baeldung.com/linux/shell-script-simple-select-menu

function envi_viewer()
{
  echo "ENVI Viewer..."
  ~/happy/bin/envi-viewer &
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
       2 "ADAMS"
       3 "Start SAM"
       4 "Stop SAM"
       5 "Start SAM-HQ"
       6 "Stop SAM-HQ")

num_items=${#items[@]}
height=$(($num_items/2+7))
width=40

while choice=$(dialog --title "Happy Tools" \
                 --ok-label "Launch" \
                 --cancel-label "Exit" \
                 --menu "Please select" $height $width $num_items "${items[@]}" \
                 2>&1 >/dev/tty)
    do
    case $choice in
        1) envi_viewer;;
        2) adams;;
        3) start_sam;;
        4) stop_sam;;
        5) start_sam_hq;;
        6) stop_sam_hq;;
    esac
done

# clear after user pressed Cancel
clear
