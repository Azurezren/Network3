#!/bin/bash

# Script save path
SCRIPT_PATH="$HOME/Network3.sh"

# Node version and download URL (configurable)
NODE_VERSION="v2.1.0"
NODE_URL="https://network3.io/ubuntu-node-${NODE_VERSION}.tar"

# Log file for debugging
LOG_FILE="$HOME/network3_script.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script needs to be run with root privileges."
    echo "Please try switching to the root user using the 'sudo -i' command, then run this script again."
    exit 1
fi

# Ensure screen is installed
if ! command -v screen &> /dev/null; then
    log_message "screen is not installed, installing now..."
    sudo apt-get install -y screen || { log_message "Failed to install screen."; exit 1; }
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
        echo "4) Check node status"
        echo "5) Exit"
        echo -n "Choose an option [1-5]: "
        read -r OPTION

        # Trim whitespace from input
        OPTION=$(echo "$OPTION" | xargs)

        case "$OPTION" in
            1) install_and_start_node ;;
            2) get_private_key ;;
            3) stop_node ;;
            4) check_node_status ;;
            5) exit 0 ;;
            *) echo "Invalid option, please try again." ;;
        esac

        echo "Press any key to return to the main menu..."
        read -n 1
    done
}

# Function to install and start the node
install_and_start_node() {
    log_message "Starting node installation..."

    # Update the system package list
    sudo apt update || { log_message "Failed to update package list."; exit 1; }

    # Install required packages
    log_message "Installing required packages..."
    sudo apt install -y wget curl make clang pkg-config libssl-dev build-essential jq lz4 gcc unzip snapd net-tools || {
        log_message "Failed to install required packages."
        exit 1
    }

    # Download, extract, and clean up files
    log_message "Downloading and extracting the node package..."
    wget "$NODE_URL" -O "ubuntu-node-${NODE_VERSION}.tar" || { log_message "Failed to download node package."; exit 1; }
    tar -xf "ubuntu-node-${NODE_VERSION}.tar" || { log_message "Failed to extract node package."; exit 1; }
    rm -rf "ubuntu-node-${NODE_VERSION}.tar"

    # Check if the directory exists
    if [ ! -d "ubuntu-node" ]; then
        log_message "Directory ubuntu-node does not exist, please check if the download and extraction were successful."
        exit 1
    fi

    # Enter the directory
    log_message "Entering the ubuntu-node directory..."
    cd ubuntu-node || { log_message "Failed to enter ubuntu-node directory."; exit 1; }

    # Check and create a screen session
    if screen -list | grep -q "network3"; then
        log_message "Detected an existing screen session named 'network3'."
    else
        log_message "Creating a new screen session 'network3'..."
        screen -S network3 -dm || { log_message "Failed to create screen session."; exit 1; }
    fi

    # Start the node
    log_message "Starting the node..."
    screen -S network3 -p 0 -X stuff 'sudo bash manager.sh up\n' || { log_message "Failed to start the node."; exit 1; }

    log_message "Node installation and startup complete."
    echo "Press any key to return to the main menu..."
    read -n 1
    main_menu
}

# Function to get the private key
get_private_key() {
    log_message "Getting the private key..."
    cd ubuntu-node || { log_message "Failed to enter ubuntu-node directory."; exit 1; }
    sudo bash manager.sh key || { log_message "Failed to retrieve private key."; exit 1; }
    echo "Press any key to return to the main menu..."
    read -n 1
    main_menu
}

# Function to stop the node
stop_node() {
    log_message "Stopping the node..."
    cd ubuntu-node || { log_message "Failed to enter ubuntu-node directory."; exit 1; }
    sudo bash manager.sh down || { log_message "Failed to stop the node."; exit 1; }
    log_message "Node has been stopped."
    echo "Press any key to return to the main menu..."
    read -n 1
    main_menu
}

# Function to check node status
check_node_status() {
    log_message "Checking node status..."
    if screen -list | grep -q "network3"; then
        echo "The node is running."
    else
        echo "The node is not running."
    fi
    echo "Press any key to return to the main menu..."
    read -n 1
    main_menu
}

# Call the main menu function to start executing the main menu logic
main_menu
