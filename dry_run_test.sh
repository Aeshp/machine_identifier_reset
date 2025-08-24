#hii this is dry run test for all scripts, it won't make change but will simulate the changes can be made when you'll run those scripts in actual.

#!/bin/bash

echo "--- Dry Run Test ---"
echo "This script will show you the commands that would be executed by the real scripts."
echo "NO actual changes will be made to your system."
echo "-------------------------------------------------"
echo ""
read -p "Press [Enter] to start the test..."
echo ""

# --- 1. Dry Run for change_mac_address.sh ---
echo "### 1. SIMULATING: change_mac_address.sh ###"
echo "This part simulates changing your MAC address."
echo ""

# Simulate asking for the interface
echo "First, the real script would list your network interfaces like this:"
ip -o link show | awk -F': ' '{print $2}'
echo ""
# For the dry run, we'll just use a placeholder to avoid asking for input.
IFACE="wlp0s40f3" # and here using a common example name for the test
echo "Then, it would ask you to enter an interface name. For this test, we'll pretend you entered '$IFACE'."
echo ""

echo "The following commands WOULD be run:"
echo "------------------------------------"
# and here use echo to print the commands instead of running them
echo "ACTION: Back up the current MAC address."
echo "  COMMAND: ip link show \"$IFACE\" | awk '/ether/ {print \$2}' > ~/orig_mac.txt"
echo ""
echo "ACTION: Install macchanger if needed."
echo "  COMMAND: sudo apt update && sudo apt install -y macchanger"
echo ""
echo "ACTION: Take the network card offline."
echo "  COMMAND: sudo ip link set dev \"$IFACE\" down"
echo ""
echo "ACTION: Set a new random MAC address."
echo "  COMMAND: sudo macchanger -r \"$IFACE\""
echo ""
echo "ACTION: Bring the network card back online."
echo "  COMMAND: sudo ip link set dev \"$IFACE\" up"
echo "------------------------------------"
echo ""
read -p "Press [Enter] to continue to the next test..."
echo ""
echo ""


# --- 2. Dry Run for reset_machine_id.sh ---
echo "### 2. SIMULATING: reset_machine_id.sh ###"
echo "This part simulates resetting your machine ID."
echo ""

echo "The following commands WOULD be run:"
echo "------------------------------------"
echo "ACTION: Display the current machine ID."
echo "  COMMAND: cat /etc/machine-id"
echo ""
echo "ACTION: Back up the machine ID file."
echo "  COMMAND: sudo cp /etc/machine-id /etc/machine-id.bak"
echo ""
echo "ACTION: (DESTRUCTIVE) Erase the original machine ID file."
echo "  COMMAND: sudo truncate -s 0 /etc/machine-id"
echo ""
echo "ACTION: Generate a new machine ID."
echo "  COMMAND: sudo systemd-machine-id-setup"
echo ""
echo "ACTION: Display the new machine ID."
echo "  COMMAND: cat /etc/machine-id"
echo "------------------------------------"
echo ""
read -p "Press [Enter] to continue to the final test..."
echo ""
echo ""


# --- 3. Dry Run for clean_yourapp.sh ---
echo "### 3. SIMULATING: clean_yourapp.sh ###"
echo "This part simulates cleaning 'Yourapp' data."
echo ""
echo "The following commands WOULD be run:"
echo "------------------------------------"
echo "ACTION: Stop the 'Yourapp' process."
echo "  COMMAND: pkill -f \"Yourapp\""
echo ""
echo "ACTION: (DESTRUCTIVE) Permanently delete application data."
echo "  COMMAND: rm -rf ~/.config/Yourapp"
echo "  COMMAND: rm -rf ~/.config/Yourapp-updater"
echo "  COMMAND: rm -rf ~/.local/share/Yourapp"
echo "  COMMAND: rm -rf ~/.cache/Yourapp"
echo "  COMMAND: rm -rf ~/.Yourapp"
echo "------------------------------------"
echo ""

echo "--- Dry Run Complete ---"
echo "Remember, no files were actually changed or deleted."
