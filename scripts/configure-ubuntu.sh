#!/bin/bash

# This script makes ElasticSearch work, and simplifies troubleshooting.


# Append system config settings, so the ElasticSearch Docker container will work:

if ! grep -q 'EffectiveDiscussions' /etc/sysctl.conf; then
  echo 'Amending the /etc/sysctl.conf config...'
  cat <<-EOF >> /etc/sysctl.conf
		
		###################################################################
		# EffectiveDiscussions settings
		#
		vm.swappiness=1            # turn off swap, default = 60
		net.core.somaxconn=8192    # Up the max backlog queue size (num connections per port), default = 128
		vm.max_map_count=262144    # ElasticSearch requires (at least) this, default = 65530
		EOF

  echo 'Reloading the system config...'
  sysctl --system
fi



# Simplify troubleshooting:
if ! grep -q 'HISTTIMEFORMAT' ~/.bashrc; then
  echo 'Adding history settings to .bashrc...'
  cat <<-EOF >> ~/.bashrc
		
		###################################################################
		export HISTCONTROL=ignoredups
		export HISTCONTROL=ignoreboth
		export HISTSIZE=10100
		export HISTFILESIZE=10100
		export HISTTIMEFORMAT='%F %T %z  '
		EOF
fi


# Automatically apply OS security patches.
echo 'Configuring automatic security updates and reboots...'
apt-get install -y unattended-upgrades
apt-get install -y update-notifier-common
cat <<EOF > /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
Unattended-Upgrade::Automatic-Reboot "true";
EOF


# Start using any hardware random number generator, in case the server has one.
# And install 'tree', nice to have.
echo 'Installing rng-tools, why not...'
apt install rng-tools tree


echo 'Done configuring Ubuntu.'

# vim: ts=2 sw=2 tw=0 fo=r list