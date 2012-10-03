define boxen::osx_defaults(
  $ensure = 'present',
  $domain = undef,
  $key    = undef,
  $value  = undef,
  $user   = undef,
) {
  $defaults_cmd = '/usr/bin/defaults'

  if $ensure == 'present' {
    if ($domain != undef) and ($key != undef) and ($value != undef) {
      exec { "osx_defaults write ${domain}:${key}=>${value}":
        command => "${defaults_cmd} write ${domain} ${key} '${value}'",
        unless  => "${defaults_cmd} read ${domain} ${key} && (${defaults_cmd} read ${domain} ${key} | awk '{ exit \$0 != \"${value}\" }')",
        user    => $user
      }
    } else {
      warning('Cannot ensure present without domain, key, and value attributes')
    }
  } else {
    exec { "osx_defaults delete ${domain}:${key}":
      command => "${defaults_cmd} delete ${domain} ${key}",
      onlyif  => "${defaults_cmd} read ${domain} | grep ${key}",
      user    => $user
    }
  }
}
