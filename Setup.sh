#!/bin/bash

echo "Enter the branch you want to clone: "
echo "Production or Dev"
read BRANCH

cd

# Use xmlstarlet or similar tool to parse XML; install if necessary
if ! command -v xmlstarlet &> /dev/null; then
    echo "Installing xmlstarlet..."
    sudo apt-get install -y xmlstarlet
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

# Run the Pull-News script and wait for it to finish before continuing
bash ./Pull-News.sh && echo "Pull-News script completed."

#!/bin/bash

# Set the directory where the HTML files are stored and the name for the new Docker image
HTML_DIR="$(dirname "$0")"
DOCKER_IMAGE_NAME="news-report"

# Find the newest HTML file in the specified directory
NEWEST_HTML_FILE=$(ls -t $HTML_DIR/*.html | head -n 1)

# Check if an HTML file was found
if [[ -z "$NEWEST_HTML_FILE" ]]; then
  echo "No HTML files found in directory $HTML_DIR."
  exit 1
fi

# Build a new Docker image using the newest HTML file
docker build -t $DOCKER_IMAGE_NAME . 

docker stop $DOCKER_IMAGE_NAME
docker rm $DOCKER_IMAGE_NAME

# Ask the user for the port to expose
echo "Enter the port to expose for the Docker container (default is 8080):"
read -p "Enter the port to expose for the Docker container: " host_port

# Validate the input is a number or if it's empty
if ! [[ "$host_port" =~ ^[0-9]+$ ]] && [[ -n "$host_port" ]]; then
    echo "Invalid port number. Please enter a numeric value."
    exit 1
fi

# Set the port to 8080 if no input was provided
host_port=${host_port:-8080}

# Spin up a new Docker container using the new image
docker run -d --name $DOCKER_IMAGE_NAME -p $host_port:80 $DOCKER_IMAGE_NAME

# Remove the used HTML file
rm $NEWEST_HTML_FILE


