#!/bin/bash
#Yourapp is for which you want to do all this , means you want to make your machine identifiers new.
# it'll find and stop any process of the app
pkill -f "Yourapp"

# and this is a short pause to allow the process to terminate completely
sleep 1

# check if the app is still running because if it is then it'll identify the new device again..
if pgrep -f "Yourapp" >/dev/null; then
  echo "Warning: Yourapp is still running."
else
  echo "Yourapp has been stopped."
fi

# here is a DANGER: This permanently deletes the app's data folders.
rm -rf \
  ~/.config/Yourapp \
  ~/.config/Yourapp-updater \
  ~/.local/share/Yourapp \
  ~/.cache/Yourapp \
  ~/.Yourapp

echo "Yourapp data directories have been removed."
