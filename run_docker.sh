#!/bin/bash

# Set your Mac IP address
IP=$(/usr/sbin/ipconfig getifaddr en0)
echo $IP
#192.168.1.9

# Allow connections from Mac to XQuartz
/opt/X11/bin/xhost + "$IP"
#192.168.1.9 being added to access control list

# Run container
docker build . -t prolog && docker run -it -e DISPLAY="${IP}:0" -v /tmp/.X11-unix:/tmp/.X11-unix prolog

