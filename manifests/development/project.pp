define boxen::development::project($dirname = $title) {
  $dir = "${boxen::development::dir}/$dirname"

  repository { $dir:
    source => "boxen/$title"
  }

  ruby::local { $dir:
    version => 'system',
    require => Repository[$dir]
  }
}
