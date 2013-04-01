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
  $defaults_cmd = '/usr/bin/defaults'

  $host_option = $host ? {
    'currentHost' => ' -currentHost',
    undef         => '',
    default       => " -host ${host}"
  }

  case $ensure {
    present: {
      if ($domain == undef) or ($key == undef) or ($value == undef) {
        fail('Cannot ensure present without domain, key, and value attributes')
      }

      if ($type == undef) and (($value == true) or ($value == false)) {
        $type_ = 'bool'
      } else {
        $type_ = $type
      }

      if (is_hash($value)) {
        $value_ = inline_template('<%= value.to_a.flatten.map {|e| "\'#{e}\'"}.join(" ") %>')
        if ($type_ == undef) {
          $type_ = 'dict'
        }
      } elsif (is_array($value)) {
        $value_ = inline_template('<%= value.map {|e| "\'#{e}\'"}.join(" ") %>')
        if ($type_ == undef) {
          $type_ = 'dict'
        }
      } else {
        $value_ = "'${value}'"
      }

      $cmd = $type_ ? {
        undef   => "${defaults_cmd}${host_option} write ${domain} ${key} ${value_}",
        default => "${defaults_cmd}${host_option} write ${domain} ${key} -${type_} ${value_}"
      }

      if ($type_ =~ /^bool/) {
        $checkvalue = $value_ ? {
          /(true|yes)/ => '1',
          /(false|no)/ => '0',
        }
      } else {
        $checkvalue = $value
      }
      exec { "osx_defaults write ${host} ${domain}:${key}=>${value_}":
        command => $cmd,
        unless  => "${defaults_cmd}${host_option} read ${domain} ${key} && (${defaults_cmd}${host_option} read ${domain} ${key} | awk '{ exit \$0 != \"${checkvalue}\" }')",
        user    => $user
      }
    } # end present

    default: {
      exec { "osx_defaults delete ${host} ${domain}:${key}":
        command => "${defaults_cmd}${host_option} delete ${domain} ${key}",
        onlyif  => "${defaults_cmd}${host_option} read ${domain} | grep ${key}",
        user    => $user
      }
    } # end default
  }
}
