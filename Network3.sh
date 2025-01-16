#!/bin/bash

# Script save path
SCRIPT_PATH="$HOME/Network3.sh"

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script needs to be run with root privileges."
    echo "Please try switching to the root user using the 'sudo -i' command, then run this script again."
    exit 1
fi

# Ensure screen is installed
if ! command -v screen &> /dev/null; then
    echo "screen is not installed, installing now..."
    sudo apt-get install -y screen
fi

# Main menu function
function main_menu() {
    while true; do
        clear
        echo "================================================================"
        echo "Welcome to the Network3 script!"
        echo "This script will help you install and manage the Network3 node."
        echo "0xAZUREZREN"
        echo "================================================================"
        echo "To exit the script, press ctrl c on your keyboard."
        echo "Please select the action you want to perform:"
        echo "1) Install and start node"
        echo "2) Get private key"
        echo "3) Stop node"
        echo "4) Exit"
        echo -n "Choose an option [1-4]: "
        read OPTION

        case $OPTION in
        1) install_and_start_node ;;
        2) get_private_key ;;
        3) stop_node ;;
        4) exit 0 ;;
        *) echo "Invalid option, please try again." ;;
        esac

        echo "Press any key to return to the main menu..."
        read -n 1
    done
}

# Function to install and start the node
install_and_start_node() {
    # Update the system package list
    sudo apt update

    # Install required packages
    sudo apt install -y wget curl make clang pkg-config libssl-dev build-essential jq lz4 gcc unzip snapd
    sudo apt-get install -y net-tools

    # Download, extract, and clean up files
    echo "Downloading and extracting the node package..."
    wget https://network3.io/ubuntu-node-v2.1.0.tar
    tar -xf ubuntu-node-v2.1.0.tar
    rm -rf ubuntu-node-v2.1.0.tar

    # Check if the directory exists
    if [ ! -d "ubuntu-node" ]; then
        echo "Directory ubuntu-node does not exist, please check if the download and extraction were successful."
        exit 1
    fi

    # Prompt and enter the directory
    echo "Entering the ubuntu-node directory..."
    cd ubuntu-node

    # Check and create a screen session
    if screen -list | grep -q "network3"; then
        echo "Detected an existing screen session named 'network3'."
    else
        echo "Creating a new screen session 'network3'..."
        screen -S network3 -dm
    fi

    # Start the node
    echo "Starting the node..."
    screen -S network3 -p 0 -X stuff 'sudo bash manager.sh up\n'

    echo "Script execution complete."
    echo "Press any key to return to the main menu..."
    read -n 1
    main_menu
}

# Function to get the private key
get_private_key() {
    echo "Getting the private key..."
    cd ubuntu-node
    sudo bash manager.sh key
    echo "Press any key to return to the main menu..."
    read -n 1
    main_menu
}

# Function to stop the node
stop_node() {
    echo "Stopping the node..."
    cd ubuntu-node
    sudo bash manager.sh down
    echo "Node has been stopped."
    echo "Press any key to return to the main menu..."
    read -n 1
    main_menu
}

# Call the main menu function to start executing the main menu logic
main_menu
