# Public: Set a system config option with the OS X defaults system

define boxen::osx_defaults(
  $ensure = 'present',
  $host   = undef,
  $domain = undef,
  $key    = undef,
  $value  = undef,
  $user   = undef,
  $type   = undef,
) {
  $defaults_cmd  = '/usr/bin/defaults'
  $default_cmds  = $host ? {
    'currentHost' => [ $defaults_cmd, '-currentHost' ],
    undef         => [ $defaults_cmd ],
    default       => [ $defaults_cmd, '-host', $host ]
  }

  case $ensure {
    present: {
      if ($domain == undef) or ($key == undef) or ($value == undef) {
        fail('Cannot ensure present without domain, key, and value attributes')
      }

      if (($type == undef) and (($value == true) or ($value == false))) or ($type =~ /^bool/) {
        $type_ = 'bool'

        $checkvalue = $value ? {
          /(true|yes)/ => '1',
          /(false|no)/ => '0',
        }

      } else {
        $type_      = $type
        $checkvalue = $value
      }

      $write_cmd = $type_ ? {
        undef   => shellquote($default_cmds, 'write', $domain, $key, "${value}"),
        default => shellquote($default_cmds, 'write', $domain, $key, "-${type_}", "${value}")
      }

      $read_cmd = shellquote($default_cmds, 'read', $domain, $key)

      exec { "osx_defaults write ${host} ${domain}:${key}=>${value}":
        command => $write_cmd,
        unless  => "${read_cmd} && (${read_cmd} | awk '{ exit \$0 != \"${checkvalue}\" }')",
        user    => $user
      }
    } # end present

    default: {
      $list_cmd   = shellquote($default_cmds, 'read', $domain)
      $key_search = shellquote('grep', $key)

      exec { "osx_defaults delete ${host} ${domain}:${key}":
        command => shellquote($default_cmds, 'delete', $domain, $key),
        onlyif  => "${list_cmd} | ${key_search}",
        user    => $user
      }
    } # end default
  }
}
