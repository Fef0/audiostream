#!/bin/bash

# Check if too many (or too few) arguments are passed
if [ $# -gt 1 ]; then
	echo "Too many arguments!"
	echo "Example:"
	echo "	$0 /proc/asound/MyCard/streamX"
	exit
elif [ $# -le 0 ]; then
	echo "Too few arguments!"
	echo "Example:"
	echo "	$0 /proc/asound/MyCard/streamX"
	exit
fi

# Check for help command
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
	echo "Example:"
	echo "	$0 /proc/asound/MyCard/streamX"
	exit
fi

# Get the device-capable streams
STREAM=$(cat $1)
# Get the running stream infos
RUNNING=$(echo "$STREAM" | grep -A 5 "Running")

# If no stream is detected, exit
if [ -z "$RUNNING" ]; then
	echo "No stream detected!"
	exit
fi

# Get the current sampling frequency
FREQ=$(echo "$RUNNING" | grep "Momentary freq" | grep -oE "[^=]+$" | awk '{print $1}')
# Get the current packet size
PACKSIZE=$(echo "$RUNNING" | grep "Packet Size" | grep -oE "[^=]+$" | awk '{print $1}')
# Get the feedback format
FEEDBACK=$(echo "$RUNNING" | grep "Feedback Format" | grep -oE "[^=]+$" | awk '{print $1}')

# Get the current interface and trim it (with xargs)
INTERFACE=$(echo "$RUNNING" | grep "Interface" | grep -oE "[^=]+$" | xargs)
# Get the current altset and trim it (with xargs)
ALTSET=$(echo "$RUNNING" | grep "Altset" | grep -oE "[^=]+$" | xargs)
# Get the interface that the streamer is using
RIGHTINTERFACE=$(echo "$STREAM" | grep -A 6 "Interface $INTERFACE" | grep -A 5 "Altset $ALTSET")
# Get the bit depth, format and channels
BITS=$(echo "$RIGHTINTERFACE" | grep "Bits" | grep -oE "[^ ]+$")
FORMAT=$(echo "$RIGHTINTERFACE" | grep "Format" | grep -oE "[^ ]+$")
CHANNELS=$(echo "$RIGHTINTERFACE" | grep "Channels" | grep -oE "[^ ]+$")


# Craft the simple message and show it
echo "Running stream for $1:"
echo "- Frequency Rate: "$FREQ"Hz"
echo "- Bit depth: $BITS"
echo "- Format: $FORMAT"
echo "- Channels: $CHANNELS"
echo "- Packet size: $PACKSIZE"
echo "- Feedback Format: $FEEDBACK"
