# This class holds resources that clean up previous boxen states.
# They'll generally be removed after a while, once it's likely that
# everyone using The boxen has applied them once.
#
# Please add some explanatory doco when you add things to this class.

class boxen::janitor {

  # We originally had dnsmasq set up to resolve the `.hub` domain,
  # which sounded good but turned out to require too many code changes
  # in various projects. This removes the old resolver file.

  file { '/etc/resolver/hub':
    ensure => absent,
    force  => true
  }

  # Remove ill-advised cc/gcc symlinks.

  file { ["${homebrew::dir}/bin/cc", "${homebrew::dir}/bin/gcc"]:
    ensure => absent
  }
}
