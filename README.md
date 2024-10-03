#Tomcat Docker Setup

## Overview
This project uses Tomcat in the 10.1.28 version to run in a Docker container with SSL/TLS enabled on port 4041.
Regarding the certificates, they are signed during the docker build process.

## Prerequisites
Make sure to have Docker installed

## How to Build and Run the project

1st Step: Build the Docker Image
    Inside the folder that contains the Dockerfile and the PEM files (ca-cert.pem and ca-key.pem), its necessary to run the command to build the Docker Image:

    docker build -t tomcat-ssl .

2nd Step: Run the Docker Container
    Run the command:

    docker run -d -p 4041:4041 tomcat-ssl

3rd Step: Testing
    In a web browser and use the following link:

    https://localhost:4041

    (The page will appear as insecure because of the self-signed certificates)
    