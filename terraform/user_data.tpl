#cloud-config

apt_upgrade: true
apt_sources:
 # PPA shortcut:
 #  * Setup correct apt sources.list line
 #  * Import the signing key from LP
 #
 #  See https://help.launchpad.net/Packaging/PPA for more information
 #  this requires 'add-apt-repository'
 - source: "ppa:ansible/ansible"    # Quote the string
packages:
  - software-properties-common
  - ansible
  - git
write_files:
  - path: /etc/ansible-pull/cron.sh
    owner: root:root
    permissions: '0744'
    content: |
        ansible-pull provision.yml --url ${git_repository} --checkout step1 --accept-host-key -i localhost -e node_type=${node_type} -e env=${env}
runcmd:
  # do not create this file in write_files part since /etc/cron.d does not yet exists
  - [ sh, -c, "echo '*/30 * * * * root /etc/ansible-pull/cron.sh > /var/log/ansible-pull.log 2>&1' > /etc/cron.d/ansible_pull_cronjob"]
