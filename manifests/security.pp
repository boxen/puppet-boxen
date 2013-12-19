# Private: A basic security profile for Boxen boxes

class boxen::security(
  $require_password = true,
  $screensaver_delay_sec = 5
) {
  boxen::osx_defaults { 'require password at screensaver':
    ensure => present,
    domain => 'com.apple.screensaver',
    key    => 'askForPassword',
    value  => $require_password,
    user   => $::boxen_user
  }

  boxen::osx_defaults { 'short delay for password dialog on screensaver':
    ensure => present,
    domain => 'com.apple.screensaver',
    key    => 'askForPasswordDelay',
    value  => $screensaver_delay_sec,
    user   => $::boxen_user
  }
}
