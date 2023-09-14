#!/bin/bash
# inspired by: https://www.baeldung.com/linux/shell-script-simple-select-menu

function envi_viewer()
{
  echo "ENVI Viewer..."
  ~/happy/bin/envi-viewer &
  exit 0
}

function start_sam()
{
  echo "Starting SAM..."
  ~/sam/start.sh &
  exit 0
}

function stop_sam()
{
  echo "Stopping SAM..."
  ~/sam/stop.sh &
  exit 0
}

function start_sam_hq()
{
  echo "Starting SAM-HQ..."
  ~/sam-hq/start.sh &
  exit 0
}

function stop_sam_hq()
{
  echo "Stopping SAM-HQ..."
  ~/sam-hq/stop.sh &
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
       2 "Start SAM"
       3 "Stop SAM"
       4 "Start SAM-HQ"
       5 "Stop SAM-HQ")

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
        2) start_sam;;
        3) stop_sam;;
        4) start_sam_hq;;
        5) stop_sam_hq;;
    esac
done

# clear after user pressed Cancel
clear
