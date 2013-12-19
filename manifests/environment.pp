# Public: Set up a basic Boxen environment
#
# Usage:
#
#   include boxen::environment

class boxen::environment(
  $relative_bin_on_path = true,
) {
  # must be run very early
  require boxen::config
  require boxen::gemrc

  # can be run whenever
  include boxen::bin
  include boxen::janitor
  include boxen::personal
  include boxen::profile
  include boxen::repo
  include boxen::security
  include boxen::sudoers

  include_projects_from_boxen_cli()

  $relative_bin_on_path_ensure = $relative_bin_on_path ? {
    true    => present,
    default => absent,
  }

  boxen::env_script {
    'config':
      content  => template('boxen/config.sh.erb'),
      priority => 'highest' ;
    'gh_creds':
      content  => template('boxen/gh_creds.sh.erb'),
      priority => 'higher' ;
    'relative_bin_on_path':
      ensure   => $relative_bin_on_path_ensure,
      source   => 'puppet:///modules/boxen/relative_bin_on_path.sh',
      priority => 'lowest' ;
    'boxen_autocomplete':
      content  => template('boxen/boxen_autocomplete.sh.erb'),
      priority => 'lowest' ;
  }
}
