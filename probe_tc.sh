#!/usr/bin/env bash
# Script to load suitable touch driver.
# This is a back-end script and is called by '/etc/r.local'

# ------------------------------------------------------------
# Algo:
# ----
# 1. Parse touch controller name from script.bin.
# 2. Depending upon touch controller name, load relevant function
#    Each function will:
#    - Copy appropriate 'script.bin' to 1st partition
#    - Copy appropriate 'uImage' to 1st partition
#    - Write module-name to '/etc/modules' file
#    - Copy appropriate 'xorg.conf.d' directory to '/usr/share/X11/' path
#    - Log events/errors in /var/log/aakash_tc.log 
#    - Reboot with new settings
# 3. If the module is already loaded, don't do anything(Load with
#    default setting and do not reboot)
# ------------------------------------------------------------


# Convert script.bin to script.fex
/home/aakash/github/sunxi-tools/bin2fex /home/aakash/nanda/script.bin > /tmp/script.fex

# Parse Capacitive touch panel name
TC_IN_SCRIPT_DOT_BIN=$(cat /tmp/script.fex | grep "ctp_used = 1" -A1 | grep ctp_name | sed 's/.*"\(.*\)".*/\1/g')
# Parse Capacitive touch panel address(Required for gslx1680 to distinguish from 'ft5x_ts'. gslx's script has ctp_name = "ft5x_ts")
TC_ADDR_IN_SCRIPT_DOT_BIN=$(cat /tmp/script.fex | grep "ctp_used = 1" -A3 | grep ctp_twi_addr | cut -d "x" -f 2)
# echo ${TC_IN_SCRIPT_DOT_BIN}
# echo ${TC_ADDR_IN_SCRIPT_DOT_BIN}


function ft5x() {
    # Configure and load 'ft5x_ts' driver
    lsmod | grep ${TC_IN_SCRIPT_DOT_BIN}
    if [ "$(echo $?)" -eq 0 ];
    then
	echo "$(date): ${TC_IN_SCRIPT_DOT_BIN} module already loaded" >> /var/log/aakash_tc.log
    else
	cp -v /home/aakash/mount/script.bin.ft5x /home/aakash/mount/script.bin
	cp -v /lib/modules/uImage.3.0.76 /home/aakash/mount/uImage	
	echo -e "8192cu\nrtl8192cu\nrtlwifi\nft5x_ts" > /etc/modules

	echo "$(date): Deleting xorg.conf.d" >> /var/log/aakash_tc.log
	rm -r /usr/share/X11/xorg.conf.d
	echo "$(date): Copying xorg.conf.d.orig to xorg.conf.d" >> /var/log/aakash_tc.log
	cp -r /usr/share/X11/xorg.conf.d.orig /usr/share/X11/xorg.conf.d

	wait
	reboot
    fi
}


function gt811() {
    # Configure and load 'gt811_ts' driver
    lsmod | grep "gt811_ts"
    if [ "$(echo $?)" -eq 0 ];
    then
	echo "$(date): ${TC_IN_SCRIPT_DOT_BIN} module already loaded" >> /var/log/aakash_tc.log
    else
	cp -v /home/aakash/mount/script.bin.gt811 /home/aakash/mount/script.bin
	cp -v /lib/modules/uImage.3.0.76 /home/aakash/mount/uImage	
	echo -e "8192cu\nrtl8192cu\nrtlwifi\ngt811_ts" > /etc/modules

	echo "$(date): Deleting xorg.conf.d" >> /var/log/aakash_tc.log
	rm -r /usr/share/X11/xorg.conf.d
	echo "$(date): Copying xorg.conf.d.orig to xorg.conf.d" >> /var/log/aakash_tc.log
	cp -r /usr/share/X11/xorg.conf.d.orig /usr/share/X11/xorg.conf.d
	
	wait
	reboot
    fi
}


function ektf2k() {
    # Configure and load 'ektf2k' driver    
    lsmod | grep "ektf2k"
    if [ "$(echo $?)" -eq 0 ];
    then
	echo "$(date): ${TC_IN_SCRIPT_DOT_BIN} module already loaded" >> /var/log/aakash_tc.log
    else
	cp -v /home/aakash/mount/script.bin.ekt2k /home/aakash/mount/script.bin
	cp -v /lib/modules/uImage.3.0.76 /home/aakash/mount/uImage
	echo -e "8192cu\nrtl8192cu\nrtlwifi\nektf2k" > /etc/modules

	echo "$(date): Backing up xorg.conf.d" >> /var/log/aakash_tc.log
	cp -r /usr/share/X11/xorg.conf.d /usr/share/X11/xorg.conf.d.orig
	echo "$(date): Deleting xorg.conf.d" >> /var/log/aakash_tc.log
	rm -r /usr/share/X11/xorg.conf.d
	echo "$(date): Copying xorg.conf.d.ektf2k to xorg.conf.d" >> /var/log/aakash_tc.log
	cp -r /usr/share/X11/xorg.conf.d.ektf2k /usr/share/X11/xorg.conf.d
	
	wait
	reboot
    fi
}


function gslx1680() {
    # Configure and load 'ektf2k' driver
    
    # Load the driver as it was compiled separately from the kernel
    insmod /lib/modules/3.4.75+/kernel/drivers/input/touchscreen/gslx680_ts.ko
    lsmod | grep "gslx680_ts"
    
    if [ "$(echo $?)" -eq 0 ];
    then
	echo "$(date): gslx1680 module already loaded" >> /var/log/aakash_tc.log
    else
	cp -v /home/aakash/mount/script.bin.gslx1680 /home/aakash/mount/script.bin
	cp -v /lib/modules/uImage.3.4.75 /home/aakash/mount/uImage
	echo -e "8192cu\nrtl8192cu\nrtlwifi\n#gslx680_ts" > /etc/modules

	echo "$(date): Deleting xorg.conf.d" >> /var/log/aakash_tc.log
	rm -r /usr/share/X11/xorg.conf.d
	echo "$(date): Copying xorg.conf.d.orig to xorg.conf.d" >> /var/log/aakash_tc.log
	cp -r /usr/share/X11/xorg.conf.d.orig /usr/share/X11/xorg.conf.d

	wait
	reboot
    fi
}


if [ ${TC_IN_SCRIPT_DOT_BIN} == "ft5x_ts" ];
then
    # 'gslx1680' in script.bin has ctp_name = "ft5x_ts", but ctp_twi_addr is '0x3f'
    if [ ${TC_ADDR_IN_SCRIPT_DOT_BIN} == "3f" ];
    then # Load gslx1680 driver
	echo "$(date): Detected gslx1680" >> /var/log/aakash_tc.log
	gslx1680
    else # Load ft5x_ts driver
	echo "$(date): Detected ft5x" >> /var/log/aakash_tc.log
	ft5x
    fi
elif [ ${TC_IN_SCRIPT_DOT_BIN} == "Goodix-TS" ];
then 
    echo "$(date): Detected Goodix-TS" >> /var/log/aakash_tc.log
    gt811
elif [ ${TC_IN_SCRIPT_DOT_BIN} == "elan_ts" ];
then 
    echo "$(date): Detected ektf2k" >> /var/log/aakash_tc.log
    ektf2k
else
    echo "$(date): $TC_IN_SCRIPT_DOT_BIN" >> /var/log/aakash_tc.log
    echo "$(date): No suitable touch driver found." >> /var/log/aakash_tc.log
fi

