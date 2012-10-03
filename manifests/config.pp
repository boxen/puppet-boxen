class boxen::config {
  $home        = $::boxenhome
  $bindir      = "${home}/bin"
  $configdir   = "${home}/config"
  $datadir     = "${home}/data"
  $envdir      = "${home}/env.d"
  $homebrewdir = "${home}/homebrew"
  $logdir      = "${home}/log"
  $socketdir   = "${datadir}/project-sockets"
  $srcdir      = $::boxensrcdir
  $login       = $::ghlogin

  file { [$home,
          $srcdir,
          $bindir,
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
    "${::ghome}/data/puppet",
    "${::ghome}/data/puppet/graphs"
  ]

  file { $puppet_data_dirs:
    ensure => directory,
    owner  => $::luser
  }
}
