# Private: A basic security profile for Boxen boxes

class boxen::security {
  boxen::osx_defaults { 'require password at screensaver':
    ensure => present,
    domain => 'com.apple.screensaver',
    key    => 'askForPassword',
    value  => 1,
    type   => 'int',
    user   => $::boxen_user
  }

  boxen::osx_defaults { 'short delay for password dialog on screensaver':
    ensure => present,
    domain => 'com.apple.screensaver',
    key    => 'askForPasswordDelay',
    value  => 5,
    type   => 'float',
    user   => $::boxen_user
  }
}
