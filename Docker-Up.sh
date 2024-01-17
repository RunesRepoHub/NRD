#!/bin/bash

cd ~/NRD

# Set the directory where the HTML files are stored and the name for the new Docker image
HTML_DIR="$(dirname "$0")"
DOCKER_IMAGE_NAME="news-report"
HTML_FILE=~/NRD/index.html

if sudo docker inspect -f '{{.State.Running}}' $DOCKER_IMAGE_NAME 2>/dev/null; then
    sudo docker stop $DOCKER_IMAGE_NAME
    sudo docker rm $DOCKER_IMAGE_NAME
else
    echo "Docker container $DOCKER_IMAGE_NAME is not running."
fi

# Build a new Docker image using the newest HTML file
sudo docker build -t $DOCKER_IMAGE_NAME ~/NRD 

# Spin up a new Docker container using the new image
sudo docker run -d --name $DOCKER_IMAGE_NAME -p 2323:80 $DOCKER_IMAGE_NAME

# Remove the used HTML file
rm $HTML_FILE


