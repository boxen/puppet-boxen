# Private: Sets up global bins on path boxen will use

class boxen::bin {
  include boxen::config
  include boxen::repo

  file { "${boxen::config::home}/bin/boxen":
    ensure  => link,
    target  => "${::boxen_home}/repo/script/boxen",
    require => Exec["clone ${::boxen_home}/repo"]
  }
}
