# Prepare puppetlabs repo
wget http://apt.puppetlabs.com/puppetlabs-release-wheezy.deb
dpkg -i puppetlabs-release-wheezy.deb
apt-get update

# Install puppet/facter
apt-get install -y puppet facter
rm -f puppetlabs-release-wheezy.deb

sed -i 's/templatedir/#templatedir/g' /etc/puppet/puppet.conf

gem install hiera-eyaml

sed -i 's|# fr_FR.UTF-8 UTF-8|fr_FR.UTF-8 UTF-8|' /etc/locale.gen
locale-gen "fr_FR.UTF-8"
ln -s /media/sf_vagrant /vagrant
echo
echo ">>>>>>>> Puppet"
old_hostname=`hostname`
export FACTER_fqdn=default.tennaxia.org
echo $FACTER_fqdn > /etc/hostname
hostname $FACTER_fqdn
echo "facter"
facter fqdn

puppet apply  --parser future                                                                       \
              --modulepath '/vagrant/Puppet/modules:/vagrant/Puppet/dist:/etc/puppet/modules'       \
              --hiera_config=/vagrant/hiera.yaml                                                    \
              --color=true                                                                          \
              --manifestdir /vagrant/Puppet/manifests                                               \
              --detailed-exitcodes /vagrant/Puppet/manifests/site.pp
echo "<<<<<<<<<<<<< Fin Puppet"
export FACTER_fqdn=$old_hostname
echo $FACTER_fqdn > /etc/hostname
hostname $FACTER_fqdn
hostname
exit 0