class boxen::gemrc {
  require boxen::config

  file { "/Users/${::luser}/.gemrc":
    ensure  => present,
    replace => false,
    source  => 'puppet:///modules/boxen/gemrc'
  }
}
