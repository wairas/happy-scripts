#!/bin/bash
# inspired by: https://www.baeldung.com/linux/shell-script-simple-select-menu

function prepare_system()
{
  echo "Preparing system..."
  sudo apt update && \
    sudo apt -y upgrade && \
    sudo apt -y install virtualenv python3-tk redis redis-server unzip openjdk-11-jdk git
}

function install_happy_tools()
{
  echo "Installing happy tools..."
  rm -Rf ~/happy
  virtualenv --system-site-packages -p /usr/bin/python3 ~/happy
  ~/happy/bin/pip install git+https://github.com/wairas/happy-tools.git
  ~/happy/bin/pip install git+https://github.com/wairas/happy-tools-tkinter.git
  ~/happy/bin/pip install git+https://github.com/wairas/happy-tools-keras.git
  wget --no-cache -O ~/happy-launch.sh https://github.com/wairas/happy-scripts/blob/main/happy-launch.sh?raw=true
  chmod a+x ~/happy-launch.sh
}

function update_happy_tools()
{
  echo "Updating happy tools..."
  ~/happy/bin/pip uninstall -y happy-tools
  ~/happy/bin/pip install --upgrade git+https://github.com/wairas/happy-tools.git
  ~/happy/bin/pip install --upgrade git+https://github.com/wairas/happy-tools-tkinter.git
  ~/happy/bin/pip install --upgrade git+https://github.com/wairas/happy-tools-keras.git
  wget --no-cache -O ~/happy-launch.sh https://github.com/wairas/happy-scripts/blob/main/happy-launch.sh?raw=true
  chmod a+x ~/happy-launch.sh
}

function install_adams()
{
  echo "Installing ADAMS..."
  rm -Rf ~/adams
  wget --no-cache -O ~/adams.zip https://adams.cms.waikato.ac.nz/snapshots/adams/adams-annotator-snapshot-bin.zip
  unzip -q adams.zip
  mv adams-annotator-*-SNAPSHOT adams
}

function install_sam()
{
  echo "Installing SAM..."

  # create dirs
  echo "- creating dirs"
  mkdir -p ~/sam/cache
  mkdir -p ~/sam/models

  # download model
  echo "- downloading model"
  wget --no-cache -O ~/sam/models/sam_vit_l_0b3195.pth https://dl.fbaipublicfiles.com/segment_anything/sam_vit_l_0b3195.pth

  # pulling image
  echo "- pulling docker image"
  docker pull waikatodatamining/pytorch-sam:2023-04-16_cuda11.6

  # scripts
  echo "- creating scripts"
  # start script
  script=~/sam/start.sh
  rm -f $script
  echo "#!/bin/bash" >> $script
  echo "" >> $script
  echo "scriptdir=\`dirname -- \"\$0\";\`" >> $script
  echo "" >> $script
  echo "docker run --pull always --rm \\" >> $script
  echo "  -u \$(id -u):\$(id -g) -e USER=\$USER \\" >> $script
  echo "  -v \$scriptdir/cache:/.cache \\" >> $script
  echo "  -v \$scriptdir:/workspace \\" >> $script
  echo "  --gpus=all --net=host \\" >> $script
  echo "  -t waikatodatamining/pytorch-sam:2023-04-16_cuda11.6 \\" >> $script
  echo "  sam_predict_redis \\" >> $script
  echo "  --redis_in sam_in \\" >> $script
  echo "  --redis_out sam_out \\" >> $script
  echo "  --model /workspace/models/sam_vit_l_0b3195.pth \\" >> $script
  echo "  --model_type vit_l \\" >> $script
  echo "  --verbose" >> $script
  echo "" >> $script
  chmod a+x $script

  # stop script
  script=~/sam/stop.sh
  rm -f $script
  echo "#!/bin/bash" >> $script
  echo "" >> $script
  echo "ids=\`ps a | grep [s]am_predict_redis | sed s/\"^[ ]*\"//g | cut -f1 -d\" \"\`" >> $script
  echo "for id in \$ids" >> $script
  echo "do" >> $script
  echo "  kill -9 \$id" >> $script
  echo "done" >> $script
  chmod a+x $script

  echo "- done!"
}

function install_sam_hq()
{
  echo "Installing SAM-HQ..."

  # create dirs
  echo "- creating dirs"
  mkdir -p ~/sam-hq/cache
  mkdir -p ~/sam-hq/models

  # download model
  echo "- downloading model"
  wget -O ~/sam-hq/models/sam_hq_vit_l.pth https://huggingface.co/lkeab/hq-sam/resolve/main/sam_hq_vit_l.pth

  # pulling image
  echo "- pulling docker image"
  docker pull waikatodatamining/pytorch-sam-hq:2023-08-17_cuda11.6

  # scripts
  echo "- creating scripts"
  # start script
  script=~/sam-hq/start.sh
  rm -f $script
  echo "#!/bin/bash" >> $script
  echo "" >> $script
  echo "scriptdir=\`dirname -- \"\$0\";\`" >> $script
  echo "" >> $script
  echo "docker run --pull always --rm \\" >> $script
  echo "  -u \$(id -u):\$(id -g) -e USER=\$USER \\" >> $script
  echo "  -v \$scriptdir/cache:/.cache \\" >> $script
  echo "  -v \$scriptdir:/workspace \\" >> $script
  echo "  --gpus=all --net=host \\" >> $script
  echo "  -t waikatodatamining/pytorch-sam-hq:2023-08-17_cuda11.6 \\" >> $script
  echo "  samhq_predict_redis \\" >> $script
  echo "  --redis_in sam_in \\" >> $script
  echo "  --redis_out sam_out \\" >> $script
  echo "  --model /workspace/models/sam_hq_vit_l.pth \\" >> $script
  echo "  --model_type vit_l \\" >> $script
  echo "  --verbose" >> $script
  echo "" >> $script
  chmod a+x $script

  # stop script
  script=~/sam-hq/stop.sh
  rm -f $script
  echo "#!/bin/bash" >> $script
  echo "" >> $script
  echo "ids=\`ps a | grep [s]amhq_predict_redis | sed s/\"^[ ]*\"//g | cut -f1 -d\" \"\`" >> $script
  echo "for id in \$ids" >> $script
  echo "do" >> $script
  echo "  kill -9 \$id" >> $script
  echo "done" >> $script
  chmod a+x $script

  echo "- done!"
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
items=(1 "Prepare system"
       2 "Install Happy Tools"
       3 "Update Happy Tools"
       4 "Install ADAMS"
       5 "Install SAM"
       6 "Install SAM-HQ")

num_items=${#items[@]}
height=$(($num_items/2+7))
width=40

while choice=$(dialog --title "Happy Tools Setup" \
                 --cancel-label "Exit" \
                 --menu "Please select" $height $width $num_items "${items[@]}" \
                 2>&1 >/dev/tty)
    do
    case $choice in
        1) prepare_system;;
        2) install_happy_tools;;
        3) update_happy_tools;;
        4) install_adams;;
        5) install_sam;;
        6) install_sam_hq;;
    esac
done

# clear after user pressed Cancel
clear
