# Private: Append our environment load to ~/.profile

class boxen::profile {
  require boxen::config

  $profile = "/Users/${::boxen_user}/.profile"

  # This is modeled as an exec instead of a file so people can have
  # classes with a .profile file in 'em.

  exec { 'create a minimal profile':
    command => "echo 'source ${boxen::config::home}/env.sh' > ${profile}",
    creates => $profile
  }
}
