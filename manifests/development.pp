# Grab a ton of repositories related to Boxen itself and shove 'em in
# ${boxen::config::srcdir}/boxen. Include this class in your personal
# manifest if you're doing a lot of work on Boxen itself.

class boxen::development {
  require boxen::config

  $dir = "${boxen::config::srcdir}/boxen"

  file { $dir:
    ensure => directory
  }

  $repos = boxen_repos()
  boxen::development::project { $repos: }
}
