# Private: Ensures the boxen repodir is a checkout of the boxen repo

class boxen::repo {
  include boxen::config

  $clone_url  = inline_template('<%= scope.lookupvar("::boxen::config::repo_url_template") % scope.lookupvar("::boxen::config::reponame") %>')
  $remote_add = "git remote add origin ${clone_url}"
  $git_fetch  = 'git fetch -q origin'
  $git_reset  = 'git reset --hard origin/master'

  file { "${boxen::config::home}/repo": ensure => directory }

  exec { "clone ${boxen::config::home}/repo":
    command => "git init && ${remote_add} && ${git_fetch} && ${git_reset}",
    creates => "${boxen::config::home}/repo/.git",
    cwd     => "${boxen::config::home}/repo",
    require => Class['git'],
  }
}
