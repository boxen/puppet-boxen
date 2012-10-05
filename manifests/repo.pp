class boxen::repo {
  repository { "${::boxen_home}/repo":
    ensure => present,
    source => $boxen::config::reponame
  }
}
