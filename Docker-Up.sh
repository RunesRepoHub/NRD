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


# Spin up a new Docker container using the new image
docker run -d --name $DOCKER_IMAGE_NAME -p 8080:80 $DOCKER_IMAGE_NAME

# Remove the used HTML file
rm $NEWEST_HTML_FILE


