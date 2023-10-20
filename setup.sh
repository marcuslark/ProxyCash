#!/bin/bash

#######################################################################
#Author, Marcuslark
#Marcus Lärk Ståhlberg
 #Fullstack, DevOps & Secure Developer
 #Java, Golang, C#, JavaScript
#######################################################################

# Setting up custom colors
red() { echo -e "\033[31m\033[01m$1\033[0m"; }
green() { echo -e "\033[32m\033[01m$1\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$1$2\033[0m"; }
reading(){ read -rp "$(green "$1")" "$2"; }

# Check if the script is run with sudo privileges
if [ "$EUID" -ne 0 ]; then
    red "This script requires superuser privileges. Please run it with 'sudo'."
    exit 1
fi

# Function to check if a command is installed
command_exists() {
    command -v "$1" &>/dev/null
}

# Function to get the version of a command
get_version() {
    version=$("$1" --version)
    if [[ $version =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
        echo "$(green "${BASH_REMATCH[1]}")"
    else
        echo "version"
    fi
}

# Check if a command is installed and color accordingly
check_and_color() {
    if command_exists "$1"; then
        local version=$(get_version "$1")
        if [ "$version" == "version" ]; then
            echo -e "$(red "[X]") $(yellow "$1") (Version $version)"
        else
            echo -e "$(green "[X]") $(yellow "$1") $(yellow "(Version") $version)"
        fi
    else
        echo -e "$(red "[-]") $(yellow "$1")"
        if [[ "$1" == "docker" ]]; then
            echo -e "Docker is not installed. Install it from https://docs.docker.com/get-docker/"
        elif [[ "$1" == "docker-compose" ]]; then
            echo -e "Docker Compose is not installed. Install it from https://docs.docker.com/compose/install/"
        fi
    fi
}

# Check if Docker is installed
if ! command_exists "docker"; then
    red "Docker is not installed. Install it from https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker-Compose is installed
if ! command_exists "docker-compose"; then
    red "Docker Compose is not installed. Install it from https://docs.docker.com/compose/install/"
    exit 1
fi

# Check if Docker and Docker-Compose are installed
docker_status=$(check_and_color   "docker")
compose_status=$(check_and_color  "docker-compose")

# Display pretty output
echo -e "$(green "Libraries Found:")"
echo -e "$docker_status"
echo -e "$compose_status"

# Check if Docker and Docker-Compose are both installed
if [[ "$docker_status" == *"[X]"* ]] && [[ "$compose_status" == *"[X]"* ]]; then
    echo -e "$(green "Yay, you have both Docker and Docker-Compose installed!")"
    read -p "Do you want to continue? (y/n): " -r continue_choice
    if [[ $continue_choice =~ ^[Yy]$ ]]; then
        green "Continuing..."
    else
        red "Aborted."
        exit 1
    fi
else
    red "Docker and/or Docker Compose is not installed. Install it from https://docs.docker.com/compose/install/"
    read -p "Continue anyway? (y/n): " -r continue_choice
    if [[ $continue_choice =~ ^[Yy]$ ]]; then
        green "Continuing..."
    else
        red "Aborted."
        exit 1
    fi
fi

# Prompt user to read the license file
read -p "Do you want to read the LICENSE file? (y/n): " -r read_license_choice
if [[ $read_license_choice =~ ^[Yy]$ ]]; then
    yellow "License Contents:"
    red "$(cat LICENSE)"
else
    red "License not read."
fi

# Check architecture and ask if user wants to run the emulator script
if [ "$(arch)" == "aarch64" ]; then
    read -p "Your system appears to be a Raspberry Pi (aarch64). Do you want to run the Raspberry Pi emulator script to support amd64 images? (y/n): " -r emulator_choice
    if [[ $emulator_choice =~ ^[Yy]$ ]]; then
        yellow "Running the Raspberry Pi emulator script..."
        ./raspberry_emulator_docker.sh
        green "Emulator script executed."
    else
        yellow "Emulator script not run."
        yellow "Please try launching the containers without running the emulator script first."
    fi
else
    yellow "Your system architecture does not appear to be a Raspberry Pi (aarch64)."
    yellow "Please try launching the containers without running the emulator script first."
fi

# Prompt user to launch all containers
read -p "Do you want to launch all containers with 'sudo docker-compose up -d'? (y/n): " -r launch_choice
if [[ $launch_choice =~ ^[Yy]$ ]]; then
    sudo docker-compose up -d
    green "Containers are now running."
    yellow "To Kill All Containers Execute: sudo docker-compose down"
else
    red "Containers not launched."
fi
