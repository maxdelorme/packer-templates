# Clean up
echo '>>>> Removing unused locales'
echo 'localepurge	localepurge/nopurge	multiselect	en, en_US.UTF-8, fr, fr_FR.UTF-8' | debconf-set-selections
echo 'localepurge	localepurge/mandelete	boolean	true' | debconf-set-selections
echo 'localepurge	localepurge/dontbothernew	boolean	true' | debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get -y install localepurge
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure localepurge
sed -i -e 's|^USE_DPKG|#USE_DPKG|' /etc/locale.nopurge
localepurge

echo '>>>> Removing unnecessary packages'
apt-get -y purge $(dpkg --list |grep '^rc' |awk '{print $2}')
apt purge -y libpix* blue* libsqlite* libX11* installation-report w3m* geoip* mutt exim*
apt-get -y remove linux-headers-$(uname -r) build-essential
apt-get -y install lsb-release
apt-get -y autoremove
apt-get -y clean
apt-get -y autoclean

echo '>>>> Removing VirtualBox ISOs'
rm -rf /home/vagrant/*.iso

echo '>>>> Cleaning up DHCP leases'
rm /var/lib/dhcp/*


# Make sure Udev doesn't block our network
echo '>>>> Fixing udev'
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules



echo '>>>> Adding a 2 sec delay to the interface up, to make dhclient happy'
echo "pre-up sleep 2" >> /etc/network/interfaces


# Zero out the free space to save space in the final image, blocking 'til
# written otherwise, the disk image won't be zeroed, and/or Packer will try to
# kill the box while the disk is still full and that's bad.  The dd will run
# 'til failure, so (due to the 'set -e' above), ignore that failure.  Also,
# really make certain that both the zeros and the file removal really sync; the
# extra sleep 1 and sync shouldn't be necessary, but...)
echo '>>>> Zeroing device to make space...'
dd if=/dev/zero of=/EMPTY bs=1M || true; sync; sleep 1; sync
rm -f /EMPTY; sync; sleep 1; sync


echo ">>>> DONE"