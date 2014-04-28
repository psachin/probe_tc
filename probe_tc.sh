#!/usr/bin/env bash

# Script to probe touch driver on Aakash
# For: ft5x_tx, gls, ekt & gt8**

/home/aakash/github/sunxi-tools/bin2fex /home/aakash/nanda/script.bin > /tmp/script.fex

TC_IN_SCRIPT_DOT_BIN=$(cat /tmp/script.fex | grep ctp_name | sed 's/.*"\(.*\)".*/\1/g')


function ft5x() {
    lsmod | grep ${TC_IN_SCRIPT_DOT_BIN}
    if [ "$(echo $?)" -eq 0 ];
    then
	echo "$(date): ${TC_IN_SCRIPT_DOT_BIN} module already loaded" >> /var/log/aakash_tc.log
    else
	cp -v /home/aakash/mount/script.bin.white /home/aakash/mount/script.bin
	echo -e "8192cu\nrtl8192cu\nrtlwifi\nft5x_ts" > /etc/modules
	wait
	reboot
    fi
}


if [ ${TC_IN_SCRIPT_DOT_BIN} == "ft5x_ts" ];
then
    echo "$(date): Detected ft5x" >> /var/log/aakash_tc.log
    ft5x
else
    echo "$(date): No suitable touch driver found." >> /var/log/aakash_tc.log
fi
