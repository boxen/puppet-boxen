# Private: Ensure we can run Boxen, launchctl, and fdesetup without sudo prompt

class boxen::sudoers {
  sudoers { 'boxen':
    users    => $::boxen_user,
    hosts    => 'ALL',
    commands => [
      '(ALL) NOPASSWD : /bin/mkdir -p /tmp/puppet',
      "/bin/mkdir -p ${::boxen_home}",
      "/usr/sbin/chown ${::boxen_user}\\:staff ${::boxen_home}",
      "${boxen::config::repodir}/bin/puppet",
      '/bin/rm -f /tmp/boxen.log'
    ],
    type     => 'user_spec',
  }

  sudoers { 'fdesetup':
    users    => $::boxen_user,
    hosts    => 'ALL',
    commands => [
      '(ALL) NOPASSWD : /usr/bin/fdesetup status',
      '/usr/bin/fdesetup list',
    ],
    type     => 'user_spec',
  }

  sudoers { 'launchctl':
    users    => $::boxen_user,
    hosts    => 'ALL',
    commands => [
      '(ALL) NOPASSWD : /bin/launchctl load',
      '/bin/launchctl unload',
    ],
    type     => 'user_spec',
  }
}
