#!/bin/bash

echo starte Heartbeat...

echo "heartbeat" | sudo tee /sys/class/leds/led0/trigger

echo "echo 'mmc0' | sudo tee /sys/class/leds/led0/trigger" 

