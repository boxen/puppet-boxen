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
      if (is_hash($value)) {
        $value_option = inline_template('<%= value.to_a.flatten.map {|e| "\'#{e}\'"}.join(" ") %>')
      } elsif (is_array($value)) {
        $value_option = inline_template('<%= value.map {|e| "\'#{e}\'"}.join(" ") %>')
      } else {
        $value_option = "'${value}'"
      }
      if ($type != undef) {
        $cmd = "${defaults_cmd}${host_option} write ${domain} ${key} -${type} ${value_option}"
      } else {
        $cmd = "${defaults_cmd}${host_option} write ${domain} ${key} ${value_option}"
      }
      exec { "osx_defaults write ${host} ${domain}:${key}=>${value_option}":
        command => "${cmd}",
        unless  => "${defaults_cmd}${host_option} read ${domain} ${key} && (${defaults_cmd}${host_option} read ${domain} ${key} | awk '{ exit \$0 != \"${value}\" }')",
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
