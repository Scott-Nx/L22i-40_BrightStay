#!/bin/bash

PRODUCT_CODE="26542"


BRIGHTNESS_LEVEL=5

change_brightness() {
    echo "Changing brightness on $PRODUCT_CODE to $BRIGHTNESS_LEVEL%"
    # Assuming the monitor's VCP code for brightness is 0x10 (common for many monitors)
    ddcutil setvcp 0x10 $BRIGHTNESS_LEVEL
}

if ddcutil detect | grep -q $PRODUCT_CODE; then
    # If connected, change the brightness
    change_brightness
    exit 0
else
    echo "External monitor with Product Code $PRODUCT_CODE not connected."
    exit 0
fi
