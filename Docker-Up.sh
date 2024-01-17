#!/bin/bash

cd ~/NRD

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
sudo docker build -t $DOCKER_IMAGE_NAME . 

sudo docker stop $DOCKER_IMAGE_NAME
sudo docker rm $DOCKER_IMAGE_NAME


# Validate the input is a number or if it's empty
if ! [[ "$host_port" =~ ^[0-9]+$ ]] && [[ -n "$host_port" ]]; then
    echo "Invalid port number. Please enter a numeric value."
    exit 1
fi

# Set the port to 8383 if no input was provided
host_port=${host_port:-8383}

# Spin up a new Docker container using the new image
sudo docker run -d --name $DOCKER_IMAGE_NAME -p $host_port:80 $DOCKER_IMAGE_NAME

# Remove the used HTML file
rm $NEWEST_HTML_FILE


