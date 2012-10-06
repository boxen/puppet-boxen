class boxen::personal {
  $manifests = "${boxen::config::repodir}/modules/people/manifests"
  $personal_manifest = "${manifests}/${::github_login}.pp"
  if file_exists($personal_manifest) {
    include "people::${::github_login}"
  }
}
