class boxen::bin {
  include boxen::config

  file { "${boxen::config::home}/bin/boxen":
    ensure  => link,
    target  => "${::boxen_home}/repo/script/boxen",
    require => Repository["${::boxen_home}/repo"]
  }
}
