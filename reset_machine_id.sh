#its a shebang
#!/bin/bash

# it'll display the current machine-id
echo -n "Current machine-ID: "
cat /etc/machine-id

# it'll backup current machine-id to /etc/machine-id.bak file..
sudo cp /etc/machine-id /etc/machine-id.bak

# it'll erase the current machine-id file (this is a destructive step)
sudo truncate -s 0 /etc/machine-id

# generate a new machine-id
sudo systemd-machine-id-setup

# display the new machine-id 
echo -n "New machine-ID: "
cat /etc/machine-id
