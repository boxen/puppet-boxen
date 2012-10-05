class boxen::bin {
  file { "${boxen::config::home}/bin/boxen":
    ensure => link,
    target => "${boxen::config::repodir}/script/boxen"
  }
}
