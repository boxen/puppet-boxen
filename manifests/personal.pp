# Private: Includes a user's personal manifest based on their github username

class boxen::personal {
  $manifests         = "${boxen::config::repodir}/modules/people/manifests"
  $login             = regsubst($::github_login, '-','_', 'G')
  $personal_manifest = "${manifests}/${login}.pp"

  if file_exists($personal_manifest) {
    include "people::${login}"
  }
}
