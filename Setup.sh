#!/bin/bash

echo "Enter the branch you want to clone: "
read BRANCH

cd

# Use xmlstarlet or similar tool to parse XML; install if necessary
if ! command -v xmlstarlet &> /dev/null; then
    echo "Installing xmlstarlet..."
    sudo apt-get install -y xmlstarlet
fi

# Install 'dialog' if not already installed
if ! command -v dialog &> /dev/null; then
    echo "Installing 'dialog'..."
    sudo apt-get install dialog
fi

# Check if git is installed
if command -v git &> /dev/null; then
    echo "git is installed."
else
    echo "git is not installed. Do you want to install it now? (yes/no)"
    read install_answer
    if [[ $install_answer == "yes" ]]; then
        sudo apt-get update && sudo apt-get install git -y
        if command -v git &> /dev/null; then
            echo "git has been successfully installed."
        else
            echo "Failed to install git. Aborting script."
            exit 1
        fi
    else
        echo "User opted not to install git. Aborting script."
        exit 1
    fi
fi


# Check if the NRD directory already exists
if [ -d "NRD" ]; then
    echo "NRD directory already exists. Pulling latest changes from branch $BRANCH."
    cd NRD
    git pull --ff-only origin $BRANCH
else
    echo "Cloning NRD repository from branch $BRANCH."
    git clone --branch $BRANCH https://github.com/RunesRepoHub/NRD.git
fi


# Function to check if a cron job exists
cron_job_exists() {
    local cron_command="$1"
    grep -qF "$cron_command" /etc/crontab
}

# Function to add a cron job
add_cron_job() {
    local cron_command="$1"
    echo "$cron_command" | sudo tee -a /etc/crontab >/dev/null
    echo "Cron job added: $cron_command"
}

# The cron job command to be added
pull_news_job="0 6 * * * root ~/NRD/Pull-News.sh"

# Check if the cron job has already been added, if not, add it
if ! cron_job_exists "$pull_news_job"; then
    add_cron_job "$pull_news_job"
else
    echo "Cron job for Pull-News.sh already exists in /etc/crontab"
fi

alias news="bash ~/NRD/Pull-News.sh"
echo 'alias news="bash ~/NRD/Pull-News.sh"' >> ~/.bashrc

bash ~/NRD/Pull-News.sh