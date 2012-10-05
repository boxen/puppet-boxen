# This class holds resources that clean up previous boxen states.
# They'll generally be removed after a while, once it's likely that
# everyone using Boxen has applied them once.
#
# Please add some explanatory doco when you add things to this class.

class boxen::janitor {
  require homebrew
  # Remove ill-advised cc/gcc symlinks.

  file { ["${homebrew::dir}/bin/cc", "${homebrew::dir}/bin/gcc"]:
    ensure => absent
  }
}
