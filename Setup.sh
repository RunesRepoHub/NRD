#!/bin/bash

echo "Enter the branch you want to clone: "
read BRANCH

cd

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

git clone --branch $BRANCH https://github.com/RunesRepoHub/NRD.git


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

bash ./Pull-News.sh