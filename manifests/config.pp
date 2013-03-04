class boxen::config {
  $home              = $::boxen_home
  $bindir            = "${home}/bin"
  $cachedir          = "${home}/cache"
  $configdir         = "${home}/config"
  $datadir           = "${home}/data"
  $envdir            = "${home}/env.d"
  $homebrewdir       = "${home}/homebrew"
  $logdir            = "${home}/log"
  $repodir           = $::boxen_repodir
  $reponame          = $::boxen_reponame
  $socketdir         = "${datadir}/project-sockets"
  $srcdir            = $::boxen_srcdir
  $login             = $::github_login
  $repo_url_template = $::boxen_repo_url_template

  file { [$home,
          $srcdir,
          $bindir,
          $cachedir,
          $configdir,
          $datadir,
          $envdir,
          $logdir,
          $socketdir]:

    ensure => directory
  }

  file { "${home}/README.md":
    source => 'puppet:///modules/boxen/README.md'
  }

  file { "${home}/env.sh":
    content => template('boxen/env.sh.erb'),
    mode    => '0755',
  }

  file { "${envdir}/config.sh":
    content => template('boxen/config.sh.erb')
  }

  file { "${envdir}/gh_creds.sh":
    content => template('boxen/gh_creds.sh.erb')
  }

  group { 'puppet':
    ensure => present
  }

  $puppet_data_dirs = [
    "${home}/data/puppet",
    "${home}/data/puppet/graphs"
  ]

  file { $puppet_data_dirs:
    ensure => directory,
    owner  => $::luser
  }
}
