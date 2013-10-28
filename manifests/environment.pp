# Public: Set up a basic Boxen environment
#
# Usage:
#
#   include boxen::environment

class boxen::environment {
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

  boxen::env_script {
    'config':
      content  => template('boxen/config.sh.erb'),
      priority => 'highest' ;
    'gh_creds':
      content  => template('boxen/gh_creds.sh.erb'),
      priority => 'higher' ;
  }
}
