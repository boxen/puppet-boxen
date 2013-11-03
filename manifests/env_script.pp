# Public: install a boxen environment script
# with the given priority.
#
# Usage:
#
#   boxen::env_script {
#    'config':
#      content  => template('boxen/config.sh.erb'),
#      priority => 'highest';
#   }

define boxen::env_script(
  $ensure     = 'present',
  $scriptname = $name,
  $priority   = 'normal',
  $source     = undef,
  $content    = undef,
) {

  if $source == undef and $content == undef {
    fail('One of source or content must not be undef!')
  }

  $real_priority = $priority ? {
    'highest' => 10,
    'higher'  => 30,
    'high'    => 40,
    'normal'  => 50,
    'low'     => 60,
    'lower'   => 70,
    'lowest'  => 90,
    default   => $priority,
  }

  include boxen::config

  file { "${boxen::config::envdir}/${real_priority}_${scriptname}.sh":
    ensure  => $ensure,
    source  => $source,
    content => $content,
  }
}
