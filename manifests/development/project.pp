# Public: Install a boxen development project
#
# Usage:
#
#   boxen::development::project { 'puppet-boxen': }

define boxen::development::project($dirname = $title) {
  $dir = "${boxen::development::dir}/${dirname}"

  repository { $dir:
    source => "boxen/${title}"
  }

  ruby::local { $dir:
    version => 'system',
    require => Repository[$dir]
  }
}
