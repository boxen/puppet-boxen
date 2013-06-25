# Private: Properly configure the Boxen gemrc environment

class boxen::gemrc {
  require boxen::config

  file { "/Users/${::boxen_user}/.gemrc":
    ensure  => present,
    replace => false,
    source  => 'puppet:///modules/boxen/gemrc'
  }
}
