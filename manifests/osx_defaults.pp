define boxen::osx_defaults(
  $ensure = 'present',
  $host   = undef,
  $domain = undef,
  $key    = undef,
  $value  = undef,
  $user   = undef,
  $type   = undef,
) {
  $defaults_cmd = '/usr/bin/defaults'
  case $host {
    'currentHost': { $host_option = ' -currentHost' }
    undef:         { $host_option = '' }
    default:       { $host_option = " -host ${host}" }
  }

  if $ensure == 'present' {
    if ($domain != undef) and ($key != undef) and ($value != undef) {
      if ($type != undef) {
        $cmd = "${defaults_cmd}${host_option} write ${domain} ${key} -${type} '${value}'"
      } else {
        $cmd = "${defaults_cmd}${host_option} write ${domain} ${key} '${value}'"
      }
      exec { "osx_defaults write ${host} ${domain}:${key}=>${value}":
        command => "${cmd}",
        unless  => "${defaults_cmd}${host_option} read ${domain} ${key} && (${defaults_cmd} read ${domain} ${key} | awk '{ exit \$0 != \"${value}\" }')",
        user    => $user
      }
    } else {
      warning('Cannot ensure present without domain, key, and value attributes')
    }
  } else {
    exec { "osx_defaults delete ${host} ${domain}:${key}":
      command => "${defaults_cmd}${host_option} delete ${domain} ${key}",
      onlyif  => "${defaults_cmd}${host_option} read ${domain} | grep ${key}",
      user    => $user
    }
  }
}
