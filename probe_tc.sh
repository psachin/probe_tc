#!/usr/bin/env bash

/home/aakash/github/sunxi-tools/bin2fex /home/aakash/nanda/script.bin > /tmp/script.fex

TC_IN_SCRIPT_DOT_BIN=$(cat /tmp/script.fex | grep "ctp_used = 1" -A1 | grep ctp_name | sed 's/.*"\(.*\)".*/\1/g')

echo $TC_IN_SCRIPT_DOT_BIN 


function ft5x() {
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
    lsmod | grep "gslx680_ts"
    if [ "$(echo $?)" -eq 0 ];
    then
	echo "$(date): ${TC_IN_SCRIPT_DOT_BIN} module already loaded" >> /var/log/aakash_tc.log
    else
	cp -v /home/aakash/mount/script.bin.gslx1680 /home/aakash/mount/script.bin
	cp -v /lib/modules/uImage.3.4.75 /home/aakash/mount/uImage
	echo -e "8192cu\nrtl8192cu\nrtlwifi" > /etc/modules

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
    echo "$(date): Detected ft5x" >> /var/log/aakash_tc.log
    ft5x
elif [ ${TC_IN_SCRIPT_DOT_BIN} == "Goodix-TS" ];
then 
    echo "$(date): Detected Goodix-TS" >> /var/log/aakash_tc.log
    gt811
elif [ ${TC_IN_SCRIPT_DOT_BIN} == "elan_ts" ];
then 
    echo "$(date): Detected ektf2k" >> /var/log/aakash_tc.log
    ektf2k
elif [ ${TC_IN_SCRIPT_DOT_BIN} == "gslx1680" ];
then 
    echo "$(date): Detected gslx1680" >> /var/log/aakash_tc.log
    gslx1680
else
    echo "$(date): $TC_IN_SCRIPT_DOT_BIN" >> /var/log/aakash_tc.log
    echo "$(date): No suitable touch driver found." >> /var/log/aakash_tc.log
fi


