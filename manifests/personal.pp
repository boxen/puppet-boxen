# Private: Includes a user's personal manifest based on their github username

class boxen::personal {
  include boxen::config

  $manifests = "${boxen::config::repodir}/modules/people/manifests"
  $login     = regsubst($boxen::config::login, '-','_', 'G')

  if $login != $boxen::config::login {
    notice("Changed boxen::personal login to ${login}")
  }
  if file_exists("${manifests}/${login}.pp") {
    include "people::${login}"
  }
}
